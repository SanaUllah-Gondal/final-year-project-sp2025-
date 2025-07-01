// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/Apis.dart'; // Make sure baseUrl is defined here

// class RequestScreen extends StatefulWidget {
//   @override
//   _RequestScreenState createState() => _RequestScreenState();
// }

// class _RequestScreenState extends State<RequestScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List plumberRequests = [];
//   List electricianRequests = [];
//   String? userProfileId;
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     loadUserProfileAndFetch();
//   }

//   Future<void> loadUserProfileAndFetch() async {
//     final prefs = await SharedPreferences.getInstance();

//     token = prefs.getString('bearer_token');
//     userProfileId = prefs.get('user_profile_id')?.toString(); // Fix applied

//     print('🟢 Loaded user_profile_id from local storage: $userProfileId');

//     if (userProfileId != null) {
//       await Future.wait([
//         fetchPlumberRequests(),
//         fetchElectricianRequests(),
//       ]);
//     } else {
//       print("❌ user_profile_id not found in local storage.");
//     }
//   }

//   Future<void> fetchPlumberRequests() async {
//     if (userProfileId == null) return;

//     final url = '$baseUrl/api/plumber_appointment?user_p_id=$userProfileId';
//     print("📡 Fetching plumber appointments from: $url");

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         print("✅ Plumber Response: $decoded");

//         if (decoded['success'] == true && decoded['data'] is List) {
//           setState(() {
//             plumberRequests = decoded['data'];
//           });
//         } else {
//           print("❌ Plumber: Invalid response format");
//         }
//       } else {
//         print("❌ Plumber fetch failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("⚠️ Error fetching plumber requests: $e");
//     }
//   }

//   Future<void> fetchElectricianRequests() async {
//     if (userProfileId == null) return;

//     final url = '$baseUrl/api/electrician_appointment?user_p_id=$userProfileId';
//     print("📡 Fetching electrician appointments from: $url");

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         print("✅ Electrician Response: $decoded");

//         if (decoded['success'] == true && decoded['data'] is List) {
//           setState(() {
//             electricianRequests = decoded['data'];
//           });
//         } else {
//           print("❌ Electrician: Invalid response format");
//         }
//       } else {
//         print("❌ Electrician fetch failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("⚠️ Error fetching electrician requests: $e");
//     }
//   }

//   Widget buildRequestCard(Map request, String type) {
//     final imageUrl = request['p_problem_image'] != null
//         ? '$baseUrl/uploads/${type}_appointment_image/${request['p_problem_image']}'
//         : null;

//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       elevation: 3,
//       child: ListTile(
//         leading: imageUrl != null
//             ? GestureDetector(
//                 onTap: () => showDialog(
//                   context: context,
//                   builder: (_) => Dialog(
//                     child: Image.network(imageUrl, fit: BoxFit.cover),
//                   ),
//                 ),
//                 child: Image.network(
//                   imageUrl,
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                 ),
//               )
//             : Icon(Icons.image_not_supported),
//         title: Text('Appointment ID: ${request['id']}'),
//         subtitle: Text(request['description'] ?? 'No Description'),
//       ),
//     );
//   }

//   Widget buildEmptyState(String message, VoidCallback onPrint) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(message),
//           SizedBox(height: 12),
//           ElevatedButton(onPressed: onPrint, child: Text("Debug Print")),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Service Requests"),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: "Plumber"),
//             Tab(text: "Electrician"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           plumberRequests.isEmpty
//               ? buildEmptyState("No plumber requests found.", () {
//                   print("🪠 plumberRequests = $plumberRequests");
//                 })
//               : ListView.builder(
//                   itemCount: plumberRequests.length,
//                   itemBuilder: (context, index) {
//                     return buildRequestCard(plumberRequests[index], 'plumber');
//                   },
//                 ),
//           electricianRequests.isEmpty
//               ? buildEmptyState("No electrician requests found.", () {
//                   print("💡 electricianRequests = $electricianRequests");
//                 })
//               : ListView.builder(
//                   itemCount: electricianRequests.length,
//                   itemBuilder: (context, index) {
//                     return buildRequestCard(
//                         electricianRequests[index], 'electrician');
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }

//000000000000000000000000000000000000000000000000000000000000000000000000000000000000 yai kabhi kabhi dikhaata
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/Apis.dart'; // Make sure baseUrl is defined here

// class RequestScreen extends StatefulWidget {
//   @override
//   _RequestScreenState createState() => _RequestScreenState();
// }

// class _RequestScreenState extends State<RequestScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List plumberRequests = [];
//   List electricianRequests = [];
//   Map<int, String> profileNames = {};
//   String? userProfileId;
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     loadUserProfileAndFetch();
//   }

//   Future<void> loadUserProfileAndFetch() async {
//     final prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('bearer_token');
//     userProfileId = prefs.get('user_profile_id')?.toString();

//     if (userProfileId != null) {
//       await Future.wait([
//         fetchPlumberRequests(),
//         fetchElectricianRequests(),
//       ]);
//     }
//   }

//   Future<void> fetchPlumberRequests() async {
//     if (userProfileId == null) return;

//     final url = '$baseUrl/api/plumber_appointment?user_p_id=$userProfileId';

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         if (decoded['success'] == true && decoded['data'] is List) {
//           setState(() {
//             plumberRequests = decoded['data'];
//           });
//           await fetchProfileNames(plumberRequests, 'plumber_p_id');
//         }
//       }
//     } catch (e) {
//       print("Error fetching plumber requests: $e");
//     }
//   }

//   Future<void> fetchElectricianRequests() async {
//     if (userProfileId == null) return;

//     final url = '$baseUrl/api/electrician_appointment?user_p_id=$userProfileId';

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         if (decoded['success'] == true && decoded['data'] is List) {
//           setState(() {
//             electricianRequests = decoded['data'];
//           });
//           await fetchProfileNames(electricianRequests, 'electrician_p_id');
//         }
//       }
//     } catch (e) {
//       print("Error fetching electrician requests: $e");
//     }
//   }

//   Future<void> fetchProfileNames(List requests, String key) async {
//     for (var request in requests) {
//       final int id = request[key];
//       if (!profileNames.containsKey(id)) {
//         final url = '$baseUrl/api/profile/$id'; // Adjust based on your API
//         try {
//           final response = await http.get(
//             Uri.parse(url),
//             headers: {
//               'Authorization': 'Bearer $token',
//               'Accept': 'application/json',
//             },
//           );

//           if (response.statusCode == 200) {
//             final data = json.decode(response.body);
//             if (data['success'] == true) {
//               final name = data['data']['name'];
//               setState(() {
//                 profileNames[id] = name;
//               });
//             }
//           }
//         } catch (e) {
//           print("Error fetching profile name: $e");
//         }
//       }
//     }
//   }

//   Widget buildRequestCard(Map request, String type) {
//     final imageUrl = request['p_problem_image'] != null
//         ? '$baseUrl/uploads/${type}_appointment_image/${request['p_problem_image']}'
//         : null;

//     final profileIdKey =
//         type == 'plumber' ? 'plumber_p_id' : 'electrician_p_id';
//     final profileId = request[profileIdKey];
//     final profileName = profileNames[profileId] ?? 'Loading...';

//     String statusText = 'Processing';
//     final status = request['status'];
//     if (status == 'accept') statusText = 'Accepted';
//     if (status == 'reject') statusText = 'Rejected';

//     Color statusColor;
//     switch (statusText) {
//       case 'Accepted':
//         statusColor = Colors.green;
//         break;
//       case 'Rejected':
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.orange;
//     }

//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       elevation: 3,
//       child: ListTile(
//         leading: imageUrl != null
//             ? GestureDetector(
//                 onTap: () => showDialog(
//                   context: context,
//                   builder: (_) => Dialog(
//                     child: Image.network(imageUrl, fit: BoxFit.cover),
//                   ),
//                 ),
//                 child: Image.network(
//                   imageUrl,
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                 ),
//               )
//             : Icon(Icons.image_not_supported),
//         title: Text('Service by: $profileName'),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Appointment ID: ${request['id']}'),
//             SizedBox(height: 4),
//             Text(request['description'] ?? 'No Description'),
//           ],
//         ),
//         trailing: Container(
//           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: statusColor.withOpacity(0.2),
//             border: Border.all(color: statusColor),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             statusText,
//             style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildEmptyState(String message) {
//     return Center(child: Text(message));
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Service Requests"),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: "Plumber"),
//             Tab(text: "Electrician"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           plumberRequests.isEmpty
//               ? buildEmptyState("No plumber requests found.")
//               : ListView.builder(
//                   itemCount: plumberRequests.length,
//                   itemBuilder: (context, index) {
//                     return buildRequestCard(plumberRequests[index], 'plumber');
//                   },
//                 ),
//           electricianRequests.isEmpty
//               ? buildEmptyState("No electrician requests found.")
//               : ListView.builder(
//                   itemCount: electricianRequests.length,
//                   itemBuilder: (context, index) {
//                     return buildRequestCard(
//                         electricianRequests[index], 'electrician');
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/Apis.dart'; // Make sure baseUrl is defined here

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List plumberRequests = [];
  List electricianRequests = [];
  Map<int, String> profileNames = {};
  String? userProfileId;
  String? token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadUserProfileAndFetch();
  }

  Future<void> loadUserProfileAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('bearer_token');
    userProfileId = prefs.get('user_profile_id')?.toString();

    if (userProfileId != null) {
      await Future.wait([
        fetchPlumberRequests(),
        fetchElectricianRequests(),
      ]);
    }
  }

  Future<void> fetchPlumberRequests() async {
    if (userProfileId == null) return;

    final url = '$baseUrl/api/plumber_appointment?user_p_id=$userProfileId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          setState(() {
            plumberRequests = decoded['data'];
          });
          await fetchProfileNames(plumberRequests, 'plumber_p_id');
        }
      }
    } catch (e) {
      print("Error fetching plumber requests: $e");
    }
  }

  Future<void> fetchElectricianRequests() async {
    if (userProfileId == null) return;

    final url = '$baseUrl/api/electrician_appointment?user_p_id=$userProfileId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          setState(() {
            electricianRequests = decoded['data'];
          });
          await fetchProfileNames(electricianRequests, 'electrician_p_id');
        }
      }
    } catch (e) {
      print("Error fetching electrician requests: $e");
    }
  }

  Future<void> fetchProfileNames(List requests, String key) async {
    for (var request in requests) {
      final int id = request[key];
      if (!profileNames.containsKey(id)) {
        final url = '$baseUrl/api/profile/$id';
        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              final name = data['data']['name'];
              setState(() {
                profileNames[id] = name;
              });
            }
          }
        } catch (e) {
          print("Error fetching profile name: $e");
        }
      }
    }
  }

  Widget buildRequestCard(Map request, String type) {
    final imageUrl = request['p_problem_image'] != null
        ? '$baseUrl/uploads/${type}_appointment_image/${request['p_problem_image']}'
        : null;

    final profileIdKey =
        type == 'plumber' ? 'plumber_p_id' : 'electrician_p_id';
    final profileId = request[profileIdKey];
    final profileName = profileNames[profileId] ?? 'Loading...';

    String statusText = 'Processing';
    final status = request['status'];
    if (status == 'accept') statusText = 'Accepted';
    if (status == 'reject') statusText = 'Rejected';

    Color statusColor;
    switch (statusText) {
      case 'Accepted':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: imageUrl != null
            ? GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.image_not_supported),
        title: Text('Service by: $profileName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment ID: ${request['id']}'),
            SizedBox(height: 4),
            Text(request['description'] ?? 'No Description'),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            border: Border.all(color: statusColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue, // Same as ProfileScreen background
      appBar: AppBar(
        title: Text("Service Requests"),
        backgroundColor: tealBlue, // Matching tealBlue AppBar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Plumber"),
            Tab(text: "Electrician"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          plumberRequests.isEmpty
              ? buildEmptyState("No plumber requests found.")
              : ListView.builder(
                  itemCount: plumberRequests.length,
                  itemBuilder: (context, index) {
                    return buildRequestCard(plumberRequests[index], 'plumber');
                  },
                ),
          electricianRequests.isEmpty
              ? buildEmptyState("No electrician requests found.")
              : ListView.builder(
                  itemCount: electricianRequests.length,
                  itemBuilder: (context, index) {
                    return buildRequestCard(
                        electricianRequests[index], 'electrician');
                  },
                ),
        ],
      ),
    );
  }
}
