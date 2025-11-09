import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plumber_project/pages/users/widgets/price_summary_widget.dart';
import 'package:plumber_project/pages/users/widgets/provider_info_widget.dart';
import 'package:plumber_project/pages/users/widgets/bidding_widget.dart';

import '../controllers/appointment_booking_controller.dart';
import 'appointment_form_widget.dart';
import 'error_widget.dart';
import 'loading_widget.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceType;
  final Position userLocation;
  final double basePrice;
  final double? distance;

  const AppointmentBookingScreen({
    Key? key,
    required this.provider,
    required this.serviceType,
    required this.userLocation,
    required this.basePrice,
    this.distance,
  }) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  late AppointmentBookingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppointmentBookingController(
      provider: widget.provider,
      serviceType: widget.serviceType,
      userLocation: widget.userLocation,
      basePrice: widget.basePrice,
      distance: widget.distance,
    );
    print('🔧 AppointmentBookingScreen initialized for ${widget.serviceType}');
    print('💰 Base Price: Rs. ${widget.basePrice}');
    print('📍 Distance: ${widget.distance?.toStringAsFixed(1)} km');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.serviceType} Appointment'),
        backgroundColor: _controller.providerColor,
      ),
      body: GetBuilder<AppointmentBookingController>(
        init: _controller,
        builder: (controller) {
          if (controller.isLoading) {
            return const LoadingWidget();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                if (controller.errorMessage != null)
                  ErrorCard(message: controller.errorMessage!),

                // Distance and Rate Information Card
                if (controller.distance != null)
                  _buildDistanceInfoCard(controller),

                ProviderInfoWidget(controller: controller),
                const SizedBox(height: 20),

                // Bidding Widget
                BiddingWidget(controller: controller),
                const SizedBox(height: 20),

                PriceSummaryWidget(controller: controller),
                const SizedBox(height: 20),
                AppointmentFormWidget(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDistanceInfoCard(AppointmentBookingController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Distance Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distance to provider:',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${controller.distance!.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suggested rate:',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Rs. ${controller.basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getRateCalculationInfo(controller.serviceType),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRateCalculationInfo(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plumber':
        return 'Rate calculated at Rs. 50 per km (Minimum: Rs. 500)';
      case 'cleaner':
        return 'Rate calculated at Rs. 30 per km (Minimum: Rs. 300)';
      case 'electrician':
        return 'Rate calculated at Rs. 60 per km (Minimum: Rs. 600)';
      default:
        return 'Rate calculated based on distance traveled';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}