import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/plumber/plumber_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http_parser/http_parser.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mime/mime.dart';

import '../../helper.dart';

class PlumberProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;
  final String? profileId;
  final String? locationToken;

  const PlumberProfilePage({
    super.key,
    this.onSuccess,
    this.profileId,
    this.locationToken,
  });

  @override
  _PlumberProfilePageState createState() => _PlumberProfilePageState();
}

class _PlumberProfilePageState extends State<PlumberProfilePage> {
  // Controllers and state variables
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final FocusNode areaFocusNode = FocusNode();

  File? _profileImage;
  String? _bearerToken;
  double? _latitude;
  double? _longitude;
  String? _address;
  String? _locationToken;
  bool _isLoading = false;
  bool _profileExists = false;
  StreamSubscription<Position>? _locationSubscription;
  bool _initialLocationFetched = false; // prevent duplicate immediate updates

  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    // do not start both simultaneously to avoid duplicate calls:
    // we'll fetch a one-time location first, then start live updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingProfile();
      _getLiveLocation();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    experienceController.dispose();
    skillsController.dispose();
    areaController.dispose();
    rateController.dispose();
    contactController.dispose();
    roleController.dispose();
    areaFocusNode.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    checkDeviceTime();
    setState(() {
      // ensure consistent key usage: 'bearer_token' everywhere
      roleController.text = prefs.getString('role') ?? 'plumber';
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = user?.email ?? prefs.getString('email') ?? '';
      _bearerToken = prefs.getString('bearer_token');
      _locationToken = widget.locationToken ?? prefs.getString('location_token');
    });
  }

  Future<void> _checkExistingProfile() async {
    try {
      if (_bearerToken == null) {
        // try to refresh/get a valid token
        _bearerToken = await _getValidToken();
        if (_bearerToken != null) {
          setState(() {});
        } else {
          return;
        }
      }

      if (_bearerToken == null) return;

      setState(() => _isLoading = true);

      final response = await http
          .get(
        Uri.parse('$baseUrl/api/profiles/check/plumber'),
        headers: {'Authorization': 'Bearer $_bearerToken'},
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exists'] == true) {
          setState(() => _profileExists = true);
          await _loadExistingProfile(data['profile_id']);
        }
      } else if (response.statusCode == 401) {
        // try refreshing token once
        final newToken = await _refreshToken();
        if (newToken != null) {
          _bearerToken = newToken;
          await _checkExistingProfile();
        }
      }
    } catch (e) {
      debugPrint('Profile check error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExistingProfile(String profileId) async {
    try {
      setState(() => _isLoading = true);

      final response = await http
          .get(
        Uri.parse('$baseUrl/api/profiles/plumber/$profileId'),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          nameController.text = data['full_name'] ?? '';
          emailController.text = data['email'] ?? '';
          experienceController.text = data['experience'] ?? '';
          skillsController.text = data['skill'] ?? '';
          areaController.text = data['service_area'] ?? '';
          rateController.text = data['hourly_rate']?.toString() ?? '';
          contactController.text = data['contact_number'] ?? '';
          _latitude = (data['location'] != null) ? (data['location']['latitude'] as num?)?.toDouble() : null;
          _longitude = (data['location'] != null) ? (data['location']['longitude'] as num?)?.toDouble() : null;
          _address = data['location']?['address'];
          _locationToken = data['location_token'] ?? _locationToken;
        });
      }
    } catch (e) {
      debugPrint('Load profile error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100, // meters
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      // do not spam immediate small updates if initial already fetched
      _updateLocation(position.latitude, position.longitude, null);
    }, onError: (e) {
      debugPrint('Location stream error: $e');
    });
  }

  Future<void> _getLiveLocation() async {
    try {
      setState(() => _isLoading = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar("Location permission permanently denied. Please enable in app settings.");
        return;
      }

      // The actual location call
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = placemarks.isNotEmpty ? _formatAddress(placemarks.first) : 'Unknown Location';
        areaController.text = _address ?? '';
      });

      // update location now, but if authenticated prefer that
      await _updateLocation(_latitude!, _longitude!, _address);

      // start background/live updates only after initial successful fetch
      if (!_initialLocationFetched) {
        _initialLocationFetched = true;
        await _startLocationUpdates();
      }
    } on TimeoutException {
      // queue update when timed out
      _showSnackBar("Location request timed out — update will be queued.");
      if (_latitude != null && _longitude != null) {
        await _queueLocationUpdate(_latitude!, _longitude!, _address);
      }
    } catch (e) {
      debugPrint("Location fetch error: $e");
      _showSnackBar("Failed to get location: ${e.toString()}");
      if (_latitude != null && _longitude != null) {
        await _queueLocationUpdate(_latitude!, _longitude!, _address);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatAddress(Placemark placemark) {
    return [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.postalCode,
      placemark.country
    ].where((part) => part?.isNotEmpty ?? false).join(', ');
  }

  Future<void> _updateLocation(double lat, double lng, String? address) async {
    try {
      // Try authenticated endpoint first if we have a token
      if (_bearerToken != null && _bearerToken!.isNotEmpty) {
        await _updateLocationWithToken(lat, lng, address);
        return;
      }

      // Try to get a valid token (maybe refresh)
      final token = await _getValidToken();
      if (token != null) {
        _bearerToken = token;
        await _updateLocationWithToken(lat, lng, address);
        return;
      }

      // Fall back to public endpoint if allowed
      if (widget.profileId != null && _locationToken != null) {
        await _updateLocationPublic(widget.profileId!, _locationToken!, lat, lng, address);
      } else {
        _queueLocationUpdate(lat, lng, address);
      }
    } catch (e) {
      debugPrint('Location update error: $e');
      // queue as fallback
      _queueLocationUpdate(lat, lng, address);
    }
  }

  Future<void> _updateLocationWithToken(double lat, double lng, String? address) async {
    final client = http.Client();
    try {
      debugPrint('Attempting authenticated location update...');
      debugPrint('Lat: $lat, Lng: $lng, Address: $address');

      final uri = Uri.parse('$baseUrl/api/profiles/update-location');
      debugPrint('Endpoint: $uri');

      final response = await client
          .post(
        uri,
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'latitude': lat,
          'longitude': lng,
          'address': address,
        }),
      )
          .timeout(const Duration(seconds: 10));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Location updated successfully (authenticated)');
      } else if (response.statusCode == 401) {
        debugPrint('Token expired, attempting refresh...');
        final newToken = await _refreshToken();
        if (newToken != null) {
          _bearerToken = newToken;
          await _updateLocationWithToken(lat, lng, address);
        } else {
          // queue as fallback
          await _queueLocationUpdate(lat, lng, address);
        }
      } else {
        throw Exception('Failed with status: ${response.statusCode}\n${response.body}');
      }
    } on TimeoutException {
      debugPrint('Location update timed out');
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('Error in _updateLocationWithToken: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> _updateLocationPublic(
      String profileId,
      String locationToken,
      double lat,
      double lng,
      String? address,
      ) async {
    final client = http.Client();
    try {
      debugPrint('Attempting public location update...');
      debugPrint('Profile ID: $profileId, Token: $locationToken');

      final uri = Uri.parse('$baseUrl/api/profiles/update-location-public');
      debugPrint('Endpoint: $uri');

      final response = await client
          .post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'profile_id': profileId,
          'location_token': locationToken,
          'latitude': lat,
          'longitude': lng,
          'address': address,
        }),
      )
          .timeout(const Duration(seconds: 10));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Location updated successfully (public)');
      } else {
        throw Exception('Failed with status: ${response.statusCode}\n${response.body}');
      }
    } on TimeoutException {
      debugPrint('Public location update timed out');
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('Error in _updateLocationPublic: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> _queueLocationUpdate(double lat, double lng, String? address) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUpdates = prefs.getStringList('pending_location_updates') ?? [];

    pendingUpdates.add(json.encode({
      'latitude': lat,
      'longitude': lng,
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
    }));

    await prefs.setStringList('pending_location_updates', pendingUpdates);
    debugPrint('Location update queued (${pendingUpdates.length} pending)');
    checkDeviceTime();

    // Helpful debug fetches (non-critical)
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/server-time')).timeout(const Duration(seconds: 6));
      final response1 = await http.get(Uri.parse('$baseUrl/api/debug-time')).timeout(const Duration(seconds: 6));
      debugPrint('Server Time: ${response.body}');
      debugPrint('Debug Time: ${response1.body}');
    } catch (e) {
      debugPrint('Server time fetch failed: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar("Failed to pick image: ${e.toString()}");
    }
  }

  void checkDeviceTime() {
    final currentTime = DateTime.now();
    debugPrint('Current Device Time: $currentTime');
    debugPrint('Is device time automatic? (Should be true)');
  }

  Future<void> _submitProfile() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      // 1. Get valid token with automatic refresh
      String? token = await _getValidTokenWithRefresh();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }
      _bearerToken = token;

      // 2. Validate all fields
      final fieldErrors = _validateProfileFields();
      if (fieldErrors.isNotEmpty) {
        throw Exception('Missing or invalid fields: ${fieldErrors.join(', ')}');
      }

      // 3. Send the request with token retry logic
      final response = await _sendProfileRequestWithTokenRetry(token);

      // 4. Handle successful response
      _handleSuccessResponse(response);
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _getValidTokenWithRefresh() async {
    String? token = await _getValidToken();
    debugPrint('Initial token: $token');

    if (token != null && token.isNotEmpty) {
      final payload = parseJwt(token);
      final exp = payload['exp'] as int?;

      if (exp != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final timeRemaining = expiryTime.difference(DateTime.now());
        debugPrint('Token expires at: $expiryTime');
        debugPrint('Time remaining: $timeRemaining');

        // Refresh token if it expires soon or is invalid
        if (timeRemaining < const Duration(minutes: 10)) {
          debugPrint('Token expires soon, refreshing...');
          final refreshed = await _refreshToken();
          debugPrint(refreshed != null ? 'Token refreshed' : 'Refresh failed');
          if (refreshed != null) token = refreshed;
        }
      }
    }

    return token;
  }

  List<String> _validateProfileFields() {
    final errors = <String>[];

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final experience = experienceController.text.trim();
    final skills = skillsController.text.trim();
    final area = areaController.text.trim();
    final rate = rateController.text.trim();
    final contact = contactController.text.trim();

    if (name.isEmpty) errors.add('Name');
    if (email.isEmpty || !EmailValidator.validate(email)) {
      errors.add('Valid Email');
    }
    if (experience.isEmpty) errors.add('Experience');
    if (skills.isEmpty) errors.add('Skills');
    if (area.isEmpty) errors.add('Service Area');
    if (rate.isEmpty || double.tryParse(rate) == null) {
      errors.add('Valid Hourly Rate');
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(contact)) {
      errors.add('Valid Contact Number (10-11 digits)');
    }
    if (_profileImage == null && !_profileExists) errors.add('Profile Image');

    return errors;
  }

  Future<http.Response> _sendProfileRequestWithTokenRetry(String initialToken) async {
    final isUpdate = _profileExists || widget.profileId != null;
    final url = isUpdate ? '$baseUrl/api/profiles/plumber/me' : '$baseUrl/api/profiles/plumber';

    // First attempt
    var response = await _sendProfileRequest(
      url: url,
      isUpdate: isUpdate,
      token: initialToken,
    );

    // If unauthorized, try with refreshed token
    if (response.statusCode == 401) {
      debugPrint('Token rejected, attempting refresh...');
      final newToken = await _refreshToken();

      if (newToken != null) {
        debugPrint('Retrying with new token');
        response = await _sendProfileRequest(
          url: url,
          isUpdate: isUpdate,
          token: newToken,
        );
      } else {
        throw Exception('Session expired. Please login again.');
      }
    }

    return response;
  }

  Future<http.Response> _sendProfileRequest({
    required String url,
    required bool isUpdate,
    required String token,
  }) async {
    final request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', Uri.parse(url));

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add fields (trim values)
    request.fields.addAll({
      'full_name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'experience': experienceController.text.trim(),
      'skill': skillsController.text.trim(),
      'service_area': areaController.text.trim(),
      'hourly_rate': rateController.text.trim(),
      'contact_number': contactController.text.trim(),
      'latitude': _latitude?.toString() ?? '',
      'longitude': _longitude?.toString() ?? '',
      'address': _address ?? '',
    });

    // Add image
    if (_profileImage != null) {
      try {
        final mimeType = lookupMimeType(_profileImage!.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');
        final contentType = MediaType(mimeParts[0], mimeParts[1]);

        request.files.add(await http.MultipartFile.fromPath(
          'plumber_image',
          _profileImage!.path,
          contentType: contentType,
        ));
      } catch (e) {
        debugPrint('Failed to attach image: $e');
      }
    }

    // Show loading snack bar
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Row(children: [
        const SizedBox(width: 4),
        const CircularProgressIndicator(),
        const SizedBox(width: 16),
        Text(isUpdate ? 'Updating profile...' : 'Creating profile...'),
      ]),
      duration: const Duration(minutes: 1),
    ));

    try {
      // Send with a timeout wrapper
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 10));
      scaffold.hideCurrentSnackBar();
      return response;
    } on TimeoutException {
      scaffold.hideCurrentSnackBar();
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      rethrow;
    }
  }

  void _handleSuccessResponse(http.Response response) {
    final responseData = json.decode(response.body);
    final isUpdate = _profileExists || widget.profileId != null;

    if (!isUpdate && responseData['location_token'] != null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('location_token', responseData['location_token']);
        _locationToken = responseData['location_token'];
      });
    }

    _showSnackBar(responseData['message'] ??
        (isUpdate ? 'Profile updated successfully' : 'Profile created successfully'));

    widget.onSuccess?.call();

    if (!isUpdate && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PlumberDashboard()),
      );
    }
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An error occurred';

    if (error is http.ClientException) {
      errorMessage = 'Network error: ${error.message}';
    } else if (error.toString().contains('Unauthenticated')) {
      errorMessage = 'Session expired. Please login again.';
    } else {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    _showSnackBar(errorMessage);
    debugPrint('Profile submission error: $error');
  }

  // JWT Helper Functions
  Map<String, dynamic> parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid token format');

      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('Invalid payload format');
      }

      return payloadMap;
    } catch (e) {
      debugPrint('JWT parsing error: $e');
      return {};
    }
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Future<String?> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Accept': 'application/json'},
        body: {'refresh_token': refreshToken},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['access_token'];
        final newRefresh = data['refresh_token'];

        if (newToken != null) {
          // Save under consistent key 'bearer_token'
          await prefs.setString('bearer_token', newToken);
        }
        if (newRefresh != null) {
          await prefs.setString('refresh_token', newRefresh);
        }
        // For compatibility, also set 'auth_token' if some parts expect it
        if (data['access_token'] != null) {
          await prefs.setString('auth_token', data['access_token']);
        }
        return data['access_token'];
      } else {
        debugPrint('Refresh failed: ${response.statusCode} ${response.body}');
      }
      return null;
    } on TimeoutException {
      debugPrint('Token refresh timed out.');
      return null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<String?> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    // Quick sanity: token length check
    if (token != null && token.length > 30) {
      return token;
    }

    // Attempt to refresh token if not present or invalid
    try {
      final newToken = await _refreshToken();
      if (newToken != null) {
        // ensure we store and return consistent key
        final freshPrefs = await SharedPreferences.getInstance();
        await freshPrefs.setString('bearer_token', newToken);
        return newToken;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _profileExists ? "Update Plumber Profile" : "Create Plumber Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: darkBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
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
                  _buildProfileImageSection(),
                  SizedBox(height: 20),
                  _buildProfileForm(),
                  SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
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
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                backgroundColor: Colors.grey,
                child: _profileImage == null ? Icon(Icons.person, size: 60, color: Colors.white) : null,
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          TextButton.icon(
            onPressed: _isLoading ? null : _pickImageFromGallery,
            icon: Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              _profileExists ? "Change Photo" : "Upload Photo",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField("Full Name", nameController),
        _buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress),
        _buildTextField("Experience (Years)", experienceController, keyboardType: TextInputType.number),
        _buildTextField("Skills", skillsController),
        _buildLocationField("Service Area", areaController),
        _buildTextField(
          "Hourly Rate (PKR)",
          rateController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
        ),
        _buildTextField(
          "Contact Number",
          contactController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            enabled: !_isLoading,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: true,
            enabled: !_isLoading,
            onTap: _isLoading ? null : _getLiveLocation,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: 'Tap to get current location',
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: Icon(Icons.location_on, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        _profileExists ? "Update Profile" : "Create Profile",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
