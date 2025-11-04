import 'package:flutter/material.dart';

import '../controllers/appointment_booking_controller.dart';
import 'map_utils.dart';


class ProviderInfoWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const ProviderInfoWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerType = controller.provider['provider_type']?.toString().toLowerCase() ??
        controller.serviceType.toLowerCase();
    final providerColor = getColorForProviderType(providerType);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: providerColor.withOpacity(0.2),
              radius: 25,
              child: getProviderIcon(providerType, providerColor, 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.provider['name'] ?? 'Provider',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    providerType.toUpperCase(),
                    style: TextStyle(
                      color: providerColor,
                      fontSize: 12,
                    ),
                  ),
                  if (controller.provider['rating'] != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${controller.provider['rating']}'),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}