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
              // Optional: Show a dialog or navigate
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
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
