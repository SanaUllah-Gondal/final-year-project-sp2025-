import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appointment_booking_controller.dart';

class PriceSummaryWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const PriceSummaryWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentBookingController>(
      builder: (controller) {
        final double minBid = controller.basePrice - 100;
        final bool isBidValid = controller.finalPrice >= minBid;
        final double emergencySurcharge = controller.appointmentType == 'emergency'
            ? controller.finalPrice * 0.2
            : 0;
        final double totalAmount = controller.finalPrice;

        return Card(
          elevation: 3,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.purple[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Price Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Suggested Price
                _buildPriceRow(
                  'Suggested Rate:',
                  'Rs. ${controller.basePrice.toStringAsFixed(0)}',
                  Colors.grey[700]!,
                ),
                const SizedBox(height: 8),

                // Your Bid
                _buildPriceRow(
                  'Your Bid:',
                  'Rs. ${controller.finalPrice.toStringAsFixed(0)}',
                  isBidValid ? Colors.green[700]! : Colors.orange[700]!,
                ),
                const SizedBox(height: 8),

                // Emergency Surcharge
                if (controller.appointmentType == 'emergency')
                  _buildPriceRow(
                    'Emergency Surcharge (20%):',
                    '+ Rs. ${emergencySurcharge.toStringAsFixed(0)}',
                    Colors.orange[700]!,
                  ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Total Amount
                _buildPriceRow(
                  'Total Amount:',
                  'Rs. ${totalAmount.toStringAsFixed(0)}',
                  Colors.green[700]!,
                  isBold: true,
                  fontSize: 16,
                ),

                // Bid Validation Message
                if (!isBidValid) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Minimum bid: Rs. ${minBid.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Success Message for valid bids
                if (isBidValid && controller.finalPrice > controller.basePrice) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up_rounded,
                          color: Colors.green[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Great bid! This will attract more providers.',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value, Color color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}