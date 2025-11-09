import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appointment_booking_controller.dart';

class BidPopupWidget extends StatefulWidget {
  final AppointmentBookingController controller;

  const BidPopupWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<BidPopupWidget> createState() => _BidPopupWidgetState();
}

class _BidPopupWidgetState extends State<BidPopupWidget> {
  late double currentBid;

  @override
  void initState() {
    super.initState();
    currentBid = widget.controller.userBidPrice;
  }

  @override
  Widget build(BuildContext context) {
    final double minBid = widget.controller.basePrice - 100;
    final bool isBidValid = currentBid >= minBid;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Place Your Bid',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Summary
                  _buildServiceSummary(),
                  const SizedBox(height: 24),

                  // Current Bid Display
                  _buildBidDisplay(isBidValid, minBid),
                  const SizedBox(height: 24),

                  // Bid Controls
                  _buildBidControls(minBid),
                  const SizedBox(height: 24),

                  // Quick Bid Buttons
                  _buildQuickBidButtons(minBid),
                  const SizedBox(height: 32),

                  // Price Breakdown
                  _buildPriceBreakdown(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(isBidValid),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.controller.serviceType} • ${widget.controller.formatServiceType(widget.controller.selectedServiceType!)}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${widget.controller.dateController.text}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Time: ${widget.controller.timeController.text}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBidDisplay(bool isBidValid, double minBid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBidValid ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBidValid ? Colors.green[100]! : Colors.orange[100]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Bid Amount',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rs. ${currentBid.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isBidValid ? Colors.green[700]! : Colors.orange[700]!,
            ),
          ),
          if (!isBidValid) ...[
            const SizedBox(height: 8),
            Text(
              'Minimum bid: Rs. ${minBid.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBidControls(double minBid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjust Your Bid:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Decrease Button
            _buildBidButton(
              icon: Icons.remove,
              color: Colors.red[400]!,
              onPressed: () {
                final newPrice = currentBid - 50;
                if (newPrice >= minBid) {
                  setState(() {
                    currentBid = newPrice;
                  });
                }
              },
            ),
            const SizedBox(width: 16),

            // Slider
            Expanded(
              child: Slider(
                value: currentBid,
                min: minBid,
                max: widget.controller.basePrice + 500,
                divisions: ((widget.controller.basePrice + 500 - minBid) / 50).round(),
                label: 'Rs. ${currentBid.toStringAsFixed(0)}',
                onChanged: (value) {
                  setState(() {
                    currentBid = value;
                  });
                },
                activeColor: _getSliderColor(currentBid, minBid),
                inactiveColor: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 16),

            // Increase Button
            _buildBidButton(
              icon: Icons.add,
              color: Colors.green[400]!,
              onPressed: () {
                final newPrice = currentBid + 50;
                setState(() {
                  currentBid = newPrice;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rs. ${minBid.toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'Rs. ${(widget.controller.basePrice + 500).toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickBidButtons(double minBid) {
    final quickBids = [
      {'label': 'Min Bid', 'amount': minBid, 'color': Colors.orange},
      {'label': 'Suggested', 'amount': widget.controller.basePrice, 'color': Colors.blue},
      {'label': '+Rs. 100', 'amount': widget.controller.basePrice + 100, 'color': Colors.green},
      {'label': '+Rs. 200', 'amount': widget.controller.basePrice + 200, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Bid:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: quickBids.map((bid) {
            return ActionChip(
              label: Text(
                '${bid['label']}\nRs. ${(bid['amount'] as double).toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: (bid['color'] as Color).withOpacity(0.1),
              labelStyle: TextStyle(
                color: bid['color'] as Color,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: (bid['color'] as Color).withOpacity(0.3),
                ),
              ),
              onPressed: () {
                setState(() {
                  currentBid = bid['amount'] as double;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final emergencySurcharge = widget.controller.appointmentType == 'emergency' ? currentBid * 0.2 : 0;
    final totalPrice = currentBid + emergencySurcharge;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Your Bid', 'Rs. ${currentBid.toStringAsFixed(0)}'),
          if (widget.controller.appointmentType == 'emergency') ...[
            _buildPriceRow('Emergency Surcharge (20%)', 'Rs. ${emergencySurcharge.toStringAsFixed(0)}'),
          ],
          const Divider(height: 20),
          _buildPriceRow(
            'Total Amount',
            'Rs. ${totalPrice.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isBidValid) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isBidValid
                ? () {
              widget.controller.updateBidPrice(currentBid);
              widget.controller.confirmBidAndBook();
              Navigator.of(context).pop();
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.controller.providerColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm & Book',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBidButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 20,
      ),
    );
  }

  Color _getSliderColor(double currentPrice, double minPrice) {
    if (currentPrice < minPrice) return Colors.orange;
    if (currentPrice == minPrice) return Colors.blue;
    return Colors.green;
  }
}