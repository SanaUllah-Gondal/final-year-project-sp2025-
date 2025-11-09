import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appointment_booking_controller.dart';

class BiddingWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const BiddingWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentBookingController>(
      builder: (controller) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pricing Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Place your bid in the next step to book the appointment',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Price Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green[100]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow('Suggested Rate', 'Rs. ${controller.basePrice.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _buildPriceRow('Your Current Bid', 'Rs. ${controller.userBidPrice.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Minimum Bid',
                        'Rs. ${(controller.basePrice - 100).toStringAsFixed(0)}',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Complete the form above to enable bidding. You can adjust your bid in the next step.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? Colors.orange : Colors.green[700],
            fontWeight: FontWeight.bold,
            fontSize: isHighlighted ? 16 : 14,
          ),
        ),
      ],
    );
  }
}