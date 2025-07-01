// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchPlumbers();
//   }

//   Future<void> fetchPlumbers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/api/profile/'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         final List<dynamic> allProfiles = data['id'];

//         final plumbersJson =
//             allProfiles
//                 .where((profile) => profile['role'] == 'plumber')
//                 .toList();

//         setState(() {
//           _plumbers =
//               plumbersJson.map((json) => Plumber.fromJson(json)).toList();
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers. Please check your connection.');
//       print('Error fetching plumbers: $e');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body:
//           _loading
//               ? Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                 itemCount: _plumbers.length,
//                 itemBuilder: (context, index) {
//                   final plumber = _plumbers[index];
//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: NetworkImage(
//                           'http://YOUR_BACKEND_URL/uploads/plumber_image/${plumber.plumberImage}',
//                         ),
//                       ),
//                       title: Text(plumber.fullName),
//                       subtitle: Text('${plumber.experience} years experience'),
//                       trailing: Text('\$${plumber.hourlyRate}/hr'),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // <-- Add this!

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;
//   String? _token;

//   @override
//   void initState() {
//     super.initState();
//     loadTokenAndFetch();
//   }

//   Future<void> loadTokenAndFetch() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token'); // Make sure token was saved after login
//     if (_token != null) {
//       fetchPlumbers();
//     } else {
//       setState(() => _loading = false);
//       _showError('Authentication token missing. Please login again.');
//     }
//   }

//   Future<void> fetchPlumbers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         final List<dynamic> allProfiles = data['data'];

//         final plumbersJson =
//             allProfiles
//                 .where((profile) => profile['role'] == 'plumber')
//                 .toList();

//         setState(() {
//           _plumbers =
//               plumbersJson.map((json) => Plumber.fromJson(json)).toList();
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers. Please check your connection.');
//       print('Error fetching plumbers: $e');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body:
//           _loading
//               ? Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                 itemCount: _plumbers.length,
//                 itemBuilder: (context, index) {
//                   final plumber = _plumbers[index];
//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     child: ListTile(
//                       onTap: ,
//                       leading: CircleAvatar(
//                         backgroundImage: NetworkImage(
//                           'http://10.0.2.2:8000/uploads/plumber_image/${plumber.plumberImage}',
//                         ),
//                       ),
//                       title: Text(plumber.fullName),
//                       subtitle: Text('${plumber.experience} years experience'),
//                       trailing: Text('\RS:${plumber.hourlyRate}/hr'),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';
// import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;
//   String? _token;

//   @override
//   void initState() {
//     super.initState();
//     loadTokenAndFetch();
//   }

//   Future<void> loadTokenAndFetch() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token != null) {
//       fetchPlumbers();
//     } else {
//       setState(() => _loading = false);
//       _showError('Authentication token missing. Please login again.');
//     }
//   }

//   Future<void> fetchPlumbers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> allProfiles = data['data'];

//         final plumbersJson =
//             allProfiles
//                 .where((profile) => profile['role'] == 'plumber')
//                 .toList();

//         setState(() {
//           _plumbers =
//               plumbersJson.map((json) => Plumber.fromJson(json)).toList();
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers. Please check your connection.');
//       print('Error fetching plumbers: $e');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body:
//           _loading
//               ? Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                 itemCount: _plumbers.length,
//                 itemBuilder: (context, index) {
//                   final plumber = _plumbers[index];

//                   // Make sure plumber.plumberImage is not null or empty
//                   final imageUrl =
//                       plumber.plumberImage != null &&
//                               plumber.plumberImage!.isNotEmpty
//                           ? 'http://10.0.2.2:8000/uploads/plumber_image/${plumber.plumberImage}'
//                           : null;

//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     child: ListTile(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) =>
//                                     PlumberDetailPage(plumber: plumber),
//                           ),
//                         );
//                       },
//                       leading: CircleAvatar(
//                         backgroundImage:
//                             imageUrl != null
//                                 ? NetworkImage(imageUrl)
//                                 : AssetImage('assets/images/placeholder.png')
//                                     as ImageProvider,
//                       ),
//                       title: Text(plumber.fullName),
//                       subtitle: Text('${plumber.experience} years experience'),
//                       trailing: Text('Rs:${plumber.hourlyRate}/hr'),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }

//00000000000000000000000000000000000000000000000000000000000000000000000000000000000 this code sucessfuly display the plumbers profile

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';
// import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;
//   String? _token;

//   // ✅ For Android emulator use 10.0.2.2. For real device, use your IP.
//   // final String baseUrl = 'http://192.168.100.108:8000';

//   @override
//   void initState() {
//     super.initState();
//     loadTokenAndFetch();
//   }

//   Future<void> loadTokenAndFetch() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token != null) {
//       fetchPlumbers();
//     } else {
//       setState(() => _loading = false);
//       _showError('Authentication token missing. Please login again.');
//     }
//   }

//   Future<void> fetchPlumbers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> allProfiles = data['data'];

//         final plumbersJson =
//             allProfiles
//                 .where((profile) => profile['role'] == 'plumber')
//                 .toList();

//         setState(() {
//           _plumbers =
//               plumbersJson.map((json) => Plumber.fromJson(json)).toList();
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers. Please check your connection.');
//       print('Error fetching plumbers: $e');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   // ✅ Construct full image URL
//   String fixImageUrl(String imageId) {
//     return '$baseUrl/uploads/plumber_image/$imageId';
//   }

//   // ✅ Return NetworkImage or placeholder
//   ImageProvider getProfileImage(String? imageId) {
//     if (imageId == null || imageId.isEmpty) {
//       return AssetImage('hello');
//     } else {
//       // final url = fixImageUrl(imageId);
//       final url = imageId;
//       print('Fetching image: $url');
//       return NetworkImage(url);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body:
//           _loading
//               ? Center(child: CircularProgressIndicator())
//               : _plumbers.isEmpty
//               ? Center(child: Text('No plumbers found.'))
//               : ListView.builder(
//                 itemCount: _plumbers.length,
//                 itemBuilder: (context, index) {
//                   final plumber = _plumbers[index];

//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     child: ListTile(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) =>
//                                     PlumberDetailPage(plumber: plumber),
//                           ),
//                         );
//                       },
//                       leading: CircleAvatar(
//                         // backgroundImage: getProfileImage(plumber.plumberImage),
//                         backgroundImage: getProfileImage(plumber.plumberImage),
//                         radius: 30,
//                         backgroundColor: Colors.grey[200],
//                       ),
//                       title: Text(plumber.fullName),
//                       subtitle: Text('${plumber.experience} years experience'),
//                       trailing: Text('Rs:${plumber.hourlyRate}/hr'),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }

//0000000000000000000000000000000000000000this code show me the animation and
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:lottie/lottie.dart';

// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';
// import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;
//   String? _token;
//   bool _showFindingScreen = true;

//   @override
//   void initState() {
//     super.initState();
//     getUserLocationAndFetch();
//   }

//   Future<void> getUserLocationAndFetch() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showError('Location services are disabled.');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showError('Location permission is required to fetch nearby plumbers.');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showError(
//           'Location permission is permanently denied. Please enable it from settings.');
//       return;
//     }

//     Position userPosition = await Geolocator.getCurrentPosition();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token != null) {
//       await fetchPlumbers(userPosition);
//     } else {
//       _showError('Authentication token missing. Please login again.');
//     }

//     setState(() {
//       _showFindingScreen = false;
//     });
//   }

//   Future<void> fetchPlumbers(Position userPosition) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> allProfiles = data['data'];

//         final List<Plumber> filtered = allProfiles
//             .where((profile) =>
//                 profile['role'] == 'plumber' &&
//                 profile['latitude'] != null &&
//                 profile['longitude'] != null)
//             .map((profile) {
//               final plumber = Plumber.fromJson(profile);
//               double distanceInMeters = Geolocator.distanceBetween(
//                 userPosition.latitude,
//                 userPosition.longitude,
//                 profile['latitude'],
//                 profile['longitude'],
//               );
//               if (distanceInMeters <= 5000) return plumber;
//               return null;
//             })
//             .whereType<Plumber>()
//             .toList();

//         setState(() {
//           _plumbers = filtered;
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers. Please check your connection.');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   ImageProvider getProfileImage(String? imageId) {
//     if (imageId == null || imageId.isEmpty) {
//       return AssetImage('assets/images/placeholder.png');
//     } else {
//       return NetworkImage(imageId); // Or use fixImageUrl(imageId) if needed
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body: _showFindingScreen
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Lottie.asset("assets/animation/finding_providers.json"),
//                   SizedBox(height: 20),
//                   Text("Finding nearby plumbers...",
//                       style: TextStyle(fontSize: 16, color: Colors.grey[700])),
//                 ],
//               ),
//             )
//           : _loading
//               ? Center(child: CircularProgressIndicator())
//               : _plumbers.isEmpty
//                   ? Center(child: Text('No nearby plumbers found.'))
//                   : ListView.builder(
//                       itemCount: _plumbers.length,
//                       itemBuilder: (context, index) {
//                         final plumber = _plumbers[index];
//                         return Card(
//                           margin:
//                               EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                           child: ListTile(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       PlumberDetailPage(plumber: plumber),
//                                 ),
//                               );
//                             },
//                             leading: CircleAvatar(
//                               backgroundImage:
//                                   getProfileImage(plumber.plumberImage),
//                               radius: 30,
//                               backgroundColor: Colors.grey[200],
//                             ),
//                             title: Text(plumber.fullName),
//                             subtitle:
//                                 Text('${plumber.experience} years experience'),
//                             trailing: Text('Rs:${plumber.hourlyRate}/hr'),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

//0000000000000000000000000000000000000000000000000000000000000000000000000000 this code finally fetch the plumber profile according to the live location
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:lottie/lottie.dart';

// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';
// import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;
//   String? _token;
//   bool _showFindingScreen = true;
//   Position? _userPosition;

//   @override
//   void initState() {
//     super.initState();
//     getUserLocationAndFetch();
//   }

//   Future<void> getUserLocationAndFetch() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showError('Location services are disabled.');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showError('Location permission denied.');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showError('Location permission is permanently denied.');
//       return;
//     }

//     _userPosition = await Geolocator.getCurrentPosition();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token != null) {
//       await fetchPlumbersWithinRadius();
//     } else {
//       _showError('Authentication token missing.');
//     }

//     setState(() {
//       _showFindingScreen = false;
//     });
//   }

//   Future<void> fetchPlumbersWithinRadius() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> allProfiles = data['data'];

//         List<Plumber> nearbyPlumbers = [];

//         for (var profile in allProfiles) {
//           if (profile['role'] == 'plumber' && profile['service_area'] != null) {
//             String serviceArea = profile['service_area'];

//             try {
//               List<Location> locations = await locationFromAddress(serviceArea);
//               if (locations.isNotEmpty) {
//                 double distance = Geolocator.distanceBetween(
//                   _userPosition!.latitude,
//                   _userPosition!.longitude,
//                   locations.first.latitude,
//                   locations.first.longitude,
//                 );

//                 if (distance <= 5000) {
//                   nearbyPlumbers.add(Plumber.fromJson(profile));
//                 }
//               }
//             } catch (e) {
//               print('Geocoding failed for $serviceArea: $e');
//               continue;
//             }
//           }
//         }

//         setState(() {
//           _plumbers = nearbyPlumbers;
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers.');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   ImageProvider getProfileImage(String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return AssetImage('assets/images/placeholder.png');
//     } else {
//       return NetworkImage(imageUrl);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body: _showFindingScreen
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Lottie.asset("assets/animation/finding_providers.json"),
//                   SizedBox(height: 20),
//                   Text("Finding nearby plumbers...",
//                       style: TextStyle(fontSize: 16, color: Colors.grey[700])),
//                 ],
//               ),
//             )
//           : _loading
//               ? Center(child: CircularProgressIndicator())
//               : _plumbers.isEmpty
//                   ? Center(child: Text('No nearby plumbers found.'))
//                   : ListView.builder(
//                       itemCount: _plumbers.length,
//                       itemBuilder: (context, index) {
//                         final plumber = _plumbers[index];
//                         return Card(
//                           margin:
//                               EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                           child: ListTile(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       PlumberDetailPage(plumber: plumber),
//                                 ),
//                               );
//                             },
//                             leading: CircleAvatar(
//                               backgroundImage:
//                                   getProfileImage(plumber.plumberImage),
//                               radius: 30,
//                               backgroundColor: Colors.grey[200],
//                             ),
//                             title: Text(plumber.fullName),
//                             subtitle:
//                                 Text('${plumber.experience} years experience'),
//                             trailing: Text('Rs:${plumber.hourlyRate}/hr'),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

//00000000000000000000000000000000000000000000000000000000000 yai sirf pic nhi dikhaa raha plumber ki or background color white hsi is ka
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:lottie/lottie.dart';

// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';
// import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';

// class PlumberPage extends StatefulWidget {
//   @override
//   _PlumberPageState createState() => _PlumberPageState();
// }

// class _PlumberPageState extends State<PlumberPage> {
//   List<Plumber> _plumbers = [];
//   bool _loading = true;
//   String? _token;
//   bool _showFindingScreen = true;
//   Position? _userPosition;

//   @override
//   void initState() {
//     super.initState();
//     getUserLocationAndFetch();
//   }

//   Future<void> getUserLocationAndFetch() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showError('Location services are disabled.');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showError('Location permission denied.');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showError('Location permission is permanently denied.');
//       return;
//     }

//     _userPosition = await Geolocator.getCurrentPosition();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('bearer_token'); // ✅ Use correct key

//     print("🔑 Retrieved token: $_token");

//     if (_token != null && _token!.isNotEmpty) {
//       await fetchPlumbersWithinRadius();
//     } else {
//       _showError('Unable to retrieve your session. Please log in again.');
//     }

//     setState(() {
//       _showFindingScreen = false;
//     });
//   }

//   Future<void> fetchPlumbersWithinRadius() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/profile'),
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> allProfiles = data['data'];

//         List<Plumber> nearbyPlumbers = [];

//         for (var profile in allProfiles) {
//           if (profile['role'] == 'plumber' && profile['service_area'] != null) {
//             String serviceArea = profile['service_area'];

//             try {
//               List<Location> locations = await locationFromAddress(serviceArea);
//               if (locations.isNotEmpty) {
//                 double distance = Geolocator.distanceBetween(
//                   _userPosition!.latitude,
//                   _userPosition!.longitude,
//                   locations.first.latitude,
//                   locations.first.longitude,
//                 );

//                 if (distance <= 5000) {
//                   if (profile['plumber_image'] != null &&
//                       !profile['plumber_image'].toString().startsWith('http')) {
//                     profile['plumber_image'] =
//                         '$baseUrl/uploads/plumber_image/${profile['plumber_image']}';
//                   }

//                   nearbyPlumbers.add(Plumber.fromJson(profile));
//                 }
//               }
//             } catch (e) {
//               print('Geocoding failed for $serviceArea: $e');
//               continue;
//             }
//           }
//         }

//         setState(() {
//           _plumbers = nearbyPlumbers;
//           _loading = false;
//         });
//       } else {
//         setState(() => _loading = false);
//         _showError('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       _showError('Failed to fetch plumbers.');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Plumber Services')),
//       body: _showFindingScreen
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Lottie.asset("assets/animation/finding_providers.json"),
//                   SizedBox(height: 20),
//                   Text("Finding nearby plumbers...",
//                       style: TextStyle(fontSize: 16, color: Colors.grey[700])),
//                 ],
//               ),
//             )
//           : _loading
//               ? Center(child: CircularProgressIndicator())
//               : _plumbers.isEmpty
//                   ? Center(child: Text('No nearby plumbers found.'))
//                   : ListView.builder(
//                       itemCount: _plumbers.length,
//                       itemBuilder: (context, index) {
//                         final plumber = _plumbers[index];
//                         return Card(
//                           margin:
//                               EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                           child: ListTile(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       PlumberDetailPage(plumber: plumber),
//                                 ),
//                               );
//                               print('Passing plumber ID: ${plumber.id}');
//                             },
//                             leading: CircleAvatar(
//                               radius: 30,
//                               backgroundColor: Colors.grey[200],
//                               child: ClipOval(
//                                 child: Image.network(
//                                   plumber.plumberImage ?? '',
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Image.asset(
//                                       'assets/images/placeholder.png',
//                                       width: 60,
//                                       height: 60,
//                                       fit: BoxFit.cover,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             title: Text(plumber.fullName),
//                             subtitle:
//                                 Text('${plumber.experience} years experience'),
//                             trailing: Text('Rs:${plumber.hourlyRate}/hr'),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';

import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/userservice/plumbermodel.dart';
import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class PlumberPage extends StatefulWidget {
  @override
  _PlumberPageState createState() => _PlumberPageState();
}

class _PlumberPageState extends State<PlumberPage> {
  List<Plumber> _plumbers = [];
  bool _loading = true;
  String? _token;
  bool _showFindingScreen = true;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    getUserLocationAndFetch();
  }

  Future<void> getUserLocationAndFetch() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permission is permanently denied.');
      return;
    }

    _userPosition = await Geolocator.getCurrentPosition();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('bearer_token');

    if (_token != null && _token!.isNotEmpty) {
      await fetchPlumbersWithinRadius();
    } else {
      _showError('Unable to retrieve your session. Please log in again.');
    }

    setState(() {
      _showFindingScreen = false;
    });
  }

  Future<void> fetchPlumbersWithinRadius() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> allProfiles = data['data'];

        List<Plumber> nearbyPlumbers = [];

        for (var profile in allProfiles) {
          if (profile['role'] == 'plumber' && profile['service_area'] != null) {
            String serviceArea = profile['service_area'];

            try {
              List<Location> locations = await locationFromAddress(serviceArea);
              if (locations.isNotEmpty) {
                double distance = Geolocator.distanceBetween(
                  _userPosition!.latitude,
                  _userPosition!.longitude,
                  locations.first.latitude,
                  locations.first.longitude,
                );

                if (distance <= 5000) {
                  if (profile['plumber_image'] != null &&
                      !profile['plumber_image'].toString().startsWith('http')) {
                    profile['plumber_image'] =
                        '$baseUrl/uploads/plumber_image/${profile['plumber_image']}';
                  }

                  nearbyPlumbers.add(Plumber.fromJson(profile));
                }
              }
            } catch (e) {
              print('Geocoding failed for $serviceArea: $e');
              continue;
            }
          }
        }

        setState(() {
          _plumbers = nearbyPlumbers;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to fetch plumbers.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text('Plumber Services'),
        backgroundColor: tealBlue,
      ),
      body: _showFindingScreen
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/animation/finding_providers.json"),
                  SizedBox(height: 20),
                  Text(
                    "Finding nearby plumbers...",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            )
          : _loading
              ? Center(child: CircularProgressIndicator(color: tealBlue))
              : _plumbers.isEmpty
                  ? Center(
                      child: Text(
                        'No nearby plumbers found.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _plumbers.length,
                      itemBuilder: (context, index) {
                        final plumber = _plumbers[index];
                        return Card(
                          color: Colors.white,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlumberDetailPage(plumber: plumber),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Image.network(
                                  plumber.plumberImage ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/placeholder.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              plumber.fullName,
                              style: TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${plumber.experience} years experience',
                              style: TextStyle(color: Colors.black87),
                            ),
                            trailing: Text(
                              'Rs:${plumber.hourlyRate}/hr',
                              style: TextStyle(
                                  color: tealBlue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
