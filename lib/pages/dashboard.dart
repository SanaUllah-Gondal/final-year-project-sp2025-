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

//0000000000000000000000000000000000000000000000000000000000 this program show me the details
// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart'; // ✅ Import the emergency screen
// import 'package:google_fonts/google_fonts.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
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
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => EmergencyScreen(),
//         ), // ✅ Navigate to Emergency
//       );
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

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   Widget _getScreen() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeScreen();
//       case 2:
//         return ProfileScreen();
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
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap:
//                       () => _onServiceCardClicked(
//                         filteredServices[index]["title"],
//                       ),
//                   child: ServiceCard(
//                     icon: filteredServices[index]["icon"],
//                     title: filteredServices[index]["title"],
//                   ),
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
//         automaticallyImplyLeading: false,
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
//                     Icon(Icons.room_service, color: Colors.black, size: 37),
//                     SizedBox(width: 8),
//                     Text(
//                       "Skill-Link",
//                       style: GoogleFonts.poppins(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.cyan,
//                         letterSpacing: 0.5,
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

// 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000 this code show me the location and add the new location
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;
//   String _userLocation = 'Fetching location...';
//   List<String> savedLocations = [];
//   String? selectedLocation;

//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
//   ];
//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//     fetchUserLocation();
//   }

//   Future<void> fetchUserLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) {
//       setState(() => _userLocation = 'Not logged in');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final profiles = data['data'];

//         final userProfile = profiles.firstWhere(
//           (profile) => profile['role'] == 'user',
//           orElse: () => null,
//         );

//         if (userProfile != null && mounted) {
//           setState(() {
//             _userLocation = userProfile['location'] ?? 'Location not set';
//             selectedLocation = _userLocation;
//           });
//         } else {
//           setState(() => _userLocation = 'Location not found');
//         }
//       } else {
//         setState(() => _userLocation = 'Failed to load location');
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       setState(() => _userLocation = 'Error loading location');
//     }
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
//       filteredServices = services
//           .where((service) =>
//               service["title"].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _onTabSelected(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('OK'))
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _showLocationBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setStateSheet) {
//           List<String> allLocations = [_userLocation, ...savedLocations];

//           return Padding(
//             padding: MediaQuery.of(context).viewInsets,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   title: Text("Select a Location"),
//                 ),
//                 ...allLocations.map((location) {
//                   return RadioListTile<String>(
//                     title: Text(location),
//                     value: location,
//                     groupValue: selectedLocation,
//                     onChanged: (value) {
//                       setStateSheet(() {
//                         selectedLocation = value!;
//                       });
//                       Navigator.pop(context);
//                       updateUserLocation(value!);
//                     },
//                   );
//                 }).toList(),
//                 ElevatedButton(
//                   onPressed: () {
//                     _cityController.clear();
//                     _streetController.clear();
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           title: Text('Add New Location'),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               TextField(
//                                 controller: _cityController,
//                                 decoration: InputDecoration(labelText: 'City'),
//                               ),
//                               TextField(
//                                 controller: _streetController,
//                                 decoration:
//                                     InputDecoration(labelText: 'Street No'),
//                               ),
//                             ],
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context),
//                               child: Text('Cancel'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () {
//                                 final newLocation =
//                                     '${_streetController.text}, ${_cityController.text}';
//                                 if (newLocation.isNotEmpty) {
//                                   setStateSheet(() {
//                                     savedLocations.add(newLocation);
//                                     selectedLocation = newLocation;
//                                   });
//                                   Navigator.pop(context);
//                                   Navigator.pop(context);
//                                   updateUserLocation(newLocation);
//                                 }
//                               },
//                               child: Text('Save'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   child: Text("Add New Location"),
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }

//   Future<void> updateUserLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) return;

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile/update'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"location": location}),
//       );

//       if (response.statusCode == 200 && mounted) {
//         setState(() => _userLocation = location);
//       } else {
//         print('Failed to update location.');
//       }
//     } catch (e) {
//       print('Error updating location: $e');
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: _showSearchBar
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search services...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: _toggleSearchBar,
//                         ),
//                       ),
//                       onChanged: _filterServices,
//                     ),
//                   )
//                 : IconButton(
//                     icon: Icon(Icons.search, color: Colors.cyan),
//                     onPressed: _toggleSearchBar,
//                     tooltip: 'Search Services',
//                   ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () =>
//                       _onServiceCardClicked(filteredServices[index]["title"]),
//                   child: ServiceCard(
//                     icon: filteredServices[index]["icon"],
//                     title: filteredServices[index]["title"],
//                   ),
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
//         automaticallyImplyLeading: false,
//         title: Text(
//           "Skill-Link",
//           style: GoogleFonts.poppins(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.cyan,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.cyan,
//         elevation: 0,
//         actions: [
//           GestureDetector(
//             onTap: _showLocationBottomSheet,
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.red, size: 18),
//                 SizedBox(width: 4),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 120),
//                   child: Text(
//                     _userLocation,
//                     style: TextStyle(fontSize: 14, color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: _selectedIndex == 0 ? _buildHomeScreen() : ProfileScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
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

// class ServiceCard extends StatelessWidget {
//   final IconData icon;
//   final String title;

//   const ServiceCard({required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 32, color: Colors.blueAccent),
//             SizedBox(height: 8),
//             Text(title, style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }

//00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 location can be update sucessfully
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;
//   String _userLocation = 'Fetching location...';
//   List<String> savedLocations = [];
//   String? selectedLocation;

//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
//   ];
//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//     fetchUserLocation();
//   }

//   Future<void> fetchUserLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) {
//       setState(() => _userLocation = 'Not logged in');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final profiles = data['data'];

//         final userProfile = profiles.firstWhere(
//           (profile) => profile['role'] == 'user',
//           orElse: () => null,
//         );

//         if (userProfile != null && mounted) {
//           setState(() {
//             _userLocation = userProfile['location'] ?? 'Location not set';
//             selectedLocation = _userLocation;
//           });
//         } else {
//           setState(() => _userLocation = 'Location not found');
//         }
//       } else {
//         setState(() => _userLocation = 'Failed to load location');
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       setState(() => _userLocation = 'Error loading location');
//     }
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
//       filteredServices = services
//           .where((service) =>
//               service["title"].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _onTabSelected(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('OK'))
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _showLocationBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSheet) {
//             return Padding(
//               padding: MediaQuery.of(context).viewInsets,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   RadioListTile<String>(
//                     title: Text("Current Location: $_userLocation"),
//                     value: _userLocation,
//                     groupValue: selectedLocation,
//                     onChanged: (value) {
//                       setStateSheet(() => selectedLocation = value);
//                     },
//                   ),
//                   Divider(),
//                   ElevatedButton(
//                     onPressed: () {
//                       _cityController.clear();
//                       _streetController.clear();
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: Text('Add New Location'),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 TextField(
//                                   controller: _cityController,
//                                   decoration:
//                                       InputDecoration(labelText: 'City'),
//                                 ),
//                                 TextField(
//                                   controller: _streetController,
//                                   decoration:
//                                       InputDecoration(labelText: 'Street No'),
//                                 ),
//                               ],
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: Text('Cancel'),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   final newLocation =
//                                       '${_streetController.text}, ${_cityController.text}';
//                                   setStateSheet(() {
//                                     savedLocations.add(newLocation);
//                                     selectedLocation = newLocation;
//                                   });
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text('Save'),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     child: Text("Add New Location"),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: savedLocations.length,
//                     itemBuilder: (context, index) {
//                       final location = savedLocations[index];
//                       return RadioListTile<String>(
//                         title: Text(location),
//                         value: location,
//                         groupValue: selectedLocation,
//                         onChanged: (value) {
//                           setStateSheet(() => selectedLocation = value);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       if (selectedLocation != null && selectedLocation != _userLocation) {
//         updateUserLocation(selectedLocation!);
//       }
//     });
//   }

//   Future<void> updateUserLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) return;

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile/update'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"location": location}),
//       );

//       if (response.statusCode == 200 && mounted) {
//         setState(() {
//           _userLocation = location;
//         });
//       } else {
//         print('Failed to update location. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating location: $e');
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: _showSearchBar
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search services...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: _toggleSearchBar,
//                         ),
//                       ),
//                       onChanged: _filterServices,
//                     ),
//                   )
//                 : IconButton(
//                     icon: Icon(Icons.search, color: Colors.cyan),
//                     onPressed: _toggleSearchBar,
//                     tooltip: 'Search Services',
//                   ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () =>
//                       _onServiceCardClicked(filteredServices[index]["title"]),
//                   child: ServiceCard(
//                     icon: filteredServices[index]["icon"],
//                     title: filteredServices[index]["title"],
//                   ),
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
//         automaticallyImplyLeading: false,
//         title: Text(
//           "Skill-Link",
//           style: GoogleFonts.poppins(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.cyan,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.cyan,
//         elevation: 0,
//         actions: [
//           GestureDetector(
//             onTap: _showLocationBottomSheet,
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.red, size: 18),
//                 SizedBox(width: 4),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 120),
//                   child: Text(
//                     _userLocation,
//                     style: TextStyle(fontSize: 14, color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: _selectedIndex == 0 ? _buildHomeScreen() : ProfileScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
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

// class ServiceCard extends StatelessWidget {
//   final IconData icon;
//   final String title;

//   const ServiceCard({required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 32, color: Colors.blueAccent),
//             SizedBox(height: 8),
//             Text(title, style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;
//   String _userLocation = 'Fetching location...';
//   List<String> savedLocations = [];
//   String? selectedLocation;

//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
//   ];
//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//     fetchUserLocation();
//     loadSavedLocations();
//   }

//   Future<void> loadSavedLocations() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedLocations = prefs.getStringList('saved_locations') ?? [];
//     setState(() {
//       savedLocations = storedLocations;
//     });
//   }

//   Future<void> saveLocationsToPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('saved_locations', savedLocations);
//   }

//   Future<void> fetchUserLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) {
//       setState(() => _userLocation = 'Not logged in');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final profiles = data['data'];

//         final userProfile = profiles.firstWhere(
//           (profile) => profile['role'] == 'user',
//           orElse: () => null,
//         );

//         if (userProfile != null && mounted) {
//           setState(() {
//             _userLocation = userProfile['location'] ?? 'Location not set';
//             selectedLocation = _userLocation;
//           });
//         } else {
//           setState(() => _userLocation = 'Location not found');
//         }
//       } else {
//         setState(() => _userLocation = 'Failed to load location');
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       setState(() => _userLocation = 'Error loading location');
//     }
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
//       filteredServices = services
//           .where((service) =>
//               service["title"].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _onTabSelected(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('OK'))
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _showLocationBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSheet) {
//             return Padding(
//               padding: MediaQuery.of(context).viewInsets,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   RadioListTile<String>(
//                     title: Text("Current Location: $_userLocation"),
//                     value: _userLocation,
//                     groupValue: selectedLocation,
//                     onChanged: (value) {
//                       setStateSheet(() => selectedLocation = value);
//                     },
//                   ),
//                   Divider(),
//                   ElevatedButton(
//                     onPressed: () {
//                       _cityController.clear();
//                       _streetController.clear();
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: Text('Add New Location'),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 TextField(
//                                   controller: _cityController,
//                                   decoration:
//                                       InputDecoration(labelText: 'City'),
//                                 ),
//                                 TextField(
//                                   controller: _streetController,
//                                   decoration:
//                                       InputDecoration(labelText: 'Street No'),
//                                 ),
//                               ],
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: Text('Cancel'),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   final newLocation =
//                                       '${_streetController.text}, ${_cityController.text}';
//                                   if (newLocation.trim().isEmpty) return;
//                                   setStateSheet(() {
//                                     if (!savedLocations.contains(newLocation)) {
//                                       savedLocations.add(newLocation);
//                                       saveLocationsToPrefs();
//                                     }
//                                     selectedLocation = newLocation;
//                                   });
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text('Save'),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     child: Text("Add New Location"),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: savedLocations.length,
//                     itemBuilder: (context, index) {
//                       final location = savedLocations[index];
//                       return RadioListTile<String>(
//                         title: Text(location),
//                         value: location,
//                         groupValue: selectedLocation,
//                         onChanged: (value) {
//                           setStateSheet(() => selectedLocation = value);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       if (selectedLocation != null && selectedLocation != _userLocation) {
//         updateUserLocation(selectedLocation!);
//       }
//     });
//   }

//   Future<void> updateUserLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) return;

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile/update'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"location": location}),
//       );

//       if (response.statusCode == 200 && mounted) {
//         setState(() {
//           _userLocation = location;
//         });
//       } else {
//         print('Failed to update location. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating location: $e');
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: _showSearchBar
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search services...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: _toggleSearchBar,
//                         ),
//                       ),
//                       onChanged: _filterServices,
//                     ),
//                   )
//                 : IconButton(
//                     icon: Icon(Icons.search, color: Colors.cyan),
//                     onPressed: _toggleSearchBar,
//                     tooltip: 'Search Services',
//                   ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () =>
//                       _onServiceCardClicked(filteredServices[index]["title"]),
//                   child: ServiceCard(
//                     icon: filteredServices[index]["icon"],
//                     title: filteredServices[index]["title"],
//                   ),
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
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             Icon(Icons.room_service, color: Colors.black, size: 28),
//             SizedBox(width: 8),
//             Text(
//               "Skill-Link",
//               style: GoogleFonts.poppins(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.cyan,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.cyan,
//         elevation: 0,
//         actions: [
//           GestureDetector(
//             onTap: _showLocationBottomSheet,
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.red, size: 18),
//                 SizedBox(width: 4),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 120),
//                   child: Text(
//                     _userLocation,
//                     style: TextStyle(fontSize: 14, color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: _selectedIndex == 0 ? _buildHomeScreen() : ProfileScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
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

// class ServiceCard extends StatelessWidget {
//   final IconData icon;
//   final String title;

//   const ServiceCard({required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 32, color: Colors.blueAccent),
//             SizedBox(height: 8),
//             Text(title, style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }

//

//000000000000000000000000000000000000000000000000000000000000000000000000000000yai code saaaara shi kaaam kr raha hai
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;
//   String _userLocation = 'Fetching location...';
//   List<String> savedLocations = [];
//   String? selectedLocation;

//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
//   ];
//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//     fetchUserLocation();
//     loadSavedLocations();
//   }

//   Future<void> loadSavedLocations() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedLocations = prefs.getStringList('saved_locations') ?? [];
//     setState(() {
//       savedLocations = storedLocations;
//     });
//   }

//   Future<void> saveLocationsToPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('saved_locations', savedLocations);
//   }

//   Future<void> fetchUserLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('bearer_token');

//     if (token == null) {
//       setState(() => _userLocation = 'Not logged in');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final profile = data['data'];

//         if (profile != null && mounted) {
//           setState(() {
//             _userLocation = profile['location'] ?? 'Location not set';
//             selectedLocation = _userLocation;
//           });
//         } else {
//           setState(() => _userLocation = 'Location not found');
//         }
//       } else {
//         setState(() => _userLocation = 'Failed to load location');
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       setState(() => _userLocation = 'Error loading location');
//     }
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
//       filteredServices = services
//           .where((service) =>
//               service["title"].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _onTabSelected(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('OK'),
//               )
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _showLocationBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSheet) {
//             return Padding(
//               padding: MediaQuery.of(context).viewInsets,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   RadioListTile<String>(
//                     title: Text("Current Location: $_userLocation"),
//                     value: _userLocation,
//                     groupValue: selectedLocation,
//                     onChanged: (value) {
//                       setStateSheet(() => selectedLocation = value);
//                     },
//                   ),
//                   Divider(),
//                   ElevatedButton(
//                     onPressed: () {
//                       _cityController.clear();
//                       _streetController.clear();
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: Text('Add New Location'),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 TextField(
//                                   controller: _cityController,
//                                   decoration:
//                                       InputDecoration(labelText: 'City'),
//                                 ),
//                                 TextField(
//                                   controller: _streetController,
//                                   decoration:
//                                       InputDecoration(labelText: 'Street No'),
//                                 ),
//                               ],
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: Text('Cancel'),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   final newLocation =
//                                       '${_streetController.text}, ${_cityController.text}';
//                                   if (newLocation.trim().isEmpty) return;
//                                   setStateSheet(() {
//                                     if (!savedLocations.contains(newLocation)) {
//                                       savedLocations.add(newLocation);
//                                       saveLocationsToPrefs();
//                                     }
//                                     selectedLocation = newLocation;
//                                   });
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text('Save'),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     child: Text("Add New Location"),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: savedLocations.length,
//                     itemBuilder: (context, index) {
//                       final location = savedLocations[index];
//                       return RadioListTile<String>(
//                         title: Text(location),
//                         value: location,
//                         groupValue: selectedLocation,
//                         onChanged: (value) {
//                           setStateSheet(() => selectedLocation = value);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       if (selectedLocation != null && selectedLocation != _userLocation) {
//         updateUserLocation(selectedLocation!);
//       }
//     });
//   }

//   Future<void> updateUserLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('bearer_token');
//     if (token == null) return;

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile/update'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"location": location}),
//       );

//       if (response.statusCode == 200 && mounted) {
//         setState(() {
//           _userLocation = location;
//         });
//       } else {
//         print('Failed to update location. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating location: $e');
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: _showSearchBar
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search services...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: _toggleSearchBar,
//                         ),
//                       ),
//                       onChanged: _filterServices,
//                     ),
//                   )
//                 : IconButton(
//                     icon: Icon(Icons.search, color: Colors.cyan),
//                     onPressed: _toggleSearchBar,
//                     tooltip: 'Search Services',
//                   ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () =>
//                       _onServiceCardClicked(filteredServices[index]["title"]),
//                   child: ServiceCard(
//                     icon: filteredServices[index]["icon"],
//                     title: filteredServices[index]["title"],
//                   ),
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
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             Icon(Icons.room_service, color: Colors.black, size: 28),
//             SizedBox(width: 8),
//             Text(
//               "Skill-Link",
//               style: GoogleFonts.poppins(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.cyan,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.cyan,
//         elevation: 0,
//         actions: [
//           GestureDetector(
//             onTap: _showLocationBottomSheet,
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.red, size: 18),
//                 SizedBox(width: 4),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 120),
//                   child: Text(
//                     _userLocation,
//                     style: TextStyle(fontSize: 14, color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: _selectedIndex == 0 ? _buildHomeScreen() : ProfileScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
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

// class ServiceCard extends StatelessWidget {
//   final IconData icon;
//   final String title;

//   const ServiceCard({required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 32, color: Colors.blueAccent),
//             SizedBox(height: 8),
//             Text(title, style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// yai code bilkul shi hai sirf background color white hai
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/users/booking.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;
//   String _userLocation = 'Fetching location...';
//   List<String> savedLocations = [];
//   String? selectedLocation;

//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
//   ];

//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//     fetchUserLocation();
//     loadSavedLocations();
//   }

//   Future<void> loadSavedLocations() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedLocations = prefs.getStringList('saved_locations') ?? [];
//     setState(() {
//       savedLocations = storedLocations;
//     });
//   }

//   Future<void> saveLocationsToPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('saved_locations', savedLocations);
//   }

//   Future<void> fetchUserLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('bearer_token');

//     if (token == null) {
//       setState(() => _userLocation = 'Not logged in');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final profile = data['data'];

//         if (profile != null && mounted) {
//           setState(() {
//             _userLocation = profile['location'] ?? 'Location not set';
//             selectedLocation = _userLocation;
//           });
//         } else {
//           setState(() => _userLocation = 'Location not found');
//         }
//       } else {
//         setState(() => _userLocation = 'Failed to load location');
//       }
//     } catch (e) {
//       print('Error fetching location: $e');
//       setState(() => _userLocation = 'Error loading location');
//     }
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
//       filteredServices = services
//           .where((service) =>
//               service["title"].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _onTabSelected(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('OK'),
//               )
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _showLocationBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSheet) {
//             return Padding(
//               padding: MediaQuery.of(context).viewInsets,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   RadioListTile<String>(
//                     title: Text("Current Location: $_userLocation"),
//                     value: _userLocation,
//                     groupValue: selectedLocation,
//                     onChanged: (value) {
//                       setStateSheet(() => selectedLocation = value);
//                     },
//                   ),
//                   Divider(),
//                   ElevatedButton(
//                     onPressed: () {
//                       _cityController.clear();
//                       _streetController.clear();
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: Text('Add New Location'),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 TextField(
//                                   controller: _cityController,
//                                   decoration:
//                                       InputDecoration(labelText: 'City'),
//                                 ),
//                                 TextField(
//                                   controller: _streetController,
//                                   decoration:
//                                       InputDecoration(labelText: 'Street No'),
//                                 ),
//                               ],
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: Text('Cancel'),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   final newLocation =
//                                       '${_streetController.text}, ${_cityController.text}';
//                                   if (newLocation.trim().isEmpty) return;
//                                   setStateSheet(() {
//                                     if (!savedLocations.contains(newLocation)) {
//                                       savedLocations.add(newLocation);
//                                       saveLocationsToPrefs();
//                                     }
//                                     selectedLocation = newLocation;
//                                   });
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text('Save'),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     child: Text("Add New Location"),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: savedLocations.length,
//                     itemBuilder: (context, index) {
//                       final location = savedLocations[index];
//                       return RadioListTile<String>(
//                         title: Text(location),
//                         value: location,
//                         groupValue: selectedLocation,
//                         onChanged: (value) {
//                           setStateSheet(() => selectedLocation = value);
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       if (selectedLocation != null && selectedLocation != _userLocation) {
//         updateUserLocation(selectedLocation!);
//       }
//     });
//   }

//   Future<void> updateUserLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('bearer_token');
//     if (token == null) return;

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile/update'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"location": location}),
//       );

//       if (response.statusCode == 200 && mounted) {
//         setState(() {
//           _userLocation = location;
//         });
//       } else {
//         print('Failed to update location. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating location: $e');
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: _showSearchBar
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search services...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: _toggleSearchBar,
//                         ),
//                       ),
//                       onChanged: _filterServices,
//                     ),
//                   )
//                 : IconButton(
//                     icon: Icon(Icons.search, color: Colors.cyan),
//                     onPressed: _toggleSearchBar,
//                     tooltip: 'Search Services',
//                   ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () =>
//                       _onServiceCardClicked(filteredServices[index]["title"]),
//                   child: ServiceCard(
//                     icon: filteredServices[index]["icon"],
//                     title: filteredServices[index]["title"],
//                   ),
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
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             PopupMenuButton<String>(
//               icon: Icon(Icons.room_service, color: Colors.black, size: 28),
//               onSelected: (value) {
//                 if (value == 'booking-request') {
//                   // Navigate to Booking Request screen
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => RequestScreen(),
//                     ),
//                   );
//                 }
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: 'booking-request',
//                   child: Row(
//                     children: [
//                       Icon(Icons.request_page, color: Colors.black),
//                       SizedBox(width: 8),
//                       Text('Booking Request'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(width: 8),
//             Text(
//               "Skill-Link",
//               style: GoogleFonts.poppins(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.cyan,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.cyan,
//         elevation: 0,
//         actions: [
//           GestureDetector(
//             onTap: _showLocationBottomSheet,
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.red, size: 18),
//                 SizedBox(width: 4),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 120),
//                   child: Text(
//                     _userLocation,
//                     style: TextStyle(fontSize: 14, color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: _selectedIndex == 0 ? _buildHomeScreen() : ProfileScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
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

// class ServiceCard extends StatelessWidget {
//   final IconData icon;
//   final String title;

//   const ServiceCard({required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 32, color: Colors.blueAccent),
//             SizedBox(height: 8),
//             Text(title, style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }

//ia code may new color show hoo raha hia background may
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/users/booking.dart';
// import 'package:plumber_project/pages/userservice/electricianservice.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'service.dart';
// import 'setting.dart';
// import 'profile.dart';
// import 'emergency.dart';

// final Color darkBlue = Color(0xFF003E6B);
// final Color tealBlue = Color(0xFF00A8A8);

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _showSearchBar = false;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedIndex = 0;
//   String _userLocation = 'Fetching location...';
//   List<String> savedLocations = [];
//   String? selectedLocation;

//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();

//   List<Map<String, dynamic>> services = [
//     {"icon": Icons.tap_and_play, "title": "Plumber"},
//     // {"icon": Icons.construction, "title": "Labor"},
//     {"icon": Icons.electrical_services, "title": "Electrician"},
//     {"icon": Icons.kitchen, "title": "Appliances"},
//     {"icon": Icons.videocam, "title": "CCTV"},
//     {"icon": Icons.format_paint, "title": "Painting"},
//     {"icon": Icons.carpenter, "title": "Carpenter"},
//     {"icon": Icons.bug_report, "title": "Pest Control"},
//     {"icon": Icons.girl, "title": "Wall Panelling"},
//     {"icon": Icons.wallpaper, "title": "Wall Panelling"},
//     {"icon": Icons.cleaning_services, "title": "Cleaner"},
//   ];

//   List<Map<String, dynamic>> filteredServices = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = services;
//     fetchUserLocation();
//     loadSavedLocations();
//   }

//   Future<void> fetchUserLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('bearer_token');

//     if (token == null) {
//       setState(() => _userLocation = 'Not logged in');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final profile = data['data'];
//         if (profile != null && mounted) {
//           setState(() {
//             _userLocation = profile['location'] ?? 'Location not set';
//             selectedLocation = _userLocation;
//           });
//         }
//       } else {
//         setState(() => _userLocation = 'Failed to load location');
//       }
//     } catch (e) {
//       setState(() => _userLocation = 'Error loading location');
//     }
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
//       filteredServices = services
//           .where((service) =>
//               service["title"].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _onTabSelected(int index) {
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
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _onServiceCardClicked(String serviceName) {
//     if (serviceName.toLowerCase() == 'plumber') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PlumberPage()),
//       );
//     } else if (serviceName.toLowerCase() == 'electrician') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ElectricianPage()),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(serviceName),
//             content: Text('You clicked on the $serviceName service.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('OK'),
//               )
//             ],
//           );
//         },
//       );
//     }
//   }

//   Widget _buildHomeScreen() {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerRight,
//             child: _showSearchBar
//                 ? AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: TextField(
//                       controller: _searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search services...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.close),
//                           onPressed: _toggleSearchBar,
//                         ),
//                       ),
//                       onChanged: _filterServices,
//                     ),
//                   )
//                 : IconButton(
//                     icon: Icon(Icons.search, color: Colors.cyan),
//                     onPressed: _toggleSearchBar,
//                     tooltip: 'Search Services',
//                   ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               itemCount: filteredServices.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () =>
//                       _onServiceCardClicked(filteredServices[index]["title"]),
//                   child: Card(
//                     color: Colors.white,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(filteredServices[index]["icon"], size: 36),
//                         SizedBox(height: 8),
//                         Text(
//                           filteredServices[index]["title"],
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLocationBottomSheet() {
//     // You can place your location selector modal here.
//   }

//   Future<void> updateUserLocation(String location) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('bearer_token');
//     if (token == null) return;

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/profile/update'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"location": location}),
//       );

//       if (response.statusCode == 200 && mounted) {
//         setState(() {
//           _userLocation = location;
//         });
//       }
//     } catch (e) {
//       print('Error updating location: $e');
//     }
//   }

//   Future<void> loadSavedLocations() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedLocations = prefs.getStringList('saved_locations') ?? [];
//     setState(() {
//       savedLocations = storedLocations;
//     });
//   }

//   Future<void> saveLocationsToPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('saved_locations', savedLocations);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _cityController.dispose();
//     _streetController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: darkBlue,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: tealBlue,
//         title: Row(
//           children: [
//             PopupMenuButton<String>(
//               icon: Icon(Icons.room_service, color: Colors.black, size: 28),
//               onSelected: (value) {
//                 if (value == 'booking-request') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RequestScreen()),
//                   );
//                 }
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: 'booking-request',
//                   child: Row(
//                     children: [
//                       Icon(Icons.request_page, color: Colors.black),
//                       SizedBox(width: 8),
//                       Text('Booking Request'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(width: 8),
//             Text(
//               "Skill-Link",
//               style: GoogleFonts.poppins(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//         elevation: 0,
//         actions: [
//           // IconButton(
//           //   icon: Icon(Icons.location_on, color: Colors.black),
//           //   onPressed: _showLocationBottomSheet,
//           //   tooltip: 'Change Location',
//           // ),
//         ],
//       ),
//       body: _buildHomeScreen(),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: tealBlue,
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.yellow,
//         unselectedItemColor: Colors.white,
//         onTap: _onTabSelected,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.emergency,
//               color: Colors.red,
//             ),
//             label: 'Emergency',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/users/booking.dart';
import 'package:plumber_project/pages/userservice/electricianservice.dart';
import 'package:plumber_project/pages/userservice/plumberservice.dart';
import 'service.dart';
import 'setting.dart';
import 'profile.dart';
import 'emergency.dart';

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
