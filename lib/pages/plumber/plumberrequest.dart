// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/Apis.dart'; // Replace with your baseUrl file

// final String imageBaseUrl = "$baseUrl/uploads/plumber_appointment/";

// class AppointmentList extends StatefulWidget {
//   @override
//   _AppointmentListState createState() => _AppointmentListState();
// }

// class _AppointmentListState extends State<AppointmentList> {
//   List<dynamic> appointments = [];
//   bool loading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchAppointments();
//   }

//   Future<void> fetchAppointments() async {
//     setState(() {
//       loading = true;
//       errorMessage = null;
//     });

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('bearer_token');

//       // ✅ Try plumber_id first, fallback to user_id
//       final int? plumberId =
//           prefs.getInt('plumber_id') ?? prefs.getInt('user_id');

//       if (token == null) {
//         setState(() {
//           loading = false;
//           errorMessage = "User is not logged in.";
//         });
//         return;
//       }

//       if (plumberId == null) {
//         setState(() {
//           loading = false;
//           errorMessage = "Plumber ID not found in local storage.";
//         });
//         return;
//       }

//       final url =
//           Uri.parse('$baseUrl/api/plumber_appointment?plumber_id=$plumberId');

//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);

//         if (jsonResponse['success'] == true) {
//           // ✅ Filter appointments where plumber_p_id == local plumberId
//           List<dynamic> allAppointments = jsonResponse['data'];
//           List<dynamic> filtered = allAppointments
//               .where((appointment) =>
//                   appointment['plumber_p_id']?.toString() ==
//                   plumberId.toString())
//               .toList();

//           setState(() {
//             appointments = filtered;
//             loading = false;
//           });
//         } else {
//           setState(() {
//             loading = false;
//             errorMessage =
//                 jsonResponse['message'] ?? "Failed to load appointments.";
//           });
//         }
//       } else {
//         setState(() {
//           loading = false;
//           errorMessage =
//               "Failed to load appointments (Status Code: ${response.statusCode})";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         loading = false;
//         errorMessage = "An error occurred: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Appointments')),
//       body: loading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(
//                   child: Text(
//                     errorMessage!,
//                     style: TextStyle(color: Colors.red, fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               : appointments.isEmpty
//                   ? Center(
//                       child: Text(
//                         "No appointments found.",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: appointments.length,
//                       itemBuilder: (context, index) {
//                         final appointment = appointments[index];
//                         final imageUrl = imageBaseUrl +
//                             (appointment['p_problem_image'] ?? '');
//                         return Card(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20)),
//                           margin: const EdgeInsets.only(bottom: 20),
//                           elevation: 5,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundImage:
//                                           imageUrl.trim().isNotEmpty
//                                               ? NetworkImage(imageUrl)
//                                               : null,
//                                       radius: 30,
//                                       backgroundColor: Colors.grey[300],
//                                       child: imageUrl.trim().isEmpty
//                                           ? Icon(Icons.plumbing,
//                                               size: 30, color: Colors.grey[700])
//                                           : null,
//                                     ),
//                                     SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Plumber Appointment #${appointment['id']}",
//                                             style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           Text(
//                                             "Plumbing Issue",
//                                             style: TextStyle(
//                                                 color: Colors.grey[600]),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 10),
//                                 Row(
//                                   children: const [
//                                     Icon(Icons.favorite,
//                                         color: Colors.red, size: 16),
//                                     SizedBox(width: 4),
//                                     Text("90% happy clients"),
//                                   ],
//                                 ),
//                                 Divider(height: 20),
//                                 Text(appointment['description'] ?? ''),
//                                 SizedBox(height: 12),
//                                 Center(
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       // TODO: Add booking logic here
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.purple,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 30, vertical: 12),
//                                     ),
//                                     child: Text(
//                                       'Book Consultation',
//                                       style: TextStyle(fontSize: 16),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

//000000000000000000000000000000000000000000000000000000000000000000000000000000000 yai code gallery may picture dikhaa raha hai
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:open_file/open_file.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:device_info_plus/device_info_plus.dart';

// final String imageBaseUrl = "$baseUrl/uploads/plumber_appointment_image/";

// class AppointmentList extends StatefulWidget {
//   @override
//   _AppointmentListState createState() => _AppointmentListState();
// }

// class _AppointmentListState extends State<AppointmentList> {
//   List<dynamic> appointments = [];
//   Map<int, String> userNames = {};
//   bool loading = true;
//   String? errorMessage;
//   late AndroidDeviceInfo androidInfo;

//   @override
//   void initState() {
//     super.initState();
//     initDeviceInfo();
//     fetchAppointments();
//   }

//   Future<void> initDeviceInfo() async {
//     androidInfo = await DeviceInfoPlugin().androidInfo;
//   }

//   Future<void> fetchAppointments() async {
//     setState(() {
//       loading = true;
//       errorMessage = null;
//     });

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('bearer_token');
//       final int? plumberId =
//           prefs.getInt('plumber_profile_id') ?? prefs.getInt('user_id');

//       if (token == null || plumberId == null) {
//         setState(() {
//           loading = false;
//           errorMessage = "User is not logged in or ID not found.";
//         });
//         return;
//       }

//       final url = Uri.parse(
//           '$baseUrl/api/plumber_appointment?plumber_profile_id=$plumberId');
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         if (jsonResponse['success'] == true) {
//           List<dynamic> allAppointments = jsonResponse['data'];
//           List<dynamic> filtered = allAppointments
//               .where(
//                   (a) => a['plumber_p_id'].toString() == plumberId.toString())
//               .toList();

//           await fetchUserNames(filtered, token);

//           setState(() {
//             appointments = filtered;
//             loading = false;
//           });
//         } else {
//           setState(() {
//             loading = false;
//             errorMessage =
//                 jsonResponse['message'] ?? "Failed to load appointments.";
//           });
//         }
//       } else {
//         setState(() {
//           loading = false;
//           errorMessage = "Failed with status: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         loading = false;
//         errorMessage = "Error: $e";
//       });
//     }
//   }

//   Future<void> fetchUserNames(List appointments, String token) async {
//     Set<int> userIds = {
//       for (var a in appointments)
//         if (a['user_p_id'] != null) a['user_p_id']
//     };

//     for (int id in userIds) {
//       if (!userNames.containsKey(id)) {
//         try {
//           final url = Uri.parse('$baseUrl/api/users/$id');
//           final res = await http.get(url, headers: {
//             'Authorization': 'Bearer $token',
//             'Accept': 'application/json',
//           });

//           if (res.statusCode == 200) {
//             final data = json.decode(res.body);
//             final user = data['data'];
//             userNames[id] =
//                 user != null && user['name'] != null ? user['name'] : 'Unknown';
//           } else {
//             userNames[id] = 'Unknown';
//           }
//         } catch (e) {
//           userNames[id] = 'Unknown';
//         }
//       }
//     }
//     setState(() {});
//   }

//   Future<void> downloadAndOpenImage(String fileName) async {
//     if (Platform.isAndroid) {
//       int sdkInt = androidInfo.version.sdkInt ?? 0;

//       PermissionStatus status;
//       if (sdkInt >= 33) {
//         status = await Permission.photos.request();
//       } else {
//         status = await Permission.storage.request();
//       }

//       if (!status.isGranted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Storage permission is required")),
//         );
//         return;
//       }
//     }

//     final url = "$imageBaseUrl$fileName";
//     print("Downloading image from: $url");
//     final response = await http.get(Uri.parse(url));
//     print("Response status: ${response.statusCode}");

//     if (response.statusCode == 200) {
//       final dir = await getTemporaryDirectory();
//       final filePath = '${dir.path}/$fileName';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//       await OpenFile.open(filePath);
//     } else {
//       print("Failed to download image: ${response.body}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text("Failed to download image: ${response.statusCode}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Appointments')),
//       body: loading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(
//                   child: Text(
//                     errorMessage!,
//                     style: TextStyle(color: Colors.red, fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               : appointments.isEmpty
//                   ? Center(child: Text("No appointments found."))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: appointments.length,
//                       itemBuilder: (context, index) {
//                         final appointment = appointments[index];
//                         final userId = appointment['user_p_id'];
//                         final userName = userNames[userId] ?? 'Fetching...';
//                         final description = appointment['description'] ?? '';
//                         final imageFile = appointment['p_problem_image'] ?? '';

//                         return Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           margin: const EdgeInsets.only(bottom: 20),
//                           elevation: 5,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "User: $userName",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "Issue: $description",
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                                 SizedBox(height: 16),
//                                 imageFile.isNotEmpty
//                                     ? TextButton(
//                                         onPressed: () {
//                                           downloadAndOpenImage(imageFile);
//                                         },
//                                         child: Text(
//                                           "View Image",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             decoration:
//                                                 TextDecoration.underline,
//                                             color: Colors.blue,
//                                           ),
//                                         ),
//                                       )
//                                     : Text("No image provided"),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:device_info_plus/device_info_plus.dart';

final String imageBaseUrl = "$baseUrl/uploads/plumber_appointment_image/";

class AppointmentList extends StatefulWidget {
  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  List<dynamic> appointments = [];
  Map<int, String> userNames = {};
  bool loading = true;
  String? errorMessage;
  late AndroidDeviceInfo androidInfo;

  @override
  void initState() {
    super.initState();
    initDeviceInfo();
    fetchAppointments();
  }

  Future<void> initDeviceInfo() async {
    androidInfo = await DeviceInfoPlugin().androidInfo;
  }

  Future<void> fetchAppointments() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('bearer_token');
      final int? plumberId =
          prefs.getInt('plumber_profile_id') ?? prefs.getInt('user_id');

      if (token == null || plumberId == null) {
        setState(() {
          loading = false;
          errorMessage = "User is not logged in or ID not found.";
        });
        return;
      }

      final url = Uri.parse(
          '$baseUrl/api/plumber_appointment?plumber_profile_id=$plumberId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          List<dynamic> allAppointments = jsonResponse['data'];
          List<dynamic> filtered = allAppointments
              .where(
                  (a) => a['plumber_p_id']?.toString() == plumberId.toString())
              .toList();

          await fetchUserNames(filtered, token);

          setState(() {
            appointments = filtered;
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
            errorMessage =
                jsonResponse['message'] ?? "Failed to load appointments.";
          });
        }
      } else {
        setState(() {
          loading = false;
          errorMessage = "Failed with status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  Future<void> fetchUserNames(List<dynamic> appointments, String token) async {
    Set<int> userIds = {
      for (var a in appointments)
        if (a['user_p_id'] != null) a['user_p_id'] as int
    };

    for (int id in userIds) {
      if (!userNames.containsKey(id)) {
        try {
          final url = Uri.parse('$baseUrl/api/users/$id');
          final res = await http.get(url, headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });

          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            final user = data['data'];
            userNames[id] =
                user != null && user['name'] != null ? user['name'] : 'Unknown';
            print("Fetched userName for $id: ${userNames[id]}");
          } else {
            userNames[id] = 'Unknown';
          }
        } catch (e) {
          userNames[id] = 'Unknown';
        }
      }
    }
    setState(() {});
  }

  Future<void> downloadAndOpenImage(String fileName) async {
    if (Platform.isAndroid) {
      int sdkInt = androidInfo.version.sdkInt ?? 0;

      PermissionStatus status;
      if (sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission is required")),
        );
        return;
      }
    }

    final url = "$imageBaseUrl$fileName";
    print("Downloading image from: $url");
    final response = await http.get(Uri.parse(url));
    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(filePath);
    } else {
      print("Failed to download image: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to download image: ${response.statusCode}")),
      );
    }
  }

  Future<void> acceptAppointment(int appointmentId) async {
    // Implement your API call to accept appointment here
    print('Accept clicked for appointment ID: $appointmentId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Accepted appointment $appointmentId')),
    );
    // Refresh or update your list here if needed
  }

  Future<void> declineAppointment(int appointmentId) async {
    // Implement your API call to decline appointment here
    print('Decline clicked for appointment ID: $appointmentId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Declined appointment $appointmentId')),
    );
    // Refresh or update your list here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointments')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : appointments.isEmpty
                  ? Center(child: Text("No appointments found."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        final userId = appointment['user_p_id'];
                        final userName =
                            (userId != null && userNames.containsKey(userId))
                                ? userNames[userId]
                                : 'Fetching...';
                        final description = appointment['description'] ?? '';
                        final imageFile = appointment['p_problem_image'] ?? '';
                        final appointmentId = appointment['id'];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "User: $userName",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Issue: $description",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 16),
                                imageFile.isNotEmpty
                                    ? TextButton(
                                        onPressed: () {
                                          downloadAndOpenImage(imageFile);
                                        },
                                        child: Text(
                                          "View Image",
                                          style: TextStyle(
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      )
                                    : Text("No image provided"),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () =>
                                          acceptAppointment(appointmentId),
                                      child: Text('Accept'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () =>
                                          declineAppointment(appointmentId),
                                      child: Text('Decline'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:open_file/open_file.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:device_info_plus/device_info_plus.dart';

// final String imageBaseUrl = "$baseUrl/uploads/plumber_appointment_image/";

// class AppointmentList extends StatefulWidget {
//   @override
//   _AppointmentListState createState() => _AppointmentListState();
// }

// class _AppointmentListState extends State<AppointmentList> {
//   List<dynamic> appointments = [];
//   Map<int, String> userNames = {};
//   bool loading = true;
//   String? errorMessage;
//   late AndroidDeviceInfo androidInfo;

//   @override
//   void initState() {
//     super.initState();
//     initDeviceInfo();
//     fetchAppointments();
//   }

//   Future<void> initDeviceInfo() async {
//     androidInfo = await DeviceInfoPlugin().androidInfo;
//   }

//   Future<void> fetchAppointments() async {
//     setState(() {
//       loading = true;
//       errorMessage = null;
//     });

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('bearer_token');
//       final int? plumberProfileId = prefs.getInt('plumber_profile_id');

//       if (token == null || plumberProfileId == null) {
//         setState(() {
//           loading = false;
//           errorMessage = "User is not logged in or plumber profile missing.";
//         });
//         return;
//       }

//       final url = Uri.parse('$baseUrl/api/plumber_appointment');
//       final response = await http.get(url, headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         if (jsonResponse['success'] == true) {
//           List<dynamic> allAppointments = jsonResponse['data'];

//           List<dynamic> filtered = allAppointments
//               .where((a) => a['plumber_p_id'] == plumberProfileId)
//               .toList();

//           await fetchAllProfiles(token);

//           setState(() {
//             appointments = filtered;
//             loading = false;
//           });
//         } else {
//           setState(() {
//             loading = false;
//             errorMessage =
//                 jsonResponse['message'] ?? "Failed to load appointments.";
//           });
//         }
//       } else {
//         setState(() {
//           loading = false;
//           errorMessage = "Failed with status: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         loading = false;
//         errorMessage = "Error: $e";
//       });
//     }
//   }

//   Future<void> fetchAllProfiles(String token) async {
//     final url = Uri.parse('$baseUrl/api/profiles');
//     final res = await http.get(url, headers: {
//       'Authorization': 'Bearer $token',
//       'Accept': 'application/json',
//     });

//     if (res.statusCode == 200) {
//       final data = json.decode(res.body);
//       final List profiles = data['data'];

//       for (var profile in profiles) {
//         final profileId = profile['profile_id'];
//         final fullName = profile['full_name'] ?? 'Unknown';
//         userNames[profileId] = fullName;
//       }
//     }
//     setState(() {});
//   }

//   Future<void> downloadAndOpenImage(String fileName) async {
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       int sdkInt = androidInfo.version.sdkInt ?? 0;

//       PermissionStatus status;
//       if (sdkInt >= 33) {
//         status = await Permission.photos.request();
//       } else {
//         status = await Permission.storage.request();
//       }

//       if (!status.isGranted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text("Storage permission is required to view images.")),
//         );
//         return;
//       }
//     }

//     final imageUrl = "$imageBaseUrl$fileName";
//     print("Downloading image from: $imageUrl");

//     try {
//       final response = await http.get(Uri.parse(imageUrl));

//       if (response.statusCode == 200) {
//         final dir = await getTemporaryDirectory();
//         final filePath = '${dir.path}/$fileName';
//         final file = File(filePath);
//         await file.writeAsBytes(response.bodyBytes);
//         await OpenFile.open(filePath);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text("Failed to download image: ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       print("Image download error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error opening image: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Appointments')),
//       body: loading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(
//                   child: Text(
//                     errorMessage!,
//                     style: TextStyle(color: Colors.red, fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               : appointments.isEmpty
//                   ? Center(child: Text("No appointments found."))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: appointments.length,
//                       itemBuilder: (context, index) {
//                         final appointment = appointments[index];
//                         final userId = appointment['user_p_id'];
//                         final userName = userNames[userId] ?? 'Fetching...';
//                         final description = appointment['description'] ?? '';
//                         final imageFile = appointment['p_problem_image'] ?? '';

//                         return Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           margin: const EdgeInsets.only(bottom: 20),
//                           elevation: 5,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "User: $userName",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "Issue: $description",
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                                 SizedBox(height: 16),
//                                 imageFile.isNotEmpty
//                                     ? TextButton(
//                                         onPressed: () {
//                                           downloadAndOpenImage(imageFile);
//                                         },
//                                         child: Text(
//                                           "View Image",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             decoration:
//                                                 TextDecoration.underline,
//                                             color: Colors.blue,
//                                           ),
//                                         ),
//                                       )
//                                     : Text("No image provided"),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }
