import 'package:flutter/material.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/plumber/plumberrequest.dart';
import 'package:plumber_project/pages/plumber_dashboard_card.dart';
import 'package:plumber_project/pages/profile.dart';

class PlumberDashboard extends StatefulWidget {
  @override
  _PlumberDashboardState createState() => _PlumberDashboardState();
}

class _PlumberDashboardState extends State<PlumberDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    Center(child: Text('Notifications Page', style: TextStyle(fontSize: 20))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergencyScreen()),
      );
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
              child: Text("Welcome", style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(leading: Icon(Icons.home), title: Text("Dashboard")),
            ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
            ListTile(leading: Icon(Icons.logout), title: Text("Logout")),
          ],
        ),
      ),
      appBar: AppBar(title: Text("Plumber Dashboard")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
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
            color: Colors.orange,
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
            color: Colors.blue,
          ),
          DashboardCard(
            title: "Completed Jobs",
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
