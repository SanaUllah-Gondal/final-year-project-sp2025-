// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/dashboard.dart'; // HomeScreen
// import 'package:plumber_project/pages/electrition_dashboard.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/login.dart';
// import 'package:plumber_project/pages/notification.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:plumber_project/pages/privacy.dart';
// import 'package:plumber_project/pages/setting.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Dummy dashboards based on role
// // class PlumberDashboard extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Plumber Dashboard")),
// //       body: Center(child: Text("Welcome, Plumber")),
// //     );
// //   }
// // }

// // class ElectricianDashboard extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Electrician Dashboard")),
// //       body: Center(child: Text("Welcome, Electrician")),
// //     );
// //   }
// // }

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
//   String _userName = 'Loading...';
//   String _userRole = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadUserDataFromPrefs();
//   }

//   Future<void> _loadUserDataFromPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     if (!mounted) return;

//     setState(() {
//       _userName = prefs.getString('name') ?? 'Guest';
//       _userRole = prefs.getString('role') ?? '';
//       _nameController.text = prefs.getString('name') ?? '';
//       _emailController.text = prefs.getString('email') ?? '';
//       _phoneController.text = prefs.getString('phone') ?? '';
//     });
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('name', _nameController.text);
//       await prefs.setString('email', _emailController.text);
//       await prefs.setString('phone', _phoneController.text);

//       setState(() {
//         _userName = _nameController.text;
//       });

//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }

//   void _onItemTapped(int index) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? role = prefs.getString('role') ?? '';

//     if (index == 1) {
//       if (role == 'plumber' || role == 'electrician') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => NotificationsScreen()),
//         );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => EmergencyScreen()),
//         );
//       }
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileScreen()),
//       );
//     } else if (index == 0) {
//       Widget homePage;
//       switch (role) {
//         case 'plumber':
//           homePage = PlumberDashboard();
//           break;
//         case 'electrician':
//           homePage = ElectricianDashboard();
//           break;
//         default:
//           homePage = HomeScreen(); // fallback
//       }

//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => homePage),
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
//             builder: (context) => IconButton(
//               icon: Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openEndDrawer();
//               },
//             ),
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
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.remove('email');
//                 await prefs.remove('token');
//                 await prefs.remove('name');
//                 await prefs.remove('phone');
//                 await prefs.setBool('remember_me', false);

//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                   (Route<dynamic> route) => false,
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
//             icon: _userRole == 'plumber' || _userRole == 'electrician'
//                 ? Icon(Icons.notifications, color: Colors.grey)
//                 : Icon(Icons.emergency, color: Colors.red),
//             label: _userRole == 'plumber' || _userRole == 'electrician'
//                 ? "Notifications"
//                 : "Emergency",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:plumber_project/pages/dashboard.dart'; // HomeScreen
import 'package:plumber_project/pages/electrition_dashboard.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/login.dart';
import 'package:plumber_project/pages/notification.dart';
import 'package:plumber_project/pages/plumber_dashboard.dart';
import 'package:plumber_project/pages/privacy.dart';
import 'package:plumber_project/pages/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

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
  String _userRole = '';

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
      _userRole = prefs.getString('role') ?? '';
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

  void _onItemTapped(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role') ?? '';

    if (index == 1) {
      if (role == 'plumber' || role == 'electrician') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyScreen()),
        );
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else if (index == 0) {
      Widget homePage;
      switch (role) {
        case 'plumber':
          homePage = PlumberDashboard();
          break;
        case 'electrician':
          homePage = ElectricianDashboard();
          break;
        default:
          homePage = HomeScreen();
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => homePage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text(
          _userRole.isNotEmpty
              ? _userRole[0].toUpperCase() + _userRole.substring(1)
              : 'Role',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: tealBlue,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: tealBlue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () => Navigator.pop(context),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealBlue,
                  foregroundColor: Colors.black,
                ),
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: tealBlue,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: _userRole == 'plumber' || _userRole == 'electrician'
                ? Icon(Icons.notifications)
                : Icon(Icons.emergency, color: Colors.red),
            label: _userRole == 'plumber' || _userRole == 'electrician'
                ? "Notifications"
                : "Emergency",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
