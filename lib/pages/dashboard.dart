// import 'package:flutter/material.dart';
// import 'service.dart';
// import 'setting.dart'; // Import Settings Screen
// import 'profile.dart'; // Import Profile Screen
// import 'package:google_fonts/google_fonts.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpeenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//   ];
//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//   }

//   void _toggleSearchBar() {
//     setState(() {
//       _showSearchBar = !_showSearchBar;
//       if (!_showSearchBar) {
//         _searchController.clear();
//         filteredServices = services;
//       }
//     });
//   }

//   void _filterServices(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredServices = services;
//       } else {
//         filteredServices =
//             services
//                 .where(
//                   (service) => service["title"].toLowerCase().contains(
//                     query.toLowerCase(),
//                   ),
//                 )
//                 .toList();
//       }
//     });
//   }

//   void _onTabSelected(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   Widget _getScreen() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeScreen();
//       case 1:
//         return SettingsScreen(); // Settings screen
//       case 2:
//         return ProfileScreen(); // Profile screen
//       default:
//         return _buildHomeScreen();
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return ServiceCard(
//                   icon: filteredServices[index]["icon"],
//                   title: filteredServices[index]["title"],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             _showSearchBar
//                 ? AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   width: MediaQuery.of(context).size.width * 0.7,
//                   child: TextField(
//                     controller: _searchController,
//                     autofocus: true,
//                     decoration: InputDecoration(
//                       hintText: "Search services...",
//                       border: InputBorder.none,
//                     ),
//                     onChanged: _filterServices,
//                   ),
//                 )
//                 : Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.room_service,
//                       color: Colors.black,
//                       size: 37, // Increased icon size
//                     ), // Icon before text
//                     SizedBox(width: 8), // Space between icon and text
//                     Text(
//                       "Haazir",
//                       style: GoogleFonts.poppins(
//                         // ✅ Use a valid Google Font
//                         fontSize: 28, // Adjust font size
//                         fontWeight: FontWeight.bold, // Make text bold
//                         color: Colors.cyan, // Change text color
//                         letterSpacing: 0.5, // Add spacing between letters
//                       ),
//                     ),
//                   ],
//                 ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.cyan,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _showSearchBar ? Icons.close : Icons.search,
//               color: Colors.black,
//             ),
//             onPressed: _toggleSearchBar,
//           ),
//         ],
//       ),
//       body: _getScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Settings",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'service.dart';
import 'setting.dart';
import 'profile.dart';
import 'emergency.dart'; // ✅ Import the emergency screen
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  List<Map<String, dynamic>> services = [
    {"icon": Icons.tap_and_play, "title": "Plumber"},
    {"icon": Icons.construction, "title": "Labor"},
    {"icon": Icons.electrical_services, "title": "Electrician"},
    {"icon": Icons.kitchen, "title": "Appliances"},
    {"icon": Icons.videocam, "title": "CCTV"},
    {"icon": Icons.format_paint, "title": "Painting"},
    {"icon": Icons.carpenter, "title": "Carpenter"},
    {"icon": Icons.bug_report, "title": "Pest Control"},
    {"icon": Icons.girl, "title": "Wall Panelling"},
    {"icon": Icons.wallpaper, "title": "Wall Panelling"},
  ];
  List<Map<String, dynamic>> filteredServices = [];

  @override
  void initState() {
    super.initState();
    filteredServices = services;
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
      if (query.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices =
            services
                .where(
                  (service) => service["title"].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _onTabSelected(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmergencyScreen(),
        ), // ✅ Navigate to Emergency
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(serviceName),
          content: Text('You clicked on the $serviceName service.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 2:
        return ProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: filteredServices.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap:
                      () => _onServiceCardClicked(
                        filteredServices[index]["title"],
                      ),
                  child: ServiceCard(
                    icon: filteredServices[index]["icon"],
                    title: filteredServices[index]["title"],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            _showSearchBar
                ? AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search services...",
                      border: InputBorder.none,
                    ),
                    onChanged: _filterServices,
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.room_service, color: Colors.black, size: 37),
                    SizedBox(width: 8),
                    Text(
                      "Handy-Hive",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.cyan,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showSearchBar ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body: _getScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.emergency,
              color: Colors.red, // 🔴 Always red
            ),
            label: "Emergency",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
