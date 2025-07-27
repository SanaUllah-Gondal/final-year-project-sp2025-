<<<<<<< HEAD
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
import 'package:plumber_project/pages/dashboard.dart';
import 'package:plumber_project/pages/profile.dart';
import 'package:plumber_project/main.dart';
=======
import 'package:flutter/material.dart';
import 'package:plumber_project/pages/dashboard.dart';
import 'package:plumber_project/pages/profile.dart';
>>>>>>> 762f597040fe8b802e8b7d610046465852ef0654

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
<<<<<<< HEAD
  final int _selectedIndex = 1;
  bool _isDarkTheme = false;
=======
  final int _selectedIndex = 1; // Default to Settings
>>>>>>> 762f597040fe8b802e8b7d610046465852ef0654

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
<<<<<<< HEAD
=======
    } else if (index == 1) {
      // Already on Settings
>>>>>>> 762f597040fe8b802e8b7d610046465852ef0654
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
<<<<<<< HEAD
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
=======
      body: Center(
        child: Text("Settings Screen", style: TextStyle(fontSize: 20)),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: Colors.cyan,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      //   ],
      // ),
>>>>>>> 762f597040fe8b802e8b7d610046465852ef0654
    );
  }
}
