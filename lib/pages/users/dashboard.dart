
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/users/booking.dart';
import 'package:plumber_project/pages/userservice/electricianservice.dart';
import 'package:plumber_project/pages/userservice/plumberservice.dart';
import '../setting.dart';
import 'profile.dart';
import '../emergency.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String _userLocation = 'Fetching location...';
  List<String> savedLocations = [];
  String? selectedLocation;

  List<Map<String, dynamic>> services = [
    {"icon": Icons.tap_and_play, "title": "Plumber"},
    {"icon": Icons.electrical_services, "title": "Electrician"},
  ];

  List<Map<String, dynamic>> filteredServices = [];

  @override
  void initState() {
    super.initState();
    filteredServices = services;
    fetchUserLocation();
    loadSavedLocations();
  }

  Future<void> fetchUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');

    if (token == null) {
      setState(() => _userLocation = 'Not logged in');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = data['data'];
        if (profile != null && mounted) {
          setState(() {
            _userLocation = profile['location'] ?? 'Location not set';
            selectedLocation = _userLocation;
          });
        }
      } else {
        setState(() => _userLocation = 'Failed to load location');
      }
    } catch (e) {
      setState(() => _userLocation = 'Error loading location');
    }
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        filteredServices = services;
      }
    });
  }

  void _filterServices(String query) {
    setState(() {
      filteredServices = services
          .where((service) =>
              service["title"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onTabSelected(int index) {
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

  void _onServiceCardClicked(String serviceName) {
    if (serviceName.toLowerCase() == 'plumber') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlumberPage()),
      );
    } else if (serviceName.toLowerCase() == 'electrician') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ElectricianPage()),
      );
    }
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _showSearchBar
                ? AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Search services...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: _toggleSearchBar,
                        ),
                      ),
                      onChanged: _filterServices,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.search, color: Colors.cyan),
                    onPressed: _toggleSearchBar,
                    tooltip: 'Search Services',
                  ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                String imagePath = service["title"].toLowerCase() == "plumber"
                    ? "assets/images/pipe_background.jpeg"
                    : "assets/images/electric_background.jpeg";

                return GestureDetector(
                  onTap: () => _onServiceCardClicked(service["title"]),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        )
                      ],
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Icon(
                            service["icon"],
                            size: 40,
                            color: Colors.yellow,
                          ),
                          SizedBox(width: 20),
                          Text(
                            service["title"],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateUserLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({"location": location}),
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _userLocation = location;
        });
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLocations = prefs.getStringList('saved_locations') ?? [];
    setState(() {
      savedLocations = storedLocations;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: tealBlue,
        title: Row(
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.room_service, color: Colors.black, size: 28),
              onSelected: (value) {
                if (value == 'booking-request') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestScreen()),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'booking-request',
                  child: Row(
                    children: [
                      Icon(Icons.request_page, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Booking Request'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            Text(
              "Skill-Link",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _buildHomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: tealBlue,
        backgroundColor: Colors.blue,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency, color: Colors.red),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
