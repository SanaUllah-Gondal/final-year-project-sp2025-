import 'package:flutter/material.dart';

import '../controllers/appointment_booking_controller.dart';


class PriceSummaryWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const PriceSummaryWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Base Price:'),
                Text('\$${controller.basePrice.toStringAsFixed(2)}'),
              ],
            ),
            if (controller.appointmentType == 'emergency') ...[
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Emergency Fee (20%):', style: TextStyle(color: Colors.orange)),
                  Text('+\$${(controller.basePrice * 0.2).toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.orange)),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${controller.finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}