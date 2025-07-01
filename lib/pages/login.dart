// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/electrition_dashboard.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:plumber_project/pages/electrition_profile.dart';
// import 'package:plumber_project/pages/user_profile.dart';
// import 'package:plumber_project/pages/plumber_profile.dart';
// import 'signup_screen.dart';
// import 'Apis.dart'; // Make sure baseUrl is defined here

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool remember = prefs.getBool('remember_me') ?? false;
//     if (remember) {
//       String? savedEmail = prefs.getString('email');
//       setState(() {
//         _rememberMe = true;
//         _emailController.text = savedEmail ?? '';
//       });
//     }
//   }

//   Future<void> _handleLogin() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showAlert('Error', 'Please enter both email and password.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data.containsKey('access_token')) {
//         final String bearerToken = data['access_token'];
//         final Map<String, dynamic> user = data['user'];
//         final String role = user['role'];
//         final int userId = user['id'];

//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('bearer_token', bearerToken);
//         await prefs.setInt('user_id', userId);
//         await prefs.setString('role', role);
//         await prefs.setString('name', user['name']);
//         await prefs.setString('email', user['email']);
//         await prefs.setBool('remember_me', _rememberMe);

//         debugPrint('🔐 Bearer Token saved: $bearerToken');
//         debugPrint('👤 User ID: $userId');

//         bool hasProfile = await _checkUserProfile(userId, bearerToken);

//         Widget destinationPage;
//         if (role == 'plumber') {
//           destinationPage =
//               hasProfile ? PlumberDashboard() : PlumberProfilePage();
//         } else if (role == 'electrician') {
//           destinationPage =
//               hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
//         } else {
//           destinationPage = hasProfile ? HomeScreen() : UserProfilePage();
//         }

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => destinationPage),
//         );
//       } else {
//         _showAlert('Login Error', data['message'] ?? 'Invalid credentials.');
//       }
//     } catch (e) {
//       _showAlert('Login Error', 'Failed to connect to the server.');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<bool> _checkUserProfile(int userId, String token) async {
//     try {
//       String url = '$baseUrl/api/check-profile/$userId';

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['profile_exists'] == true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Skill-Link',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 28,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.grey[200],
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: Colors.grey[200],
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 60),
//               const Icon(Icons.lock, size: 80, color: Colors.black),
//               const SizedBox(height: 20),
//               const Text("Email",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter your email",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 10),
//               const Text("Password",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter your password",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 10),
//               CheckboxListTile(
//                 value: _rememberMe,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _rememberMe = value ?? false;
//                   });
//                 },
//                 title: const Text("Remember Me"),
//                 controlAffinity: ListTileControlAffinity.leading,
//                 contentPadding: EdgeInsets.zero,
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _handleLogin,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 child: Text(_isLoading ? "Logging in..." : "Login"),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account?"),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SignUpScreen()),
//                       );
//                     },
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//0000000000000000000000000000000000000000000000 yai sirf purrany user pr shi chla raha hai
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/electrition_dashboard.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:plumber_project/pages/electrition_profile.dart';
// import 'package:plumber_project/pages/user_profile.dart';
// import 'package:plumber_project/pages/plumber_profile.dart';
// import 'signup_screen.dart';
// import 'Apis.dart'; // Make sure baseUrl is defined here

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool remember = prefs.getBool('remember_me') ?? false;
//     if (remember) {
//       String? savedEmail = prefs.getString('email');
//       setState(() {
//         _rememberMe = true;
//         _emailController.text = savedEmail ?? '';
//       });
//     }
//   }

//   // Future<void> _handleLogin() async {
//   //   String email = _emailController.text.trim();
//   //   String password = _passwordController.text.trim();

//   //   if (email.isEmpty || password.isEmpty) {
//   //     _showAlert('Error', 'Please enter both email and password.');
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse('$baseUrl/api/login'),
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: jsonEncode({'email': email, 'password': password}),
//   //     );

//   //     final data = jsonDecode(response.body);

//   //     if (response.statusCode == 200 && data.containsKey('access_token')) {
//   //       final String bearerToken = data['access_token'];
//   //       final Map<String, dynamic> user = data['user'];
//   //       final String role = user['role'];
//   //       final int userId = user['id'];

//   //       SharedPreferences prefs = await SharedPreferences.getInstance();

//   //       // ✅ Save common info for all users
//   //       await prefs.setString('bearer_token', bearerToken);
//   //       await prefs.setInt('user_id', userId);
//   //       await prefs.setString('role', role);
//   //       await prefs.setString('name', user['name']);
//   //       await prefs.setString('email', user['email']);
//   //       await prefs.setBool('remember_me', _rememberMe);

//   //       // ✅ Save role-specific info (plumber_id)
//   //       if (role == 'plumber') {
//   //         await prefs.setInt('plumber_id', userId);
//   //       }

//   //       debugPrint('✅ Login success');
//   //       debugPrint('🪪 User ID: $userId');
//   //       debugPrint('🎭 Role: $role');
//   //       debugPrint('🔐 Token: $bearerToken');

//   //       // ✅ Check if user has completed profile
//   //       bool hasProfile = await _checkUserProfile(userId, bearerToken);

//   //       Widget destinationPage;
//   //       if (role == 'plumber') {
//   //         destinationPage =
//   //             hasProfile ? PlumberDashboard() : PlumberProfilePage();
//   //       } else if (role == 'electrician') {
//   //         destinationPage =
//   //             hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
//   //       } else {
//   //         destinationPage = hasProfile ? HomeScreen() : UserProfilePage();
//   //       }

//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => destinationPage),
//   //       );
//   //     } else {
//   //       _showAlert('Login Error', data['message'] ?? 'Invalid credentials.');
//   //     }
//   //   } catch (e) {
//   //     _showAlert('Login Error', 'Failed to connect to the server.');
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> _handleLogin() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showAlert('Error', 'Please enter both email and password.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Step 1: Call login API
//       final loginResponse = await http.post(
//         Uri.parse('$baseUrl/api/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       final loginData = jsonDecode(loginResponse.body);

//       if (loginResponse.statusCode == 200 &&
//           loginData.containsKey('access_token')) {
//         final String bearerToken = loginData['access_token'];
//         final Map<String, dynamic> user = loginData['user'];
//         final String role = user['role'];
//         final int userId = user['id'];

//         SharedPreferences prefs = await SharedPreferences.getInstance();

//         // Save basic user info
//         await prefs.setString('bearer_token', bearerToken);
//         await prefs.setInt('user_id', userId);
//         await prefs.setString('role', role);
//         await prefs.setString('name', user['name']);
//         await prefs.setString('email', user['email']);
//         await prefs.setBool('remember_me', _rememberMe);

//         // Step 2: Fetch profile info using API
//         final profileResponse = await http.get(
//           Uri.parse('$baseUrl/api/check-profile/$userId'),
//           headers: {
//             'Authorization': 'Bearer $bearerToken',
//             'Accept': 'application/json',
//           },
//         );

//         if (profileResponse.statusCode == 200) {
//           final profileData = jsonDecode(profileResponse.body);

//           if (profileData['success'] == true) {
//             final profile = profileData['profile'];

//             // Save profile id based on role, if exists
//             if (role == 'plumber' && profile['plumber_profile'] != null) {
//               await prefs.setInt(
//                   'plumber_profile_id', profile['plumber_profile']['id']);
//             } else if (role == 'electrician' &&
//                 profile['electrician_profile'] != null) {
//               await prefs.setInt('electrician_profile_id',
//                   profile['electrician_profile']['id']);
//             } else if (role == 'user' && profile['user_profile'] != null) {
//               await prefs.setInt(
//                   'user_profile_id', profile['user_profile']['id']);
//             }

//             // You can also store the whole profile json string if you want
//             await prefs.setString('profile_data', jsonEncode(profile));
//           } else {
//             debugPrint('Profile fetch failed: ${profileData['message']}');
//           }
//         } else {
//           debugPrint(
//               'Failed to fetch profile info: ${profileResponse.statusCode}');
//         }

//         // Debug: print all saved SharedPreferences keys and values
//         Map<String, Object> allPrefs = {};
//         prefs.getKeys().forEach((key) {
//           allPrefs[key] = prefs.get(key) ?? 'null';
//         });
//         debugPrint('--- Shared Preferences Stored Data ---');
//         allPrefs.forEach((key, value) {
//           debugPrint('$key : $value');
//         });

//         // Step 3: Decide if profile exists to navigate
//         bool hasProfile = false;
//         if (role == 'plumber') {
//           hasProfile = prefs.containsKey('plumber_profile_id');
//         } else if (role == 'electrician') {
//           hasProfile = prefs.containsKey('electrician_profile_id');
//         } else if (role == 'user') {
//           hasProfile = prefs.containsKey('user_profile_id');
//         }

//         Widget destinationPage;
//         if (role == 'plumber') {
//           destinationPage =
//               hasProfile ? PlumberDashboard() : PlumberProfilePage();
//         } else if (role == 'electrician') {
//           destinationPage =
//               hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
//         } else {
//           destinationPage = hasProfile ? HomeScreen() : UserProfilePage();
//         }

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => destinationPage),
//         );
//       } else {
//         _showAlert(
//             'Login Error', loginData['message'] ?? 'Invalid credentials.');
//       }
//     } catch (e) {
//       debugPrint('Exception during login: $e');
//       _showAlert('Login Error', 'Failed to connect to the server.');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<bool> _checkUserProfile(int userId, String token) async {
//     try {
//       String url = '$baseUrl/api/check-profile/$userId';

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['profile_exists'] == true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Skill-Link',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 28,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.grey[200],
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: Colors.grey[200],
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 60),
//               const Icon(Icons.lock, size: 80, color: Colors.black),
//               const SizedBox(height: 20),
//               const Text("Email",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter your email",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 10),
//               const Text("Password",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter your password",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 10),
//               CheckboxListTile(
//                 value: _rememberMe,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _rememberMe = value ?? false;
//                   });
//                 },
//                 title: const Text("Remember Me"),
//                 controlAffinity: ListTileControlAffinity.leading,
//                 contentPadding: EdgeInsets.zero,
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _handleLogin,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 child: Text(_isLoading ? "Logging in..." : "Login"),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account?"),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SignUpScreen()),
//                       );
//                     },
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/electrition_dashboard.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:plumber_project/pages/electrition_profile.dart';
// import 'package:plumber_project/pages/user_profile.dart';
// import 'package:plumber_project/pages/plumber_profile.dart';
// import 'signup_screen.dart';
// import 'Apis.dart'; // Make sure baseUrl is defined here

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool remember = prefs.getBool('remember_me') ?? false;
//     if (remember) {
//       String? savedEmail = prefs.getString('email');
//       setState(() {
//         _rememberMe = true;
//         _emailController.text = savedEmail ?? '';
//       });
//     }
//   }

//   Future<void> _handleLogin() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showAlert('Error', 'Please enter both email and password.');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Step 1: Login API Call
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['access_token'] != null) {
//         final prefs = await SharedPreferences.getInstance();

//         final String token = data['access_token'];
//         final Map<String, dynamic> user = data['user'];
//         final String role = user['role'];
//         final int userId = user['id'];

//         // Save login data
//         await prefs.setString('bearer_token', token);
//         await prefs.setString('role', role);
//         await prefs.setInt('user_id', userId);
//         await prefs.setString('name', user['name']);
//         await prefs.setString('email', user['email']);
//         await prefs.setBool('remember_me', _rememberMe);

//         print('bearer_token');
//         print('role');
//         print('user_id');
//         print('name');
//         print('email');

//         // Step 2: Check profile by role
//         final profileResponse = await http.get(
//           Uri.parse('$baseUrl/api/check-profile/$userId'),
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Accept': 'application/json',
//           },
//         );

//         bool hasProfile = false;
//         final profileData = jsonDecode(profileResponse.body);

//         if (profileData['success'] == true && profileData['profile'] != null) {
//           final profile = profileData['profile'];

//           if (role == 'plumber' && profile['plumber_profile'] != null) {
//             hasProfile = true;
//             await prefs.setInt(
//                 'plumber_profile_id', profile['plumber_profile']['id']);
//           } else if (role == 'electrician' &&
//               profile['electrician_profile'] != null) {
//             hasProfile = true;
//             await prefs.setInt(
//                 'electrician_profile_id', profile['electrician_profile']['id']);
//           } else if (role == 'user' && profile['user_profile'] != null) {
//             hasProfile = true;
//             await prefs.setInt(
//                 'user_profile_id', profile['user_profile']['id']);
//           }

//           await prefs.setString('profile_data', jsonEncode(profile));
//         } else {
//           debugPrint('🔍 No profile found for this user.');
//         }

//         // Step 4: Navigate to role-based destination
//         Widget destinationPage;
//         if (role == 'plumber') {
//           destinationPage =
//               hasProfile ? PlumberDashboard() : PlumberProfilePage();
//         } else if (role == 'electrician') {
//           destinationPage =
//               hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
//         } else {
//           destinationPage = hasProfile ? HomeScreen() : UserProfilePage();
//         }

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => destinationPage),
//         );
//       } else {
//         _showAlert('Login Error', data['message'] ?? 'Invalid credentials.');
//       }
//     } catch (e) {
//       debugPrint('❌ Login Exception: $e');
//       _showAlert('Login Error', 'Could not connect to the server.');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<bool> _checkUserProfile(int userId, String token) async {
//     try {
//       String url = '$baseUrl/api/check-profile/$userId';

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['profile_exists'] == true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Skill-Link',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 28,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.grey[200],
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       backgroundColor: Colors.grey[200],
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 60),
//               const Icon(Icons.lock, size: 80, color: Colors.black),
//               const SizedBox(height: 20),
//               const Text("Email",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter your email",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 10),
//               const Text("Password",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter your password",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 10),
//               CheckboxListTile(
//                 value: _rememberMe,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _rememberMe = value ?? false;
//                   });
//                 },
//                 title: const Text("Remember Me"),
//                 controlAffinity: ListTileControlAffinity.leading,
//                 contentPadding: EdgeInsets.zero,
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _handleLogin,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 child: Text(_isLoading ? "Logging in..." : "Login"),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account?"),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SignUpScreen()),
//                       );
//                     },
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      String? savedEmail = prefs.getString('email');
      setState(() {
        _rememberMe = true;
        _emailController.text = savedEmail ?? '';
      });
    }
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlert('Error', 'Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();

        final String token = data['access_token'];
        final Map<String, dynamic> user = data['user'];
        final String role = user['role'];
        final int userId = user['id'];

        await prefs.setString('bearer_token', token);
        await prefs.setString('role', role);
        await prefs.setInt('user_id', userId);
        await prefs.setString('name', user['name']);
        await prefs.setString('email', user['email']);
        await prefs.setBool('remember_me', _rememberMe);

        final profileResponse = await http.get(
          Uri.parse('$baseUrl/api/check-profile/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        bool hasProfile = false;
        final profileData = jsonDecode(profileResponse.body);

        if (profileData['success'] == true && profileData['profile'] != null) {
          final profile = profileData['profile'];

          if (role == 'plumber' && profile['plumber_profile'] != null) {
            hasProfile = true;
            await prefs.setInt(
                'plumber_profile_id', profile['plumber_profile']['id']);
          } else if (role == 'electrician' &&
              profile['electrician_profile'] != null) {
            hasProfile = true;
            await prefs.setInt(
                'electrician_profile_id', profile['electrician_profile']['id']);
          } else if (role == 'user' && profile['user_profile'] != null) {
            hasProfile = true;
            await prefs.setInt(
                'user_profile_id', profile['user_profile']['id']);
          }

          await prefs.setString('profile_data', jsonEncode(profile));
        }

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
      } else {
        _showAlert('Login Error', data['message'] ?? 'Invalid credentials.');
      }
    } catch (e) {
      debugPrint('❌ Login Exception: $e');
      _showAlert('Login Error', 'Could not connect to the server.');
    } finally {
      setState(() => _isLoading = false);
    }
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Allows background behind AppBar
      appBar: AppBar(
        title: const Text(
          'Skill-Link',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent, // ✅ Transparent for gradient
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // ✅ Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBlue, tealBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // ✅ Main content
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
                      backgroundColor: const Color(0xFFFFCD00), // Yellow
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
