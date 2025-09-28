import 'package:flutter/material.dart';

import '../controllers/appointment_booking_controller.dart';
import 'image_upload_widget.dart';


class AppointmentFormWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const AppointmentFormWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppointmentTypeSection(),
        const SizedBox(height: 16),
        _buildServiceTypeDropdown(),
        const SizedBox(height: 16),
        _buildDateTimeSection(context),
        const SizedBox(height: 16),
        _buildAddressField(),
        const SizedBox(height: 16),
        _buildDescriptionField(),
        const SizedBox(height: 16),
        ImageUploadWidget(controller: controller),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildAppointmentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Type *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Normal'),
                selected: controller.appointmentType == 'normal',
                onSelected: (selected) {
                  controller.updateAppointmentType('normal');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('Emergency (+20%)'),
                selected: controller.appointmentType == 'emergency',
                onSelected: (selected) {
                  controller.updateAppointmentType('emergency');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.selectedServiceType,
      decoration: const InputDecoration(
        labelText: 'Service Type *',
        border: OutlineInputBorder(),
      ),
      items: controller.getServiceTypeOptions().map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(controller.formatServiceType(value)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        controller.updateServiceType(newValue);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a service type';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.dateController,
            decoration: const InputDecoration(
              labelText: 'Date *',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => controller.selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller.timeController,
            decoration: const InputDecoration(
              labelText: 'Time *',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            readOnly: true,
            onTap: () => controller.selectTime(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a time';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: controller.addressController,
      decoration: const InputDecoration(
        labelText: 'Service Address *',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the service address';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: controller.descriptionController,
      decoration: const InputDecoration(
        labelText: 'Problem Description *',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please describe the problem';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: controller.isLoading ? null : () => controller.submitAppointment(),
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.providerColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.calendar_today, color: Colors.white),
      label: controller.isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Text(
        'Confirm Appointment Booking',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}