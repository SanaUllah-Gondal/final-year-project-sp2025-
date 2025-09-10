import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'map_utils.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceType;
  final Position userLocation;

  const AppointmentBookingScreen({
    Key? key,
    required this.provider,
    required this.serviceType,
    required this.userLocation,
  }) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _problemImage;
  String? _selectedServiceType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.provider['address_name'] ?? '';
    _selectedServiceType = _getDefaultServiceType();
  }

  String _getDefaultServiceType() {
    switch (widget.serviceType.toLowerCase()) {
      case 'cleaner':
        return 'regular';
      case 'plumber':
        return 'leak_fix';
      case 'electrician':
        return 'wiring';
      default:
        return 'general';
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _problemImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitAppointment() {
    if (_formKey.currentState!.validate()) {
      final appointmentData = {
        'provider_id': widget.provider['provider_id'] ?? widget.provider['id'],
        'provider_name': widget.provider['name'],
        'service_type': widget.serviceType,
        'sub_service_type': _selectedServiceType,
        'description': _descriptionController.text,
        'appointment_date': _selectedDate?.toIso8601String(),
        'appointment_time': _selectedTime?.format(context),
        'address': _addressController.text,
        'problem_image': _problemImage?.path,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      _showConfirmationDialog(appointmentData);
    }
  }

  void _showConfirmationDialog(Map<String, dynamic> appointmentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Request Sent'),
        content: const Text(
            'Your appointment request has been sent to the provider. You will be notified when they respond.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<String> _getServiceTypeOptions() {
    switch (widget.serviceType.toLowerCase()) {
      case 'cleaner':
        return ['regular', 'deep', 'office', 'move_in_out', 'other'];
      case 'plumber':
        return [
          'leak_fix',
          'installation',
          'drain_cleaning',
          'water_heater',
          'other'
        ];
      case 'electrician':
        return ['wiring', 'installation', 'repair', 'lighting', 'other'];
      default:
        return ['general', 'repair', 'installation', 'other'];
    }
  }

  String _formatServiceType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final providerType = widget.provider['provider_type']?.toString().toLowerCase() ?? widget.serviceType.toLowerCase();
    final Color providerColor = getColorForProviderType(providerType);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.serviceType} Appointment'),
        backgroundColor: providerColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: providerColor.withOpacity(0.2),
                  child: getProviderIcon(providerType, providerColor, 20),
                ),
                title: Text(widget.provider['name'] ?? 'Provider'),
                subtitle: Text(providerType),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                ),
                items: _getServiceTypeOptions().map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_formatServiceType(value)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedServiceType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
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
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: _selectTime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Service Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Problem Description',
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
              ),
              const SizedBox(height: 16),
              const Text('Upload image of the problem (optional)'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              if (_problemImage != null) ...[
                const SizedBox(height: 8),
                Image.file(
                  _problemImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: providerColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirm Appointment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}