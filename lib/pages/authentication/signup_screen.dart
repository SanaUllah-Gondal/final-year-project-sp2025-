import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for input formatting
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/electrition/electrition_profile.dart';
import 'package:plumber_project/pages/plumber/plumber_profile.dart';
import 'package:plumber_project/pages/users/user_profile.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/authentication/otp_page.dart';
import 'package:plumber_project/pages/cleaner/cleaner_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  bool _isOtpVisible = false;

  // CNIC validation for Pakistani CNIC
  bool _isValidCnic(String cnic) {
    // Remove any dashes or spaces
    String cleanCnic = cnic.replaceAll(RegExp(r'[-\s]'), '');

    // Check if it's exactly 13 digits
    if (cleanCnic.length != 13) return false;

    // Check if all characters are digits
    if (!RegExp(r'^[0-9]{13}$').hasMatch(cleanCnic)) return false;

    return true;
  }

  // Check if CNIC already exists in Firestore
  Future<bool> _isCnicAlreadyTaken(String cnic) async {
    try {
      String cleanCnic = cnic.replaceAll(RegExp(r'[-\s]'), '');

      final querySnapshot = await _firestore
          .collection('cnic')
          .where('cnic_number', isEqualTo: cleanCnic)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking CNIC: $e');
      return true; // Return true to prevent registration in case of error
    }
  }

  // Save CNIC to Firestore
  Future<void> _saveCnicToFirestore(String cnic, String email) async {
    try {
      String cleanCnic = cnic.replaceAll(RegExp(r'[-\s]'), '');

      await _firestore.collection('cnic').add({
        'cnic_number': cleanCnic,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving CNIC to Firestore: $e');
      throw 'Failed to save CNIC information';
    }
  }

  Future<void> _handleSignUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String cnic = _cnicController.text.trim();

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

    if (cnic.isEmpty) {
      _showAlert('CNIC Required', 'Please enter your CNIC.');
      return;
    }

    if (!_isValidCnic(cnic)) {
      _showAlert('Invalid CNIC', 'Please enter a valid Pakistani CNIC (13 digits without dashes).');
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
      // First check if CNIC is already taken
      bool isCnicTaken = await _isCnicAlreadyTaken(cnic);
      if (isCnicTaken) {
        _showAlert('CNIC Already Exists', 'This CNIC is already registered. Please use a different CNIC.');
        setState(() => _isLoading = false);
        return;
      }

      // Then call your Laravel API
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
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

          // Save CNIC to Firestore
          await _saveCnicToFirestore(cnic, email);

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
              color: Colors.white
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
                  _buildLabel("CNIC"),
                  _buildCnicTextField(), // Use the new CNIC-specific text field
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

  // Special CNIC text field with digit-only restriction and max length
  Widget _buildCnicTextField() {
    return TextField(
      controller: _cnicController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Only allow digits
        LengthLimitingTextInputFormatter(13), // Maximum 13 characters
      ],
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "Enter your CNIC (13 digits)",
        helperText: "Enter 13-digit CNIC without dashes",
        helperStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.badge, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        counterText: "", // Remove the default counter
      ),
      maxLength: 13, // Set maximum length to 13
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text, String? helperText}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        helperText: helperText,
        helperStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
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