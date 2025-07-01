// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/electrition_cards.dart';
// import 'package:plumber_project/pages/profile.dart';

// class ElectricianDashboard extends StatefulWidget {
//   @override
//   _ElectricianDashboardState createState() => _ElectricianDashboardState();
// }

// class _ElectricianDashboardState extends State<ElectricianDashboard> {
//   int _selectedIndex = 0;
//   String _userRole = '';

//   final List<Widget> _pages = [
//     HomeContent(),
//     Center(child: Text('Emergency Alerts', style: TextStyle(fontSize: 20))),
//     Center(child: Text('Profile Page', style: TextStyle(fontSize: 20))),
//   ];

//   void _onItemTapped(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               child: Text(
//                 "Welcome, Electrician!",
//                 style: TextStyle(color: Colors.white, fontSize: 20),
//               ),
//               decoration: BoxDecoration(color: Colors.indigo),
//             ),
//             ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard")),
//             ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
//             ListTile(leading: Icon(Icons.logout), title: Text("Logout")),
//           ],
//         ),
//       ),
//       appBar: AppBar(title: Text("Electrician Dashboard")),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.indigo,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.warning),
//             label: 'Emergency',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }

// class HomeContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: GridView.count(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         children: [
//           DashboardCard(
//             title: "New Jobs",
//             icon: Icons.assignment,
//             color: Colors.orange,
//           ),
//           DashboardCard(
//             title: "Ongoing Work",
//             icon: Icons.electrical_services,
//             color: Colors.blue,
//           ),
//           DashboardCard(
//             title: "Completed Tasks",
//             icon: Icons.check_circle,
//             color: Colors.green,
//           ),
//           DashboardCard(
//             title: "Earnings",
//             icon: Icons.attach_money,
//             color: Colors.purple,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:plumber_project/pages/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/electrition_cards.dart';
import 'package:plumber_project/pages/profile.dart';

class ElectricianDashboard extends StatefulWidget {
  @override
  _ElectricianDashboardState createState() => _ElectricianDashboardState();
}

class _ElectricianDashboardState extends State<ElectricianDashboard> {
  int _selectedIndex = 0;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? ''; // e.g., 'electrician'
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      if (_userRole == 'plumber' || _userRole == 'electrician') {
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
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                "Welcome, ${_userRole.isNotEmpty ? _userRole[0].toUpperCase() + _userRole.substring(1) : "User"}!",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              decoration: BoxDecoration(color: Colors.indigo),
            ),
            ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard")),
            ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
            ListTile(leading: Icon(Icons.logout), title: Text("Logout")),
          ],
        ),
      ),
      appBar: AppBar(title: Text("Electrician Dashboard")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  final List<Widget> _pages = [
    HomeContent(),
    Center(child: Text('Emergency Alerts', style: TextStyle(fontSize: 20))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 20))),
  ];
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          DashboardCard(
            title: "New Jobs",
            icon: Icons.assignment,
            color: Colors.orange,
          ),
          DashboardCard(
            title: "Ongoing Work",
            icon: Icons.electrical_services,
            color: Colors.blue,
          ),
          DashboardCard(
            title: "Completed Tasks",
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          DashboardCard(
            title: "Earnings",
            icon: Icons.attach_money,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
