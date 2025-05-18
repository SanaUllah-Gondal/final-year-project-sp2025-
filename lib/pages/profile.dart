// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/login.dart';
// import 'package:plumber_project/pages/setting.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   final int _selectedIndex = 2;

//   void _onItemTapped(int index) {
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => EmergencyScreen()),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileScreen()),
//       );
//     } else if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Form is valid, proceed with saving or sending data
//       // ScaffoldMessenger.of(
//       //   context,
//       // ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
//        Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Profile"),
//         backgroundColor: Colors.cyan,
//         actions: [
//           Builder(
//             builder:
//                 (context) => IconButton(
//                   icon: Icon(Icons.menu),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//           ),
//         ],
//       ),
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.cyan),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.edit),
//               title: Text('Edit Profile'),
//               onTap: () {
//                 Navigator.pop(context); // Just close drawer here
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.settings),
//               title: Text('Setting'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SettingsScreen()));
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Logout'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Full Name'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   // Basic email pattern check
//                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                     return 'Enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(labelText: 'Phone Number'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
//                 child: Text('Save Profile'),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.cyan,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.emergency,
//               color: Colors.red, // 🔴 Always red
//             ),
//             label: "Emergency",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
//00000000000000000000000000000000000000000000000000000000000000000000000000000

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/login.dart';
// import 'package:plumber_project/pages/privacy.dart';
// import 'package:plumber_project/pages/setting.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Added import for SharedPreferences

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   final int _selectedIndex = 2;

//   String _userName = 'Loading...'; // name to be displayed

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData(); // Fetch name from API
//   }

//   Future<void> _fetchUserData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/api/profile/'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         // Assume API returns a list of users, and you're fetching the first one
//         final firstUser = data['id'];

//         if (!mounted) return; // ✅ Check if widget is still in the tree

//         setState(() {
//           _userName = firstUser['name'];
//           _nameController.text = firstUser['name'];
//           _emailController.text = firstUser['email'] ?? '';
//           _phoneController.text = firstUser['phone'] ?? '';
//         });
//       } else {
//         if (!mounted) return;

//         setState(() {
//           _userName = 'Failed to load user';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _userName = 'Error fetching user';
//       });
//     }
//   }

//   void _onItemTapped(int index) {
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => EmergencyScreen()),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileScreen()),
//       );
//     } else if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(" $_userName"),
//         backgroundColor: Colors.cyan,
//         actions: [
//           Builder(
//             builder:
//                 (context) => IconButton(
//                   icon: Icon(Icons.menu),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//           ),
//         ],
//       ),
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.cyan),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.edit),
//               title: Text('Edit Profile'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.settings),
//               title: Text('Setting'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SettingsScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.privacy_tip),
//               title: Text('Privacy & Terms'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => PrivacyTermsScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Logout'),
//               onTap: () async {
//                 // Clear local storage
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.remove('email');
//                 await prefs.remove('token');
//                 await prefs.setBool('remember_me', false); // Reset remember me

//                 // Navigate back to LoginScreen
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                   (Route<dynamic> route) =>
//                       false, // Removes all previous routes
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Full Name'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                     return 'Enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(labelText: 'Phone Number'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
//                 child: Text('Save Profile'),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.cyan,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.emergency, color: Colors.red),
//             label: "Emergency",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:plumber_project/pages/dashboard.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/login.dart';
import 'package:plumber_project/pages/notification.dart';
import 'package:plumber_project/pages/privacy.dart';
import 'package:plumber_project/pages/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final int _selectedIndex = 2;
  String _userName = 'Loading...';
  String _userRole = ''; // To store the user's role

  @override
  void initState() {
    super.initState();
    _loadUserDataFromPrefs();
  }

  Future<void> _loadUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _userName = prefs.getString('name') ?? 'Guest';
      _userRole = prefs.getString('role') ?? ''; // Load the role
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('phone', _phoneController.text);

      setState(() {
        _userName = _nameController.text;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 1 && _userRole != 'plumber' && _userRole != 'electrician') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergencyScreen()),
      );
    } else if (index == 1 &&
        (_userRole == 'plumber' || _userRole == 'electrician')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationsScreen(),
        ), // Replace Emergency with Notifications
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" $_userName"),
        backgroundColor: Colors.cyan,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy & Terms'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyTermsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('email');
                await prefs.remove('token');
                await prefs.remove('name');
                await prefs.remove('phone');
                await prefs.setBool('remember_me', false);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon:
                _userRole == 'plumber' || _userRole == 'electrician'
                    ? Icon(
                      Icons.notifications,
                      color: Colors.grey,
                    ) // Show Notifications for plumber/electrician
                    : Icon(
                      Icons.emergency,
                      color: Colors.red,
                    ), // Show Emergency for others
            label:
                _userRole == 'plumber' || _userRole == 'electrician'
                    ? "Notifications" // Update label accordingly
                    : "Emergency",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
