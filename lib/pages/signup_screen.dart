// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:plumber_project/pages/otp_page.dart';
// // import 'otp_popup_screen.dart'; // Import OTP screen
// // import 'coach_details_screen.dart'; // Coach details screen
// // import 'player_selector_screen.dart'; // Player selection screen

// class SignUpScreen extends StatefulWidget {
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   String? _selectedRole;
//   bool _isLoading = false;
//   bool _isOtpVisible = false;

//   // Function to validate and sign up user
//   Future<void> _handleSignUp() async {
//     String name = _nameController.text.trim();
//     String email = _emailController.text.trim();
//     String password = _passwordController.text;
//     String confirmPassword = _confirmPasswordController.text;

//     if (!email.contains('@')) {
//       _showAlert('Invalid Email', 'Please enter a valid email address.');
//       return;
//     }
//     if (password != confirmPassword) {
//       _showAlert('Password Mismatch', 'Passwords do not match.');
//       return;
//     }
//     if (password.length < 6) {
//       _showAlert(
//         'Weak Password',
//         'Password must be at least 6 characters long.',
//       );
//       return;
//     }
//     if (_selectedRole == null) {
//       _showAlert('Select Role', 'Please select a role (Coach or Player).');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:8000/api/signup/'), // Your API endpoint
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'name': name,
//           'email': email,
//           'password': password,
//           'password_confirmation': confirmPassword,
//           'role': _selectedRole,
//         }),
//       );

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         setState(() {
//           _isOtpVisible = true; // Show OTP popup
//         });
//         Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPopupScreen(email: email, visible: visible, onClose: onClose, onSuccess: onSuccess)); 
//           } else {
//         _showAlert('Error', data['message'] ?? 'Failed to sign up');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again later.');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Function to show alert dialogs
//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   // Function to handle OTP success and navigate
//   void _handleOtpSuccess() {
//     setState(() {
//       _isOtpVisible = false;
//     });

//     if (_selectedRole == 'coach') {
//       // Navigator.pushReplacement(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => CoachDetailsScreen()),
//       // );
//     } else {
//       // Navigator.pushReplacement(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => PlayerSelectorScreen()),
//       // );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "Sign Up",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),

//             // Name Field
//             Text(
//               "Name",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 hintText: "Enter your name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),

//             // Email Field
//             Text(
//               "Email",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 hintText: "Enter your email",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//               autocorrect: false,
//             ),
//             SizedBox(height: 10),

//             // Password Field
//             Text(
//               "Password",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(
//                 hintText: "Enter your password",
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             SizedBox(height: 10),

//             // Confirm Password Field
//             Text(
//               "Confirm Password",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             TextField(
//               controller: _confirmPasswordController,
//               decoration: InputDecoration(
//                 hintText: "Confirm your password",
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             SizedBox(height: 10),

//             // Role Selection Dropdown
//             Text(
//               "Select Role",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             DropdownButtonFormField<String>(
//               value: _selectedRole,
//               decoration: InputDecoration(border: OutlineInputBorder()),
//               items: [
//                 DropdownMenuItem(value: 'coach', child: Text("Coach")),
//                 DropdownMenuItem(value: 'player', child: Text("Player")),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _selectedRole = value;
//                 });
//               },
//               hint: Text("Select your role"),
//             ),
//             SizedBox(height: 20),

//             // Sign Up Button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _handleSignUp,
//               child: Text(_isLoading ? "Signing Up..." : "Sign Up"),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),

//       // OTP Popup (If visible)
//       // floatingActionButton: _isOtpVisible
//       //     ? OtpPopupScreen(
//       //         email: _emailController.text,
//       //         onClose: () => setState(() => _isOtpVisible = false),
//       //         onSuccess: _handleOtpSuccess,
//       //       )
//       //     : null,
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/electrition_profile.dart';
import 'package:plumber_project/pages/login.dart';
import 'package:plumber_project/pages/plumber_profile.dart';
import 'package:plumber_project/pages/user_profile.dart';
import 'dart:convert';

import 'otp_page.dart'; // Import OTP screen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  bool _isOtpVisible = false;

  // Function to validate and sign up user
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
        'Weak Password',
        'Password must be at least 6 characters long.',
      );
      return;
    }
    if (_selectedRole == null) {
      _showAlert('Select Role', 'Please select a role (Coach or Player).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/register/'), // Your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
          'role': _selectedRole,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _isOtpVisible = true; // Show OTP popup
        });
        // Directly navigate to OTP Popup
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpPopupScreen(
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show alert dialogs
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Function to handle OTP success and navigate
  void _handleOtpSuccess() {
  setState(() {
    _isOtpVisible = false;
  });

  if (_selectedRole == 'plumber') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlumberProfilePage()),
    );
  } else if (_selectedRole == 'electrition') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ElectricianProfilePage()),
    );
  } else if (_selectedRole == 'user') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserProfilePage()),
    );
  }
} // ✅ This closing brace was missing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Sign Up",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Name Field
            Text(
              "Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter your name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Email Field
            Text(
              "Email",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
            SizedBox(height: 10),

            // Password Field
            Text(
              "Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: "Enter your password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),

            // Confirm Password Field
            Text(
              "Confirm Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: "Confirm your password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),

            // Role Selection Dropdown
            Text(
              "Select Role",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'plumber', child: Text("Plumber")),
                DropdownMenuItem(value: 'electrition', child: Text("Electrition")),
                DropdownMenuItem(value: 'user', child: Text("User")),

              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              hint: Text("Select your role"),
            ),
            SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(_isLoading ? "Signing Up..." : "Sign Up"),
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Log-in",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  } 
