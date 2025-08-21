import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/electrition/electrition_profile.dart';
import 'package:plumber_project/pages/plumber/plumber_profile.dart';
import 'package:plumber_project/pages/users/user_profile.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/authentication/otp_page.dart';
import 'package:plumber_project/pages/cleaner/cleaner_profile.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);
  final _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  bool _isOtpVisible = false;

  Future<void> _handleSignUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      _showAlert('Name Required', 'Please enter your name.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showAlert('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showAlert('Weak Password', 'Password must be at least 6 characters long.');
      return;
    }

    if (password != confirmPassword) {
      _showAlert('Password Mismatch', 'Passwords do not match.');
      return;
    }

    if (_selectedRole == null) {
      _showAlert('Select Role', 'Please select a role.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First call your Laravel API
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'), // Remove extra slash if baseUrl already has it
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
          'role': _selectedRole,
        }),
      ).timeout(const Duration(seconds: 30));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If Laravel API succeeds, then create Firebase user
        try {
          await _registerWithEmailAndPassword(email, password);

          // Show OTP screen
          setState(() => _isOtpVisible = true);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPopupScreen(
                email: email,
                visible: _isOtpVisible,
                onClose: () => setState(() => _isOtpVisible = false),
                onSuccess: _handleOtpSuccess,
              ),
            ),
          );
        } catch (firebaseError) {
          _showAlert('Firebase Error', firebaseError.toString());
        }
      } else {
        // Handle API errors
        String errorMessage = 'Failed to sign up';
        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null) {
          // Handle Laravel validation errors
          final errors = data['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first?.first?.toString() ?? errorMessage;
          }
        }
        _showAlert('Registration Failed', errorMessage);
      }
    } on http.ClientException catch (e) {
      _showAlert('Network Error', 'Could not connect to server: ${e.message}');
    } on TimeoutException {
      _showAlert('Timeout', 'Request timed out. Please try again.');
    } catch (e) {
      _showAlert('Error', 'Something went wrong: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = 'An unknown error occurred: ${e.code}';
      }
      throw message;
    } catch (e) {
      throw 'Failed to create user: ${e.toString()}';
    }
  }

  void _handleOtpSuccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _selectedRole!);

    Widget destination;
    switch (_selectedRole) {
      case 'plumber':
        destination = PlumberProfilePage();
        break;
      case 'electrician':
        destination = ElectricianProfilePage();
        break;
      case 'cleaner':
        destination = CleanerProfilePage();
        break;
      case 'user':
      default:
        destination = UserProfilePage();
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination)
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')
          )
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
              color: Colors.white // Changed to white for better visibility
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  const SizedBox(height: 40),
                  const Icon(Icons.person_add, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  _buildLabel("Name"),
                  _buildTextField(_nameController, "Enter your name", Icons.person),
                  const SizedBox(height: 10),
                  _buildLabel("Email"),
                  _buildTextField(_emailController, "Enter your email", Icons.email),
                  const SizedBox(height: 10),
                  _buildLabel("Password"),
                  _buildTextField(_passwordController, "Enter your password", Icons.lock,
                      obscure: true),
                  const SizedBox(height: 10),
                  _buildLabel("Confirm Password"),
                  _buildTextField(_confirmPasswordController, "Confirm your password", Icons.lock,
                      obscure: true),
                  const SizedBox(height: 10),
                  _buildLabel("Select Role"),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'plumber', child: Text("Plumber")),
                      DropdownMenuItem(value: 'electrician', child: Text("Electrician")),
                      DropdownMenuItem(value: 'cleaner', child: Text("Cleaner")),
                      DropdownMenuItem(value: 'user', child: Text("Customer")),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                    hint: const Text("Select your role"),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCD00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(_isLoading ? "Signing Up..." : "Sign Up"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  LoginScreen()),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFFFFCD00),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }
}