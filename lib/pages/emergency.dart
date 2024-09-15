// import 'package:flutter/material.dart';

// class EmergencyScreen extends StatelessWidget {
//   const EmergencyScreen({super.key});

//   final List<Map<String, dynamic>> services = const [
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
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Emergency Services"),
//         backgroundColor: Colors.red,
//       ),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(12),
//         itemCount: services.length,
//         itemBuilder: (context, index) {
//           final service = services[index];
//           return ListTile(
//             leading: Icon(service["icon"], color: Colors.red),
//             title: Text(
//               service["title"],
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               // Optional: Show a dialog or navigate
//               showDialog(
//                 context: context,
//                 builder:
//                     (_) => AlertDialog(
//                       title: Text(service["title"]),
//                       content: Text(
//                         "You tapped on ${service["title"]} (Emergency)",
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: Text("OK"),
//                         ),
//                       ],
//                     ),
//               );
//             },
//           );
//         },
//         separatorBuilder: (context, index) => Divider(),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class EmergencyScreen extends StatelessWidget {
//   const EmergencyScreen({super.key});

//   final List<Map<String, dynamic>> services = const [
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
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Emergency Services"),
//         backgroundColor: Colors.red,
//       ),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(12),
//         itemCount: services.length,
//         itemBuilder: (context, index) {
//           final service = services[index];
//           return ListTile(
//             leading: Icon(service["icon"], color: Colors.red),
//             title: Text(
//               service["title"],
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               if (service["title"] == "Plumber") {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => PlumberServicesPage()),
//                 );
//               } else if (service["title"] == "Electrician") {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => ElectricianServicesPage()),
//                 );
//               } else {
//                 showDialog(
//                   context: context,
//                   builder:
//                       (_) => AlertDialog(
//                         title: Text(service["title"]),
//                         content: Text(
//                           "You tapped on ${service["title"]} (Emergency)",
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text("OK"),
//                           ),
//                         ],
//                       ),
//                 );
//               }
//             },
//           );
//         },
//         separatorBuilder: (context, index) => Divider(),
//       ),
//     );
//   }
// }

// class PlumberServicesPage extends StatelessWidget {
//   final List<String> plumberServices = const [
//     "Washbasin Repair",
//     "Tap Leakage Fix",
//     "Toilet Installation",
//     "Drain Cleaning",
//     "Pipe Blockage",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Plumber Services"),
//         backgroundColor: Colors.red,
//       ),
//       body: ListView.builder(
//         itemCount: plumberServices.length,
//         itemBuilder: (context, index) {
//           final serviceName = plumberServices[index];
//           return ListTile(
//             title: Text(serviceName),
//             leading: Icon(Icons.build, color: Colors.red),
//             trailing: Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) =>
//                           PlumberSubServiceDetailPage(serviceName: serviceName),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class PlumberSubServiceDetailPage extends StatelessWidget {
//   final String serviceName;

//   const PlumberSubServiceDetailPage({super.key, required this.serviceName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(serviceName), backgroundColor: Colors.red),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Text(
//             "$serviceName Details and Booking Info Coming Soon!",
//             style: TextStyle(fontSize: 18),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ElectricianServicesPage extends StatelessWidget {
//   final List<String> electricianServices = const [
//     "Board Repair",
//     "Short Circuit Fix",
//     "Light Installation",
//     "Fan Repair",
//     "Switch Replacement",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Electrician Services"),
//         backgroundColor: Colors.red,
//       ),
//       body: ListView.builder(
//         itemCount: electricianServices.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(electricianServices[index]),
//             leading: Icon(Icons.electrical_services, color: Colors.red),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  final List<Map<String, dynamic>> services = const [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Services"),
        backgroundColor: Colors.red,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ListTile(
            leading: Icon(service["icon"], color: Colors.red),
            title: Text(
              service["title"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (service["title"] == "Plumber") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlumberServicesPage()),
                );
              } else if (service["title"] == "Electrician") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ElectricianServicesPage()),
                );
              } else {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text(service["title"]),
                        content: Text(
                          "You tapped on ${service["title"]} (Emergency)",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                );
              }
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}

// ------------------ PLUMBER SECTION ------------------

class PlumberServicesPage extends StatelessWidget {
  final List<String> plumberServices = const [
    "Washbasin Repair",
    "Tap Leakage Fix",
    "Toilet Installation",
    "Drain Cleaning",
    "Pipe Blockage",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plumber Services"),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: plumberServices.length,
        itemBuilder: (context, index) {
          final serviceName = plumberServices[index];
          return ListTile(
            title: Text(serviceName),
            leading: Icon(Icons.build, color: Colors.red),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          PlumberSubServiceDetailPage(serviceName: serviceName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlumberSubServiceDetailPage extends StatelessWidget {
  final String serviceName;

  const PlumberSubServiceDetailPage({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceName), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "$serviceName Details and Booking Info Coming Soon!",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ------------------ ELECTRICIAN SECTION ------------------

class ElectricianServicesPage extends StatelessWidget {
  final List<String> electricianServices = const [
    "Board Repair",
    "Short Circuit Fix",
    "Light Installation",
    "Fan Repair",
    "Switch Replacement",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Electrician Services"),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: electricianServices.length,
        itemBuilder: (context, index) {
          final serviceName = electricianServices[index];
          return ListTile(
            title: Text(serviceName),
            leading: Icon(Icons.electrical_services, color: Colors.red),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ElectricianSubServiceDetailPage(
                        serviceName: serviceName,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ElectricianSubServiceDetailPage extends StatelessWidget {
  final String serviceName;

  const ElectricianSubServiceDetailPage({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceName), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "$serviceName Details and Booking Info Coming Soon!",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
