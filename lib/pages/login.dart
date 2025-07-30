import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:plumber_project/pages/dashboard.dart';
import 'package:plumber_project/pages/electrition_dashboard.dart';
import 'package:plumber_project/pages/plumber_dashboard.dart' as dash;
import 'package:plumber_project/pages/electrition_profile.dart';
import 'package:plumber_project/pages/user_profile.dart';
import 'package:plumber_project/pages/plumber_profile.dart' as profile;
import 'signup_screen.dart';
import 'Apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    debugPrint('Initializing LoginScreen with baseUrl: $baseUrl');
  }

  void _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool remember = prefs.getBool('remember_me') ?? false;
      if (remember) {
        String? savedEmail = prefs.getString('email');
        debugPrint('Loaded saved email: $savedEmail');
        setState(() {
          _rememberMe = true;
          _emailController.text = savedEmail ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    debugPrint('Attempting login with email: $email');

    if (email.isEmpty || password.isEmpty) {
      _showAlert('Error', 'Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = '$baseUrl/api/login';
      debugPrint('Making request to: $url');

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'email': email, 'password': password});

      debugPrint('Request headers: $headers');
      debugPrint('Request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Check if response is HTML (indicates server error)
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        throw FormatException('Server returned HTML error page');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        await _handleSuccessfulLogin(data);
      } else {
        String errorMessage = data['error'] ??
            data['message'] ??
            'Invalid credentials. Status code: ${response.statusCode}';
        _showAlert('Login Error', errorMessage);
      }
    } on FormatException catch (e) {
      debugPrint('FormatException: $e');
      _showAlert('Server Error', 'Received unexpected response from server. Please check your API URL.');
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      _showAlert('Connection Error', 'Could not connect to the server. Please check your internet connection.');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      _showAlert('Timeout Error', 'Connection timed out. Please try again.');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showAlert('Error', 'An unexpected error occurred: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = data['access_token'];
      final Map<String, dynamic> user = data['user'];
      final String role = user['role'];
      final int userId = user['id'];

      debugPrint('Login successful for user: ${user['email']} with role: $role');

      // Save basic user data
      await prefs.setString('bearer_token', token);
      await prefs.setString('role', role);
      await prefs.setInt('user_id', userId);
      await prefs.setString('name', user['name']);
      await prefs.setString('email', user['email']);
      await prefs.setBool('remember_me', _rememberMe);

      // Check profile status
      bool hasProfile = await _checkUserProfile(token, userId, role, prefs);

      // Navigate to appropriate screen
      Widget destinationPage;
      if (role == 'plumber') {
        destinationPage = hasProfile
            ? dash.PlumberDashboard()
            : profile.PlumberProfilePage();
      } else if (role == 'electrician') {
        destinationPage =
        hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
      } else {
        destinationPage = hasProfile ? HomeScreen() : UserProfilePage();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destinationPage),
      );
    } catch (e) {
      debugPrint('Error handling successful login: $e');
      _showAlert('Error', 'Failed to complete login process.');
    }
  }

  Future<bool> _checkUserProfile(String token, int userId, String role, SharedPreferences prefs) async {
    try {
      final profileUrl = '$baseUrl/api/check-profile/$userId';
      debugPrint('Checking profile at: $profileUrl');

      final profileResponse = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Profile check status: ${profileResponse.statusCode}');
      debugPrint('Profile response: ${profileResponse.body}');

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);

        if (profileData['success'] == true && profileData['profile'] != null) {
          final profile = profileData['profile'];
          bool hasProfile = false;

          if (role == 'plumber' && profile['plumber_profile'] != null) {
            hasProfile = true;
            await prefs.setInt('plumber_profile_id', profile['plumber_profile']['id']);
          } else if (role == 'electrician' && profile['electrician_profile'] != null) {
            hasProfile = true;
            await prefs.setInt('electrician_profile_id', profile['electrician_profile']['id']);
          } else if (role == 'user' && profile['user_profile'] != null) {
            hasProfile = true;
            await prefs.setInt('user_profile_id', profile['user_profile']['id']);
          }

          await prefs.setString('profile_data', jsonEncode(profile));
          return hasProfile;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking profile: $e');
      return false;
    }
  }

  void _showAlert(String title, String message) {
    debugPrint('Showing alert: $title - $message');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Skill-Link',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.lock, size: 80, color: Colors.black),
                  const SizedBox(height: 20),
                  const Text(
                    "Email",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter your email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Password",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: "Enter your password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    title: const Text("Remember Me",
                        style: TextStyle(color: Colors.white)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCD00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(_isLoading ? "Logging in..." : "Login"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?",
                          style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFFFFCD00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}