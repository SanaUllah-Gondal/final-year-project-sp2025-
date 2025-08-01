// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/profile.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final int _selectedIndex = 1; // Default to Settings

//   void _onItemTapped(int index) {
//     if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } else if (index == 1) {
//       // Already on Settings
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.cyan),
//       body: Center(
//         child: Text("Settings Screen", style: TextStyle(fontSize: 20)),
//       ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   currentIndex: _selectedIndex,
//       //   onTap: _onItemTapped,
//       //   selectedItemColor: Colors.cyan,
//       //   unselectedItemColor: Colors.grey,
//       //   items: const [
//       //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.settings),
//       //       label: 'Settings',
//       //     ),
//       //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//       //   ],
//       // ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:plumber_project/pages/users/dashboard.dart';
import 'package:plumber_project/pages/users/profile.dart';
import 'package:plumber_project/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int _selectedIndex = 1;
  bool _isDarkTheme = false;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.cyan),
      body: ListView(
        children: [
          ListTile(
            title: Text("Dark Theme"),
            trailing: Switch(
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                });
                MyApp.of(context)?.toggleTheme(value);
              },
              activeColor: Colors.cyan,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
