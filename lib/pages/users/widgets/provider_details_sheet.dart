import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../Apis.dart';

class ProviderDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceType;
  final VoidCallback onBookAppointment;
  final Color primaryColor;
  final Color secondaryColor;

  const ProviderDetailsSheet({
    Key? key,
    required this.provider,
    required this.serviceType,
    required this.onBookAppointment,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.teal,
  }) : super(key: key);

  @override
  State<ProviderDetailsSheet> createState() => _ProviderDetailsSheetState();
}

class _ProviderDetailsSheetState extends State<ProviderDetailsSheet> {
  String? _firebaseProfileImageUrl;
  bool _isLoadingFirebaseImage = false;
  Uint8List? _firebaseProfileImageBytes;
  double? _firebaseHourlyRate;

  @override
  void initState() {
    super.initState();
    _loadProfileDataFromFirebase();
  }

  Future<void> _loadProfileDataFromFirebase() async {
    final providerType = widget.provider['provider_type']?.toString().toLowerCase() ??
        widget.serviceType.toLowerCase();
    final email = widget.provider['email']?.toString();

    if (email == null || email.isEmpty) return;

    setState(() {
      _isLoadingFirebaseImage = true;
    });

    try {
      // Determine the collection name based on provider type
      String collectionName;
      switch (providerType.toLowerCase()) {
        case 'plumber':
          collectionName = 'plumbers';
          break;
        case 'electrician':
          collectionName = 'electricians';
          break;
        case 'cleaner':
          collectionName = 'cleaners';
          break;
        default:
          collectionName = 'providers'; // fallback collection
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        // Check if profileImage is a base64 string
        if (data.containsKey('profileImage') && data['profileImage'] != null) {
          final profileImage = data['profileImage'];

          if (profileImage is String && profileImage.startsWith('data:image/')) {
            // Handle data URI format: data:image/png;base64,...
            final base64Data = profileImage.split(',').last;
            try {
              final imageBytes = base64.decode(base64Data);
              setState(() {
                _firebaseProfileImageBytes = imageBytes;
              });
            } catch (e) {
              debugPrint('Error decoding base64 image: $e');
            }
          } else if (profileImage is String && profileImage.length > 100) {
            // Assume it's a raw base64 string without data URI prefix
            try {
              final imageBytes = base64.decode(profileImage);
              setState(() {
                _firebaseProfileImageBytes = imageBytes;
              });
            } catch (e) {
              debugPrint('Error decoding raw base64 image: $e');
            }
          } else if (profileImage is String && profileImage.startsWith('http')) {
            // It's a URL, not base64
            setState(() {
              _firebaseProfileImageUrl = profileImage;
            });
          }
        }

        // Get hourlyRate from Firebase
        if (data.containsKey('hourlyRate') && data['hourlyRate'] != null) {
          final hourlyRate = data['hourlyRate'];
          if (hourlyRate is double) {
            setState(() {
              _firebaseHourlyRate = hourlyRate;
            });
          } else if (hourlyRate is int) {
            setState(() {
              _firebaseHourlyRate = hourlyRate.toDouble();
            });
          } else if (hourlyRate is String) {
            final parsedRate = double.tryParse(hourlyRate);
            if (parsedRate != null) {
              setState(() {
                _firebaseHourlyRate = parsedRate;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading profile data from Firebase: $e');
    } finally {
      setState(() {
        _isLoadingFirebaseImage = false;
      });
    }
  }

  // ----------------- Helpers -----------------

  double? parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Color getColorForProviderType(String type) {
    switch (type.toLowerCase()) {
      case 'plumber':
        return Colors.blue;
      case 'cleaner':
        return Colors.green;
      case 'electrician':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget getProviderIcon(String providerType, Color color, double size) {
    switch (providerType.toLowerCase()) {
      case 'plumber':
        return Icon(Icons.build, color: color, size: size);
      case 'cleaner':
        return Icon(Icons.cleaning_services, color: color, size: size);
      case 'electrician':
        return Icon(Icons.electrical_services, color: color, size: size);
      default:
        return Icon(Icons.person, color: color, size: size);
    }
  }

  Widget resolveProfileImage(String providerType, String rawImage, Color providerColor) {
    // First check if we have base64 image bytes
    if (_firebaseProfileImageBytes != null) {
      return Image.memory(
        _firebaseProfileImageBytes!,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading memory image: $error');
          return _buildFallbackIcon(providerType, providerColor);
        },
      );
    }

    // Check if we have a Firebase URL
    if (_firebaseProfileImageUrl != null && _firebaseProfileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _firebaseProfileImageUrl!,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        placeholder: (context, url) => Container(
          color: providerColor.withOpacity(0.1),
          child: Icon(Icons.person, color: providerColor, size: 30),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Firebase image load error: $error');
          return _buildApiImage(providerType, rawImage, providerColor);
        },
      );
    }

    // Fall back to API image
    return _buildApiImage(providerType, rawImage, providerColor);
  }

  Widget _buildApiImage(String providerType, String rawImage, Color providerColor) {
    if (rawImage.trim().isEmpty) {
      return _buildFallbackIcon(providerType, providerColor);
    }

    final r = rawImage.trim();

    // Already a full URL - use CachedNetworkImage
    if (r.startsWith('http://') || r.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: r,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        placeholder: (context, url) => Container(
          color: providerColor.withOpacity(0.1),
          child: Icon(Icons.person, color: providerColor, size: 30),
        ),
        errorWidget: (context, url, error) {
          debugPrint('API image load error: $error');
          return _buildFallbackIcon(providerType, providerColor);
        },
      );
    }

    // Construct URL for relative paths or filenames
    String imageUrl;
    if (r.startsWith('uploads/')) {
      imageUrl = '$baseUrl/$r';
    } else {
      final directory = 'uploads/${providerType.toLowerCase()}_images';
      imageUrl = '$baseUrl/$directory/$r';
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: 70,
      height: 70,
      placeholder: (context, url) => Container(
        color: providerColor.withOpacity(0.1),
        child: Icon(Icons.person, color: providerColor, size: 30),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Constructed image load error: $error (url: $url)');
        return _buildFallbackIcon(providerType, providerColor);
      },
    );
  }

  Widget _buildFallbackIcon(String providerType, Color providerColor) {
    return Container(
      color: providerColor.withOpacity(0.1),
      child: getProviderIcon(providerType, providerColor, 30),
    );
  }

  // Get the hourly rate with priority: Firebase > API
  double getHourlyRate() {
    // Priority 1: Use Firebase hourly rate if available
    if (_firebaseHourlyRate != null) {
      return _firebaseHourlyRate!;
    }

    // Priority 2: Use API hourly rate
    final apiHourlyRate = parseDouble(widget.provider['hourly_rate']) ?? 0;
    return apiHourlyRate;
  }

  // -------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerType =
        widget.provider['provider_type']?.toString().toLowerCase() ?? widget.serviceType.toLowerCase();

    final double experience = parseDouble(widget.provider['experience']) ?? 0;
    final String email = widget.provider['email']?.toString() ?? 'No email';
    final String phone =
        widget.provider['phone_number']?.toString() ?? widget.provider['phone']?.toString() ?? 'No phone';
    final String address = widget.provider['address_name']?.toString() ?? 'Location not specified';

    final String rawProfileImage = widget.provider['profile_image']?.toString() ?? '';

    final double rating = parseDouble(widget.provider['rating']) ?? 0;
    final int reviews = int.tryParse(widget.provider['reviews']?.toString() ?? '0') ?? 0;
    final double hourlyRate = getHourlyRate(); // Use the prioritized hourly rate
    final String serviceArea = widget.provider['service_area']?.toString() ?? 'Not specified';
    final String skills = widget.provider['skills']?.toString() ?? 'Not specified';

    final Color providerColor = getColorForProviderType(providerType);

    debugPrint('Provider data: ${widget.provider}');
    debugPrint('Raw profile image: $rawProfileImage');
    debugPrint('Firebase profile image available: ${_firebaseProfileImageBytes != null || _firebaseProfileImageUrl != null}');
    debugPrint('Hourly rate - Firebase: $_firebaseHourlyRate, API: ${widget.provider['hourly_rate']}, Final: $hourlyRate');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                // Profile Image Container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: providerColor, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: _isLoadingFirebaseImage
                        ? Container(
                      color: providerColor.withOpacity(0.1),
                      child: const CircularProgressIndicator(),
                    )
                        : resolveProfileImage(providerType, rawProfileImage, providerColor),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.provider['name'] ?? 'Unknown Provider',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        providerType.capitalizeFirst(),
                        style: TextStyle(color: providerColor, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Text('($reviews reviews)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Experience & Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard(
                    icon: Icons.work,
                    title: 'Experience',
                    value: '${experience.toStringAsFixed(0)} yrs',
                    color: providerColor
                ),
                _buildInfoCard(
                    icon: Icons.attach_money,
                    title: 'Hourly Rate',
                    value: hourlyRate > 0 ? '\$${hourlyRate.toStringAsFixed(2)}' : 'Not set',
                    color: providerColor
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Service Area and Skills
            if (serviceArea.isNotEmpty && serviceArea != 'Not specified')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Service Area',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16)
                  ),
                  const SizedBox(height: 6),
                  Text(serviceArea, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                ],
              ),

            if (skills.isNotEmpty && skills != 'Not specified')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Skills & Specialties',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16)
                  ),
                  const SizedBox(height: 6),
                  Text(skills, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                ],
              ),

            // Contact Information
            Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16)
            ),
            const SizedBox(height: 12),

            _buildContactInfo(icon: Icons.email, title: 'Email', value: email),
            const SizedBox(height: 8),
            _buildContactInfo(icon: Icons.phone, title: 'Phone', value: phone),
            const SizedBox(height: 8),
            _buildContactInfo(icon: Icons.location_on, title: 'Location', value: address),
            const SizedBox(height: 20),

            // Description
            if (widget.provider['description'] != null && widget.provider['description'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'About',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16)
                  ),
                  const SizedBox(height: 8),
                  Text(
                      widget.provider['description'].toString(),
                      style: const TextStyle(fontSize: 14, height: 1.4)
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Book Appointment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onBookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: providerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                    'Book Appointment Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String value
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 2),
              Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Safe capitalize extension
extension StringCap on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}