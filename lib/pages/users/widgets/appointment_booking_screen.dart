import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plumber_project/pages/users/widgets/price_summary_widget.dart';
import 'package:plumber_project/pages/users/widgets/provider_info_widget.dart';

import '../controllers/appointment_booking_controller.dart';
import 'appointment_form_widget.dart';
import 'error_widget.dart';
import 'loading_widget.dart';


class AppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceType;
  final Position userLocation;
  final double basePrice;

  const AppointmentBookingScreen({
    Key? key,
    required this.provider,
    required this.serviceType,
    required this.userLocation,
    required this.basePrice,
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
    );
    print('🔧 AppointmentBookingScreen initialized for ${widget.serviceType}');
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

                ProviderInfoWidget(controller: controller),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}