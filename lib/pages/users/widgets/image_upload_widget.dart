import 'package:flutter/material.dart';

import '../controllers/appointment_booking_controller.dart';


class ImageUploadWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const ImageUploadWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload image of the problem (optional)'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: controller.pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Select Image'),
        ),
        if (controller.problemImage != null) ...[
          const SizedBox(height: 8),
          Stack(
            children: [
              Image.file(
                controller.problemImage!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 15, color: Colors.white),
                    onPressed: controller.removeImage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}