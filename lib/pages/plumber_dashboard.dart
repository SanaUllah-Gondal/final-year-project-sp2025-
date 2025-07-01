// is code may sirf background color change hai
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/plumber/plumberrequest.dart';
// import 'package:plumber_project/pages/plumber_dashboard_card.dart';
// import 'package:plumber_project/pages/profile.dart';
// import 'package:plumber_project/pages/notification.dart'; // Make sure this exists

// class PlumberDashboard extends StatefulWidget {
//   @override
//   _PlumberDashboardState createState() => _PlumberDashboardState();
// }

// class _PlumberDashboardState extends State<PlumberDashboard> {
//   int _selectedIndex = 0;
//   String _userRole = '';

//   final List<Widget> _pages = [
//     HomeContent(),
//     Center(child: Text('Notifications Page', style: TextStyle(fontSize: 20))),
//     Center(child: Text('Profile Page', style: TextStyle(fontSize: 20))),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserRole();
//   }

//   Future<void> _loadUserRole() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _userRole = prefs.getString('role') ?? '';
//     });
//   }

//   void _onItemTapped(int index) {
//     if (index == 1) {
//       if (_userRole == 'plumber' || _userRole == 'electrician') {
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
//       // drawer: Drawer(
//       //   child: ListView(
//       //     children: [
//       //       DrawerHeader(
//       //         child: Text("Welcome", style: TextStyle(color: Colors.white)),
//       //         decoration: BoxDecoration(color: Colors.blue),
//       //       ),
//       //       ListTile(
//       //         leading: Icon(Icons.home),
//       //         title: Text("Dashboard"),
//       //         onTap: () {
//       //           Navigator.pop(context); // Close drawer
//       //         },
//       //       ),
//       //       ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
//       //       ListTile(
//       //         leading: Icon(Icons.logout),
//       //         title: Text("Logout"),
//       //         onTap: () async {
//       //           SharedPreferences prefs = await SharedPreferences.getInstance();
//       //           await prefs.clear();
//       //           Navigator.pushReplacementNamed(context, '/login');
//       //         },
//       //       ),
//       //     ],
//       //   ),
//       // ),
//       appBar: AppBar(
//         title: const Text(
//           'Skill-Link',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 28,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.transparent, // ✅ Transparent for gradient
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),

//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.blue,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.notifications), label: 'Notifications'),
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
//             title: "New Requests",
//             icon: Icons.assignment,
//             color: Colors.orange,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AppointmentList()),
//               );
//             },
//           ),
//           DashboardCard(
//             title: "Ongoing Jobs",
//             icon: Icons.work,
//             color: Colors.blue,
//           ),
//           DashboardCard(
//             title: "Completed Jobs",
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/plumber/plumberrequest.dart';
import 'package:plumber_project/pages/plumber_dashboard_card.dart';
import 'package:plumber_project/pages/profile.dart';
import 'package:plumber_project/pages/notification.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class PlumberDashboard extends StatefulWidget {
  @override
  _PlumberDashboardState createState() => _PlumberDashboardState();
}

class _PlumberDashboardState extends State<PlumberDashboard> {
  int _selectedIndex = 0;
  String _userRole = '';

  final List<Widget> _pages = [
    HomeContent(),
    Center(
        child: Text('Notifications Page',
            style: TextStyle(fontSize: 20, color: Colors.white))),
    Center(
        child: Text('Profile Page',
            style: TextStyle(fontSize: 20, color: Colors.white))),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? '';
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
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text(
          'Skill-Link',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        backgroundColor: tealBlue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
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
            title: "New Requests",
            icon: Icons.assignment,
            gradientColors: [Color(0xFFF7971E), Color(0xFFFFD200)],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentList()),
              );
            },
          ),
          DashboardCard(
            title: "Ongoing Jobs",
            icon: Icons.work,
            gradientColors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
          ),
          DashboardCard(
            title: "Completed Jobs",
            icon: Icons.check_circle,
            gradientColors: [Color(0xFF00b09b), Color(0xFF96c93d)],
          ),
          DashboardCard(
            title: "Earnings",
            icon: Icons.attach_money,
            gradientColors: [Color(0xFFF953C6), Color(0xFFB91D73)],
          ),
        ],
      ),
    );
  }
}
