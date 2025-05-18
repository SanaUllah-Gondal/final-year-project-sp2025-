import 'package:flutter/material.dart';
import 'package:plumber_project/pages/userservice/plumbermodel.dart';

class PlumberDetailPage extends StatelessWidget {
  final Plumber plumber;

  const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build the full URL for the plumber image
    final String imageUrl =
        plumber.plumberImage != null
            ? 'http://10.0.2.2:8000/uploads/plumber_image/${plumber.plumberImage}'
            : '';

    return Scaffold(
      appBar: AppBar(title: Text(plumber.fullName)),
      body: SingleChildScrollView(
        // ✅ added scroll to avoid overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipOval(
                child:
                    plumber.plumberImage != null
                        ? Image.network(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // if image not found
                            return Image.asset(
                              'assets/images/placeholder.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          'assets/images/placeholder.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              plumber.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildDetailRow('Experience', '${plumber.experience} years'),
            buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
            // buildDetailRow('Skill', plumber.skill ?? 'N/A'),
            // buildDetailRow('Service Area', plumber.serviceArea ?? 'N/A'),
            // buildDetailRow('Contact Number', plumber.contactNumber ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  // Helper Widget for clean details
  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
