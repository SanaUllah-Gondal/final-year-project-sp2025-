
import 'package:flutter/material.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/electrition/electrition_profile.dart';
import 'package:plumber_project/pages/plumber/plumber_profile.dart';
import 'package:plumber_project/pages/users/user_profile.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/authentication/otp_page.dart';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  bool _isOtpVisible = false;



  /// [EmailAuthentication] - REGISTER
  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) { // Throw custom [message] variable
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        default:
          message = 'An unknown error occurred.';
      }
      throw message;
    } catch (_) {
      const message = 'Something went wrong. Please try again.';
      throw message;
    }
  }
  Future<void> _handleSignUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (!email.contains('@')) {
      _showAlert('Invalid Email', 'Please enter a valid email address.');
      return;
    }
    if (password != confirmPassword) {
      _showAlert('Password Mismatch', 'Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      _showAlert(
          'Weak Password', 'Password must be at least 6 characters long.');
      return;
    }
    if (_selectedRole == null) {
      _showAlert('Select Role',
          'Please select a role (Plumber, Electrician, or User).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': _selectedRole,
        }),
      );


      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await registerWithEmailAndPassword(email, password);
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
      } else {
        _showAlert('Error', data['message'] ?? 'Failed to sign up');
      }
    } catch (e) {
      _showAlert('Error', 'Something went wrong. Please try again later.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleOtpSuccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _selectedRole!);

    Widget destination;
    if (_selectedRole == 'plumber') {
      destination = PlumberProfilePage();
    } else if (_selectedRole == 'electrician') {
      destination = ElectricianProfilePage();
    } else {
      destination = UserProfilePage();
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => destination));
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
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
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black),
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
                  const Icon(Icons.person_add, size: 80, color: Colors.black),
                  const SizedBox(height: 20),
                  _buildLabel("Name"),
                  _buildTextField(
                      _nameController, "Enter your name", Icons.person),
                  const SizedBox(height: 10),
                  _buildLabel("Email"),
                  _buildTextField(
                      _emailController, "Enter your email", Icons.email),
                  const SizedBox(height: 10),
                  _buildLabel("Password"),
                  _buildTextField(
                      _passwordController, "Enter your password", Icons.lock,
                      obscure: true),
                  const SizedBox(height: 10),
                  _buildLabel("Confirm Password"),
                  _buildTextField(_confirmPasswordController,
                      "Confirm your password", Icons.lock,
                      obscure: true),
                  const SizedBox(height: 10),
                  _buildLabel("Select Role"),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'plumber', child: Text("Plumber")),
                      DropdownMenuItem(
                          value: 'electrician', child: Text("Electrician")),
                      DropdownMenuItem(value: 'user', child: Text("Customer")),
                      DropdownMenuItem(value: 'cleaner', child: Text("Cleaner")),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                    hint: const Text("Select your role"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCD00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(_isLoading ? "Signing Up..." : "Sign Up"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?",
                          style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  LoginScreen()),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Color(0xFFFFCD00),
                              fontWeight: FontWeight.bold),
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
    return Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white));
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
