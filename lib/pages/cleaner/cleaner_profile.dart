import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  final experienceController = TextEditingController();
  final skillsController = TextEditingController();
  final rateController = TextEditingController();
  final contactController = TextEditingController();
  final roleController = TextEditingController();

  File? _profileImage;
  String? _bearerToken;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getLocationAndAddress();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    roleController.text = prefs.getString('role') ?? 'Cleaner';
    nameController.text = prefs.getString('name') ?? 'Unknown';
    _bearerToken = prefs.getString('bearer_token');
  }
  Future<void> _navigateToLogin() async {
    try {
      // Clear any existing data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset all GetX controllers and state
      Get.offAll(
            () => LoginScreen(),
        routeName: '/login',
        predicate: (route) => false, // Remove all routes
      );
    } catch (e) {
      debugPrint('Error navigating to login: $e');
    }
  }
  Future<void> _getLocationAndAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission permanently denied. Open settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Position fetched: ${position.latitude}, ${position.longitude}");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        print("Detected Address: $address");

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No address found')));
      }
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
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
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickFileImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _pickFileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _profileImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_bearerToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Token not found')));
      return;
    }

    final url = Uri.parse('$baseUrl/api/profile/');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_bearerToken';

    request.fields.addAll({
      'full_name': nameController.text,
      'experience': experienceController.text,
      'skill': skillsController.text,
      'hourly_rate': rateController.text,
      'contact_number': contactController.text,
      'role': roleController.text,
      if (_currentAddress != null) 'service_area': _currentAddress!,
      if (_currentPosition != null) ...{
        'latitude': _currentPosition!.latitude.toString(),
        'longitude': _currentPosition!.longitude.toString(),
      },
    });

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'cleaner_image',
          _profileImage!.path,
        ),
      );
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profile saved successfully')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CleanerDashboard()),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save profile')));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving profile')));
    }
  }

  Widget _buildField(
      String label,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
        bool readOnly = false,
        List<TextInputFormatter>? formatters,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
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
          return false; // Prevent default back button behavior
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    backgroundColor: Colors.teal[200],
                    child: _profileImage == null
                        ? Icon(Icons.cleaning_services, size: 50, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _pickImageOption,
                    icon: Icon(Icons.camera_alt, color: Colors.teal),
                    label: Text("Upload Profile Photo", style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildField("Full Name", nameController),
            _buildField(
              "Experience (Years)",
              experienceController,
              type: TextInputType.number,
            ),
            _buildField("Cleaning Skills", skillsController),
            _buildField(
              "Hourly Rate (PKR)",
              rateController,
              type: TextInputType.number,
            ),
            _buildField(
              "Contact Number",
              contactController,
              type: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
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
                onPressed: _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Save Profile",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}