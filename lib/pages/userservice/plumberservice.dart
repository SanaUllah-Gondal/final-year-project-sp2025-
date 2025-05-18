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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/Apis.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/userservice/plumbermodel.dart';
import 'package:plumber_project/pages/userservice/plumber_detail_page.dart';

class PlumberPage extends StatefulWidget {
  @override
  _PlumberPageState createState() => _PlumberPageState();
}

class _PlumberPageState extends State<PlumberPage> {
  List<Plumber> _plumbers = [];
  bool _loading = true;
  String? _token;

  // ✅ For Android emulator use 10.0.2.2. For real device, use your IP.
  // final String baseUrl = 'http://192.168.100.108:8000';

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
  }

  Future<void> loadTokenAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      fetchPlumbers();
    } else {
      setState(() => _loading = false);
      _showError('Authentication token missing. Please login again.');
    }
  }

  Future<void> fetchPlumbers() async {
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

        final plumbersJson =
            allProfiles
                .where((profile) => profile['role'] == 'plumber')
                .toList();

        setState(() {
          _plumbers =
              plumbersJson.map((json) => Plumber.fromJson(json)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to fetch plumbers. Please check your connection.');
      print('Error fetching plumbers: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ✅ Construct full image URL
  String fixImageUrl(String imageId) {
    return '$baseUrl/uploads/plumber_image/$imageId';
  }

  // ✅ Return NetworkImage or placeholder
  ImageProvider getProfileImage(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return AssetImage('hello');
    } else {
      // final url = fixImageUrl(imageId);
      final url = imageId;
      print('Fetching image: $url');
      return NetworkImage(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plumber Services')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _plumbers.isEmpty
              ? Center(child: Text('No plumbers found.'))
              : ListView.builder(
                itemCount: _plumbers.length,
                itemBuilder: (context, index) {
                  final plumber = _plumbers[index];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PlumberDetailPage(plumber: plumber),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        // backgroundImage: getProfileImage(plumber.plumberImage),
                        backgroundImage: getProfileImage(plumber.plumberImage),
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                      ),
                      title: Text(plumber.fullName),
                      subtitle: Text('${plumber.experience} years experience'),
                      trailing: Text('Rs:${plumber.hourlyRate}/hr'),
                    ),
                  );
                },
              ),
    );
  }
}
