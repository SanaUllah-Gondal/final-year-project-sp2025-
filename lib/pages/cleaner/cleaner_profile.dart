import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/cleaner/cleaner_dashboard.dart';
import '../authentication/login.dart';

class CleanerProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CleanerProfilePage({Key? key, this.onSuccess}) : super(key: key);

  @override
  _CleanerProfilePageState createState() => _CleanerProfilePageState();
}

class _CleanerProfilePageState extends State<CleanerProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final experienceController = TextEditingController();
  final skillsController = TextEditingController();
  final rateController = TextEditingController();
  final contactController = TextEditingController();
  final roleController = TextEditingController();

  File? _profileImage;
  String? _bearerToken;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getLocationAndAddress();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    roleController.text = prefs.getString('role') ?? 'cleaner';
    nameController.text = prefs.getString('name') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    _bearerToken = prefs.getString('bearer_token');
  }

  Future<void> _navigateToLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAll(
            () => LoginScreen(),
        routeName: '/login',
        predicate: (route) => false,
      );
    } catch (e) {
      debugPrint('Error navigating to login: $e');
    }
  }

  Future<void> _getLocationAndAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        'Permission permanently denied. Open settings.',
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
        });
      } else {
        _showSnackBar('No address found');
      }
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
    }
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
  }

  Future<void> _pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _submitProfile() async {
    if (_bearerToken == null) {
      _showSnackBar('Authentication required');
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        experienceController.text.isEmpty ||
        skillsController.text.isEmpty ||
        rateController.text.isEmpty ||
        contactController.text.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    if (_profileImage == null) {
      _showSnackBar('Please upload a profile image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl/api/profile/cleaner');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_bearerToken';

    request.fields.addAll({
      'full_name': nameController.text,
      'email': emailController.text,
      'experience': experienceController.text,
      'skill': skillsController.text,
      'hourly_rate': rateController.text,
      'contact_number': contactController.text,
      if (_currentAddress != null) 'service_area': _currentAddress!,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'cleaner_image',
        _profileImage!.path,
      ),
    );

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save profile data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cleaner_profile', json.encode(responseData));

        _showSnackBar('Profile saved successfully');
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CleanerDashboard()),
          );
        }
      } else {
        final error = responseData['message'] ?? 'Failed to save profile';
        _showSnackBar(error);
      }
    } catch (e) {
      _showSnackBar('Error saving profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildField(
      String label,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
        bool readOnly = false,
        List<TextInputFormatter>? formatters,
        bool isRequired = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              if (isRequired)
                Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            readOnly: readOnly,
            inputFormatters: formatters,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: readOnly,
              fillColor: readOnly ? Colors.grey[200] : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _navigateToLogin();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Cleaner Profile Setup',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _navigateToLogin,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              backgroundColor: Colors.teal[200],
                              child: _profileImage == null
                                  ? Icon(Icons.cleaning_services,
                                  size: 50,
                                  color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20),
                                  onPressed: _pickImageOption,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Profile Photo',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildField("Full Name", nameController, isRequired: true),
                  _buildField("Email", emailController,
                      type: TextInputType.emailAddress,
                      isRequired: true),
                  _buildField(
                    "Experience (Years)",
                    experienceController,
                    type: TextInputType.number,
                    isRequired: true,
                  ),
                  _buildField("Cleaning Skills", skillsController,
                      isRequired: true),
                  _buildField(
                    "Hourly Rate (PKR)",
                    rateController,
                    type: TextInputType.number,
                    isRequired: true,
                  ),
                  _buildField(
                    "Contact Number",
                    contactController,
                    type: TextInputType.phone,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    isRequired: true,
                  ),
                  _buildField("Role", roleController, readOnly: true),
                  if (_currentAddress != null)
                    _buildField(
                      "Service Area",
                      TextEditingController(text: _currentAddress),
                      readOnly: true,
                    ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Save Profile",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}