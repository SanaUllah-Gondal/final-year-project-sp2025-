import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../Apis.dart';
import '../services/appointment_service.dart';
import 'map_utils.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _problemImage;
  String? _selectedServiceType;
  String? _appointmentType = 'normal';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double _finalPrice = 0.0;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.provider['address_name'] ?? '';
    _selectedServiceType = _getDefaultServiceType();
    _calculatePrice();
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

  void _calculatePrice() {
    setState(() {
      if (_appointmentType == 'emergency') {
        _finalPrice = widget.basePrice * 1.2; // 20% increase for emergency
      } else {
        _finalPrice = widget.basePrice;
      }
    });
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

  Future<void> _submitAppointment() async {
    print("Submit Appointment tapped ✅");

    if (!_formKey.currentState!.validate()) {
      print("Form validation failed ❌");
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showErrorDialog('Please select both date and time');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/appointments/${widget.serviceType.toLowerCase()}'),
      );

      // Add headers
      final token = await AppointmentService.getToken();
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Get provider ID and ensure it's a string
      final providerId = widget.provider['provider_id'] ?? widget.provider['id'];
      final providerIdString = providerId.toString();

      // Add form data
      request.fields['provider_id'] = providerIdString;
      request.fields['appointment_type'] = _appointmentType!;
      request.fields['sub_service_type'] = _selectedServiceType!;
      request.fields['description'] = _descriptionController.text;
      request.fields['appointment_date'] = appointmentDateTime.toIso8601String();
      request.fields['address'] = _addressController.text;
      request.fields['base_price'] = widget.basePrice.toString();
      request.fields['latitude'] = widget.userLocation.latitude.toString();
      request.fields['longitude'] = widget.userLocation.longitude.toString();

      // Add image file if selected
      if (_problemImage != null) {
        var fileStream = http.ByteStream(_problemImage!.openRead());
        var length = await _problemImage!.length();

        var multipartFile = http.MultipartFile(
          'problem_image',
          fileStream,
          length,
          filename: path.basename(_problemImage!.path),
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: $responseData");

      var result = json.decode(responseData);

      if (response.statusCode == 201) {
        // 🔥 Save to Firebase as backup
        await _saveAppointmentToFirebase(
          providerId: providerIdString,
          appointmentDateTime: appointmentDateTime,
        );

        _showConfirmationDialog();
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to create appointment. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error in submit: $e");
      _showErrorDialog("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save appointment details into Firebase Firestore
  Future<void> _saveAppointmentToFirebase({
    required String providerId,
    required DateTime appointmentDateTime,
  }) async {
    try {
      // ✅ Pick correct collection
      String collectionName;
      switch (widget.serviceType.toLowerCase()) {
        case 'cleaner':
          collectionName = 'cleaner_appointment';
          break;
        case 'plumber':
          collectionName = 'plumber_appointment';
          break;
        case 'electrician':
          collectionName = 'electrician_appointment';
          break;
        default:
          collectionName = 'general_appointment';
      }

      // ✅ Convert image to base64 if available
      String? base64Image;
      if (_problemImage != null) {
        final bytes = await _problemImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // ✅ Build appointment data
      final appointmentData = {
        'provider_id': providerId,
        'appointment_type': _appointmentType,
        'sub_service_type': _selectedServiceType,
        'description': _descriptionController.text,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'address': _addressController.text,
        'base_price': widget.basePrice,
        'latitude': widget.userLocation.latitude,
        'longitude': widget.userLocation.longitude,
        'problem_image': base64Image,
        'created_at': DateTime.now().toIso8601String(),
      };

      // ✅ Save into Firestore
      await FirebaseFirestore.instance
          .collection(collectionName)
          .add(appointmentData);

      print("🔥 Appointment saved to Firebase in $collectionName");
    } catch (e) {
      print("❌ Error saving to Firebase: $e");
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Request Sent'),
        content: Text(
            'Your ${_appointmentType} appointment request has been sent to the provider. '
                'Total amount: \$${_finalPrice.toStringAsFixed(2)}. '
                'You will be notified when they respond.'),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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

              // Appointment Type Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Normal'),
                          selected: _appointmentType == 'normal',
                          onSelected: (selected) {
                            setState(() {
                              _appointmentType = 'normal';
                              _calculatePrice();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Emergency (+20%)'),
                          selected: _appointmentType == 'emergency',
                          onSelected: (selected) {
                            setState(() {
                              _appointmentType = 'emergency';
                              _calculatePrice();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Price: \$${_finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                onPressed: _isLoading ? null : _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: providerColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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