import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appointment_booking_controller.dart';
import 'advanced_datetime_picker.dart';
import 'image_upload_widget.dart';
import 'bid_popup_widget.dart';

class AppointmentFormWidget extends StatelessWidget {
  final AppointmentBookingController controller;

  const AppointmentFormWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppointmentTypeSection(),
        const SizedBox(height: 20),
        _buildServiceTypeDropdown(),
        const SizedBox(height: 20),
        _buildDateTimePicker(context),
        const SizedBox(height: 20),
        _buildAddressField(),
        const SizedBox(height: 20),
        _buildDescriptionField(),
        const SizedBox(height: 20),
        ImageUploadWidget(controller: controller),
        const SizedBox(height: 24),
        _buildPlaceBidButton(context),
      ],
    );
  }

  Widget _buildAppointmentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _buildAppointmentTypeChip(
                  label: 'Normal',
                  type: 'normal',
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAppointmentTypeChip(
                  label: 'Emergency',
                  type: 'emergency',
                  icon: Icons.emergency_rounded,
                  isEmergency: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          controller.appointmentType == 'emergency'
              ? 'Emergency appointments include 20% surcharge for priority service'
              : 'Standard appointment with regular pricing',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTypeChip({
    required String label,
    required String type,
    required IconData icon,
    bool isEmergency = false,
  }) {
    final isSelected = controller.appointmentType == type;

    return Material(
      color: isSelected
          ? (isEmergency ? Colors.red[50] : controller.providerColor.withOpacity(0.1))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => controller.updateAppointmentType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (isEmergency ? Colors.red! : controller.providerColor)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (isEmergency ? Colors.red : controller.providerColor)
                    : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? (isEmergency ? Colors.red : controller.providerColor)
                      : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              if (isEmergency) ...[
                const SizedBox(height: 2),
                Text(
                  '+20%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.red : Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: controller.selectedServiceType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: controller.providerColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: controller.getServiceTypeOptions().map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      _getServiceTypeIcon(value),
                      color: controller.providerColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.formatServiceType(value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
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
            style: const TextStyle(color: Colors.black87),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(Icons.arrow_drop_down_rounded, color: controller.providerColor),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  IconData _getServiceTypeIcon(String serviceType) {
    switch (serviceType) {
      case 'regular':
      case 'general':
        return Icons.cleaning_services_rounded;
      case 'deep':
        return Icons.clean_hands_rounded;
      case 'office':
        return Icons.business_rounded;
      case 'move_in_out':
        return Icons.moving_rounded;
      case 'leak_fix':
        return Icons.water_damage_rounded;
      case 'installation':
        return Icons.build_rounded;
      case 'drain_cleaning':
        return Icons.timeline_rounded;
      case 'water_heater':
        return Icons.heat_pump_rounded;
      case 'wiring':
        return Icons.electric_bolt_rounded;
      case 'repair':
        return Icons.handyman_rounded;
      case 'lighting':
        return Icons.lightbulb_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return AdvancedDateTimePicker(
      initialDate: controller.selectedDate,
      initialTime: controller.selectedTime,
      onDateTimeSelected: (DateTime dateTime) {
        controller.updateSelectedDateTime(dateTime);
      },
      label: 'Appointment Date & Time *',
      isRequired: true,
      margin: EdgeInsets.zero,
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Address *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.addressController,
          onChanged: (value) => controller.updateAddress(value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: controller.providerColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.location_on_rounded, color: controller.providerColor),
            hintText: 'Enter the service address...',
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the service address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problem Description *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.descriptionController,
          onChanged: (value) => controller.updateDescription(value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: controller.providerColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.description_rounded, color: controller.providerColor),
            hintText: 'Describe the problem in detail...',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please describe the problem';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Provide as much detail as possible to help the ${controller.serviceType} understand your needs',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceBidButton(BuildContext context) {
    return GetBuilder<AppointmentBookingController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: controller.providerColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isFormValid && !controller.isLoading
                ? () => _showBidPopup(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.providerColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.gavel_rounded, size: 20),
                SizedBox(width: 12),
                Text(
                  'Place Your Bid & Book',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBidPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BidPopupWidget(controller: controller),
    );
  }
}
