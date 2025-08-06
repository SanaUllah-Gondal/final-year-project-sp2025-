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

final Color darkBlue = Color(0xFF003E6B);
final Color tealColor = Color(0xFF008080); // Changed to teal for cleaner theme

final String imageBaseUrl = "$baseUrl/uploads/cleaner_appointment_image/";

class CleanerAppointmentList extends StatefulWidget {
  @override
  _CleanerAppointmentListState createState() => _CleanerAppointmentListState();
}

class _CleanerAppointmentListState extends State<CleanerAppointmentList> {
  List<dynamic> appointments = [];
  Map<int, Map<String, dynamic>> userDetails = {};
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
      final int? cleanerId = prefs.getInt('cleaner_profile_id') ?? prefs.getInt('user_id');

      if (token == null || cleanerId == null) {
        setState(() {
          loading = false;
          errorMessage = "User is not logged in or ID not found.";
        });
        return;
      }

      final url = Uri.parse('$baseUrl/api/cleaner_appointment?cleaner_profile_id=$cleanerId');
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

          List<dynamic> filtered = allAppointments.where((a) {
            final belongsToCleaner =
                a['cleaner_p_id']?.toString() == cleanerId.toString();
            final notRejected = a['status'] == null ||
                a['status'].toString().toLowerCase() != 'reject';
            return belongsToCleaner && notRejected;
          }).toList();

          await fetchUserDetails(filtered, token);

          setState(() {
            appointments = filtered;
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
            errorMessage = jsonResponse['message'] ?? "Failed to load appointments.";
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

  Future<void> fetchUserDetails(List<dynamic> appointments, String token) async {
    Set<int> userIds = {
      for (var a in appointments)
        if (a['user_p_id'] != null) a['user_p_id'] as int
    };

    for (int id in userIds) {
      if (!userDetails.containsKey(id)) {
        try {
          final url = Uri.parse('$baseUrl/api/users/$id');
          final res = await http.get(url, headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });

          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            final user = data['data'];
            userDetails[id] = {
              'name': user != null && user['name'] != null ? user['name'] : 'Unknown',
              'location': user != null && user['location'] != null ? user['location'] : 'Location not specified'
            };
          } else {
            userDetails[id] = {
              'name': 'Unknown',
              'location': 'Location not specified'
            };
          }
        } catch (e) {
          userDetails[id] = {
            'name': 'Unknown',
            'location': 'Location not specified'
          };
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
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download image")),
      );
    }
  }

  Future<void> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('bearer_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not authenticated")),
        );
        return;
      }

      final url = Uri.parse('$baseUrl/api/Accept_C_Appointment/$appointmentId');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {'status': status},
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment $status successfully')),
        );
        fetchAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: tealColor,
        title: Text('Cleaning Requests', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAppointments,
          ),
        ],
      ),
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
          ? Center(
        child: Text(
          "No cleaning appointments found!",
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final userName = userDetails[appointment['user_p_id']]?['name'] ?? 'Fetching...';
          final userLocation = userDetails[appointment['user_p_id']]?['location'] ?? 'Location not specified';
          final description = appointment['description'] ?? '';
          final cleaningType = appointment['cleaning_type'] ?? 'Not specified';
          final imageFile = appointment['c_problem_image'] ?? '';
          final appointmentId = appointment['id'];
          final status = appointment['status']?.toLowerCase();

          return Card(
            color: tealColor.withOpacity(0.2),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name Section
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Location Section
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.yellow),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userLocation,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Cleaning Type Section
                  Row(
                    children: [
                      Icon(Icons.cleaning_services, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        'Type: $cleaningType',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Issue Description Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description, color: Colors.yellow),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Image Section
                  imageFile.isNotEmpty
                      ? Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.image, color: Colors.yellow),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              downloadAndOpenImage(imageFile);
                            },
                            child: Text(
                              "View Cleaning Area Image",
                              style: TextStyle(
                                color: Colors.yellow,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  )
                      : SizedBox(),

                  // Action Buttons
                  if (status == 'accept')
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "Accepted",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.yellow,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () => updateAppointmentStatus(
                              appointmentId, 'accept'),
                          child: Text('Accept Cleaning Job'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.yellow,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () => updateAppointmentStatus(
                              appointmentId, 'reject'),
                          child: Text('Decline Cleaning Job'),
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