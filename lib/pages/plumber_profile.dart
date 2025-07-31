import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/plumber_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PlumberProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;

  const PlumberProfilePage({super.key, this.onSuccess});

  @override
  _PlumberProfilePageState createState() => _PlumberProfilePageState();
}

class _PlumberProfilePageState extends State<PlumberProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final FocusNode areaFocusNode = FocusNode();

  File? _profileImage;
  List<dynamic> _placeList = [];
  String _sessionToken = "1234567890";
  String? _bearerToken;

  double? _latitude;
  double? _longitude;

  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    areaController.addListener(_onChanged);
    areaFocusNode.addListener(() {
      if (!areaFocusNode.hasFocus) {
        setState(() {
          _placeList = [];
        });
      }
    });
    _loadLocalData();
    _getLiveLocation();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final name= prefs.getString('name') ?? 'Unknown';
    final role = prefs.getString('role') ?? 'Unknown';
    final token = prefs.getString('bearer_token');
    setState(() {
      roleController.text = role;
      nameController.text=name;
      _bearerToken = token;
    });
  }

  void _onChanged() {
    if (_sessionToken == "1234567890") {
      setState(() {
        _sessionToken = Random().nextInt(100000).toString();
      });
    }
    getSuggestion(areaController.text);
  }

  Future<void> getSuggestion(String input) async {
    const String PLACES_APIS_KEY = "YOUR_API_KEY_HERE";
    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location permission denied.")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission permanently denied.")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );
      if (placemarks.isNotEmpty) {
        String locationName = placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            '';
        setState(() {
          areaController.text = locationName;
        });
      }

      await _updateLocationOnServer(_latitude!, _longitude!);
    } catch (e) {
      print("Location fetch error: $e");
    }
  }

  Future<void> _updateLocationOnServer(double lat, double lng) async {
    if (_bearerToken == null || _bearerToken!.isEmpty) {
      print("Bearer token missing, can't update location");
      return;
    }

    final url = Uri.parse('$baseUrl/api/profile/update-location');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Accept': 'application/json',
        },
        body: {'latitude': lat.toString(), 'longitude': lng.toString()},
      );

      if (response.statusCode == 200) {
        print('Location updated on server');
      } else {
        print('Failed to update location on server: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating location on server: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_bearerToken == null || _bearerToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token is missing')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/api/profile/');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $_bearerToken',
      'Accept': 'application/json',
    });

    request.fields['full_name'] = nameController.text;
    request.fields['experience'] = experienceController.text;
    request.fields['skill'] = skillsController.text;
    request.fields['service_area'] = areaController.text;
    request.fields['hourly_rate'] = rateController.text;
    request.fields['contact_number'] = contactController.text;
    request.fields['role'] = roleController.text;

    if (_latitude != null && _longitude != null) {
      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();
    }

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile saved successfully')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlumberDashboard()),
        );
      } else {
        print('Failed: ${response.statusCode}');
        print('Body: ${response.body}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save profile')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving profile')));
    }
  }

  @override
  void dispose() {
    areaFocusNode.dispose();
    nameController.dispose();
    experienceController.dispose();
    skillsController.dispose();
    areaController.dispose();
    rateController.dispose();
    contactController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plumber Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBlue, tealBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
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
                      backgroundColor: Colors.grey,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text("Update Photo",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildLabeledTextField("Experience (Years)", experienceController,
                  type: TextInputType.number),
              _buildLabeledTextField("Skills", skillsController),
              _buildLabeledTextField("Service Area", areaController,
                  readOnly: true),
              _buildLabeledTextField("Hourly Rate (PKR)", rateController,
                  type: TextInputType.number),
              _buildLabeledTextField("Contact Number", contactController,
                  type: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ]),
              _buildLabeledTextField("Role", roleController, readOnly: true),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text("Save Profile", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Custom Plumber Dashboard with Gradient Background
// class PlumberDashboard extends StatelessWidget {
//   final Color darkBlue = const Color(0xFF003E6B);
//   final Color tealBlue = const Color(0xFF00A8A8);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [darkBlue, tealBlue],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             'Welcome to the Plumber Dashboard',
//             style: TextStyle(color: Colors.white, fontSize: 24),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }
// }
