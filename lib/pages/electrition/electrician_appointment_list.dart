import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notification/notification_helper.dart';
import '../../widgets/app_color.dart';
import '../../widgets/app_text_style.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../chat_screen.dart';
import 'controllers/electrician_dashboard_controller.dart';

class ElectricianAppointmentList extends StatefulWidget {
  @override
  _ElectricianAppointmentListState createState() => _ElectricianAppointmentListState();
}

class _ElectricianAppointmentListState extends State<ElectricianAppointmentList> {
  final ElectricianDashboardController _controller = Get.find();
  final ApiService _apiService = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _tabs = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
  var _selectedTab = 0.obs;
  var _isLoading = false.obs;
  var _appointments = [].obs;
  var _hasPendingRequests = false.obs;

  // Store Firebase user data
  final Map<String, Map<String, dynamic>> _userDataCache = {};
  final Map<String, Uint8List?> _profileImageCache = {};
  final Map<String, Uint8List?> _problemImageCache = {};

  // Bidding state
  final Map<String, double> _bidPrices = {};
  final Map<String, bool> _isPlacingBid = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      _isLoading.value = true;
      print('Loading Electrician appointments...');

      final response = await _apiService.getElectricianAppointments();
      print('Raw API response: $response');

      if (response['data'] != null) {
        final paginationData = response['data'];
        final appointmentsData = paginationData['data'];

        if (appointmentsData is List) {
          _appointments.value = appointmentsData;
          _checkPendingRequests();

          // Initialize bid prices - handle both String and numeric values
          for (var appointment in appointmentsData) {
            final appointmentId = appointment['id'].toString();
            final price = appointment['price'];
            if (price is String) {
              _bidPrices[appointmentId] = double.tryParse(price) ?? 0.0;
            } else if (price is num) {
              _bidPrices[appointmentId] = price.toDouble();
            } else {
              _bidPrices[appointmentId] = 0.0;
            }
            _isPlacingBid[appointmentId] = false;
          }

          // Pre-fetch user data from Firebase for all appointments
          for (var appointment in appointmentsData) {
            final user = appointment['user'];
            if (user != null && user['email'] != null) {
              await _fetchUserDataFromFirebase(user['email']);
            }

            // Fetch problem image from Firebase
            final providerId = appointment['provider_id']?.toString();
            final appointmentId = appointment['id']?.toString();
            if (providerId != null && appointmentId != null) {
              await _fetchProblemImageFromFirebase(providerId, appointmentId);
            }
          }
        } else {
          print('ERROR: appointmentsData is not a List');
          Get.snackbar('Error',
              'Invalid response format from server. Expected List but got ${appointmentsData.runtimeType}');
          _appointments.value = [];
        }
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to load appointments');
        _appointments.value = [];
      }
    } catch (e) {
      print('Exception in _loadAppointments: $e');
      Get.snackbar('Error', 'Failed to load appointments: $e');
      _appointments.value = [];
    } finally {
      _isLoading.value = false;
      print('Finished loading appointments');
    }
  }

  Future<void> _fetchUserDataFromFirebase(String email) async {
    if (_userDataCache.containsKey(email)) {
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        _userDataCache[email] = data;

        // Process profile image
        if (data.containsKey('profileImage') && data['profileImage'] != null) {
          final profileImage = data['profileImage'];
          if (profileImage is String && profileImage.startsWith('data:image/')) {
            final base64Data = profileImage.split(',').last;
            try {
              final imageBytes = base64.decode(base64Data);
              _profileImageCache[email] = imageBytes;
            } catch (e) {
              debugPrint('Error decoding base64 image: $e');
            }
          } else if (profileImage is String && profileImage.length > 100) {
            try {
              final imageBytes = base64.decode(profileImage);
              _profileImageCache[email] = imageBytes;
            } catch (e) {
              debugPrint('Error decoding raw base64 image: $e');
            }
          } else if (profileImage is String && profileImage.startsWith('http')) {
            _userDataCache[email]?['profileImageUrl'] = profileImage;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data from Firebase: $e');
    }
  }

  Future<void> _fetchProblemImageFromFirebase(String providerId, String appointmentId) async {
    final cacheKey = '$providerId-$appointmentId';

    if (_problemImageCache.containsKey(cacheKey)) {
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('electrician_appointment')
          .where('provider_id', isEqualTo: providerId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        if (data.containsKey('problem_image') && data['problem_image'] != null) {
          final problemImage = data['problem_image'];
          if (problemImage is String && problemImage.startsWith('data:image/')) {
            final base64Data = problemImage.split(',').last;
            try {
              final imageBytes = base64.decode(base64Data);
              _problemImageCache[cacheKey] = imageBytes;
            } catch (e) {
              debugPrint('Error decoding base64 problem image: $e');
            }
          } else if (problemImage is String && problemImage.length > 100) {
            try {
              final imageBytes = base64.decode(problemImage);
              _problemImageCache[cacheKey] = imageBytes;
            } catch (e) {
              debugPrint('Error decoding raw base64 problem image: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching problem image from Firebase: $e');
    }
  }

  void _checkPendingRequests() {
    _hasPendingRequests.value = _appointments.any((appt) =>
    appt['status'] == 'pending' &&
        DateTime.parse(appt['appointment_date']).isAfter(DateTime.now())
    );
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      _isLoading.value = true;

      // Find the appointment details
      final appointment = _appointments.firstWhere(
            (appt) => appt['id'].toString() == appointmentId,
        orElse: () => null,
      );

      if (appointment == null) {
        Get.snackbar('Error', 'Appointment not found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white);
        return;
      }

      final response = await _apiService.updateAppointmentStatus(
        'electrician',
        appointmentId,
        status,
      );

      if (response['success']) {
        // Send notification to user
        await _sendStatusNotification(appointment, status);

        Get.snackbar('Success', 'Appointment $status successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successColor,
            colorText: Colors.white);
        await _loadAppointments(); // Refresh the list
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update status',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _placeBid(String appointmentId, double bidPrice) async {
    try {
      _isPlacingBid[appointmentId] = true;
      update();

      final response = await _apiService.placeBid(
        'electrician',
        appointmentId,
        bidPrice,
      );

      if (response['success']) {
        _updateAppointmentStatus(appointmentId, "modified");
        Get.snackbar('Success', 'Bid placed successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successColor,
            colorText: Colors.white);

        // Send bid notification to user
        final appointment = _appointments.firstWhere(
              (appt) => appt['id'].toString() == appointmentId,
        );
        await _sendBidNotification(appointment, bidPrice);

        await _loadAppointments(); // Refresh the list
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to place bid',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to place bid: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white);
    } finally {
      _isPlacingBid[appointmentId] = false;
      update();
    }
  }

  Future<void> _sendStatusNotification(Map<String, dynamic> appointment, String status) async {
    try {
      final user = appointment['user'] ?? {};
      final userEmail = user['email'];
      final appointmentDate = DateTime.parse(appointment['appointment_date']);

      if (userEmail != null) {
        await NotificationHelper.sendAppointmentStatusNotification(
          userEmail: userEmail,
          appointmentId: appointment['id'].toString(),
          status: status,
          serviceType: 'electrician',
          providerName: 'Your Electrician',
          appointmentDate: appointmentDate,
        );
      }
    } catch (e) {
      print('❌ Error sending status notification: $e');
    }
  }

  Future<void> _sendBidNotification(Map<String, dynamic> appointment, double bidPrice) async {
    try {
      final user = appointment['user'] ?? {};
      final userEmail = user['email'];

      if (userEmail != null) {
        await NotificationHelper.sendBidNotification(
          userEmail: userEmail,
          appointmentId: appointment['id'].toString(),
          bidAmount: bidPrice,
          serviceType: 'electrician',
          providerName: 'Your Electrician',
        );
      }
    } catch (e) {
      print('❌ Error sending bid notification: $e');
    }
  }

  List<dynamic> _getFilteredAppointments() {
    final statusFilter = _tabs[_selectedTab.value].toLowerCase();
    return _appointments.where((appt) => appt['status'] == statusFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningColor;
      case 'confirmed':
        return AppColors.successColor;
      case 'completed':
        return AppColors.infoColor;
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.greyColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showImagePreview(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: PhotoView(
                imageProvider: MemoryImage(imageBytes),
                backgroundDecoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBidDialog(String appointmentId, double currentPrice) {
    double bidPrice = currentPrice;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.gavel, color: AppColors.primaryColor),
                SizedBox(width: 8),
                Text('Place Your Bid'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set your bid price for this appointment',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Text(
                  'Rs. ${bidPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                Slider(
                  value: bidPrice,
                  min: currentPrice - 100,
                  max: currentPrice + 500,
                  divisions: 60,
                  onChanged: (value) {
                    setState(() {
                      bidPrice = value;
                    });
                  },
                  activeColor: AppColors.primaryColor,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rs. ${(currentPrice - 100).toStringAsFixed(0)}'),
                    Text('Rs. ${(currentPrice + 500).toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _placeBid(appointmentId, bidPrice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Text('Place Bid'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to safely convert image data to base64 string
  String? _convertImageToBase64(dynamic image) {
    if (image == null) return null;
    if (image is String) return image;
    if (image is Uint8List) return base64.encode(image);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Appointment Requests',
          style: AppTextStyles.heading6.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        actions: [
          Obx(() => _hasPendingRequests.value
              ? CustomBadge(
            count: _appointments.where((appt) => appt['status'] == 'pending').length,
            child: IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                _selectedTab.value = 0;
              },
            ),
          )
              : IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          )),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAppointments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTab.value == index;
                final hasPending = index == 0 && _hasPendingRequests.value;

                return Expanded(
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () => _selectedTab.value = index,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryColor : AppColors.greyColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasPending && !isSelected)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.warningColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            )),
          ),

          // Appointments List
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return _buildShimmerLoading();
              }

              final filteredAppointments = _getFilteredAppointments();

              if (filteredAppointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: AppColors.greyColor.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No ${_tabs[_selectedTab.value]} appointments',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyColor),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for new requests',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadAppointments,
                backgroundColor: AppColors.primaryColor,
                color: Colors.white,
                child: ListView.separated(
                  itemCount: filteredAppointments.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.lightGrey),
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return _buildAppointmentCard(appointment);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(16),
        child: LoadingShimmer.card(),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final appointmentDate = DateTime.parse(appointment['appointment_date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final status = appointment['status'];
    final user = appointment['user'] ?? {};
    final userEmail = user['email'];
    final providerId = appointment['provider_id']?.toString();
    final appointmentId = appointment['id']?.toString();

    // Handle price conversion safely
    final price = appointment['price'];
    double currentPrice;
    if (price is String) {
      currentPrice = double.tryParse(price) ?? 0.0;
    } else if (price is num) {
      currentPrice = price.toDouble();
    } else {
      currentPrice = 0.0;
    }

    // Get Firebase user data if available
    final firebaseUserData = userEmail != null ? _userDataCache[userEmail] : null;
    final phoneNumber = firebaseUserData?['contactNumber'] ?? 'No phone number';
    final profileImageBytes = userEmail != null ? _profileImageCache[userEmail] : null;
    final profileImageUrl = firebaseUserData?['profileImageUrl'];

    // Get problem image from Firebase cache
    final problemImageBytes = (providerId != null && appointmentId != null)
        ? _problemImageCache['$providerId-$appointmentId']
        : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with User Info and Status
                Row(
                  children: [
                    // User Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 23,
                        backgroundImage: profileImageBytes != null
                            ? MemoryImage(profileImageBytes)
                            : profileImageUrl != null
                            ? CachedNetworkImageProvider(profileImageUrl)
                            : AssetImage('assets/icons/user_location.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 12),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'Unknown User',
                            style: AppTextStyles.subtitle1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: AppColors.greyColor),
                              SizedBox(width: 4),
                              Text(
                                phoneNumber,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(status), size: 14, color: _getStatusColor(status)),
                          SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Divider(color: AppColors.lightGrey),

                // Appointment Details
                _buildDetailRow(Icons.calendar_today, '$formattedDate at $formattedTime'),
                SizedBox(height: 8),
                _buildDetailRow(Icons.location_on, appointment['address'] ?? 'No address provided'),
                SizedBox(height: 8),
                _buildDetailRow(Icons.attach_money, 'Rs. ${currentPrice.toStringAsFixed(0)}'),

                // Bid Information
                if (appointment['bid_amount'] != null && appointment['bid_amount'] > 0)
                  _buildDetailRow(Icons.gavel, 'Your Bid: Rs. ${appointment['bid_amount'].toStringAsFixed(0)}'),

                // Problem Description
                if (appointment['description'] != null) ...[
                  SizedBox(height: 12),
                  Text(
                    'Problem Description:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment['description'],
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyColor),
                    ),
                  ),
                ],

                // Problem Image
                if (problemImageBytes != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Problem Image:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showImagePreview(problemImageBytes),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          problemImageBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.lightGrey,
                            child: Icon(Icons.error, color: AppColors.greyColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to view full image',
                    style: AppTextStyles.caption.copyWith(color: AppColors.greyColor),
                    textAlign: TextAlign.center,
                  ),
                ],

                SizedBox(height: 16),

                // Action Buttons
                if (status == 'pending')
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateAppointmentStatus(
                                appointment['id'].toString(),
                                'confirmed',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.check_circle, size: 20),
                              label: Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _updateAppointmentStatus(
                                appointment['id'].toString(),
                                'cancelled',
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.errorColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.cancel, size: 20, color: AppColors.errorColor),
                              label: Text(
                                'Reject',
                                style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showBidDialog(appointmentId!, currentPrice),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warningColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.gavel, size: 20),
                              label: _isPlacingBid[appointmentId] == true
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : Text('Place Bid', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final userName = user['name'] ?? 'Customer';
                                final userImage = _convertImageToBase64(profileImageUrl ?? profileImageBytes);
                                _controller.openOrCreateChat(
                                  userEmail: userEmail!,
                                  userName: userName,
                                  userImage: userImage,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.infoColor),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.message, size: 20, color: AppColors.infoColor),
                              label: Text(
                                'Chat',
                                style: TextStyle(color: AppColors.infoColor, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                if (status == 'confirmed')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final userName = user['name'] ?? 'Customer';
                            final userImage = _convertImageToBase64(profileImageUrl ?? profileImageBytes);
                            _controller.openOrCreateChat(
                              userEmail: userEmail!,
                              userName: userName,
                              userImage: userImage,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.infoColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.message, size: 20),
                          label: Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateAppointmentStatus(
                            appointment['id'].toString(),
                            'cancelled',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.errorColor),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.cancel, size: 20, color: AppColors.errorColor),
                          label: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (status == 'completed' || status == 'cancelled')
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status == 'completed'
                          ? AppColors.successColor.withOpacity(0.1)
                          : AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status == 'completed' ? Icons.verified : Icons.block,
                          color: status == 'completed' ? AppColors.successColor : AppColors.errorColor,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          status == 'completed'
                              ? 'This appointment has been completed'
                              : 'This appointment was cancelled',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: status == 'completed' ? AppColors.successColor : AppColors.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }
}