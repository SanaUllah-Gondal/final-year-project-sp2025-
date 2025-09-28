import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plumber_project/services/api_service.dart';
import 'package:plumber_project/widgets/app_color.dart';
import 'package:plumber_project/widgets/app_text_style.dart';
import 'package:plumber_project/widgets/loading_shimmer.dart';

class UserAppointmentsScreen extends StatefulWidget {
  @override
  _UserAppointmentsScreenState createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  final ApiService _apiService = Get.find();

  final List<String> _tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
  var _selectedTab = 0.obs;
  var _isLoading = false.obs;
  var _appointments = [].obs;
  var _filteredAppointments = [].obs;

  @override
  void initState() {
    super.initState();
    _loadUserAppointments();
  }

  Future<void> _loadUserAppointments() async {
    try {
      _isLoading.value = true;

      // Load appointments from all service types
      final List<Future> futures = [
        _apiService.getCleanerAppointments(),
        _apiService.getPlumberAppointments(),
        _apiService.getElectricianAppointments(),
      ];

      final results = await Future.wait(futures);

      // Combine all appointments
      List<dynamic> allAppointments = [];
      for (var result in results) {
        if (result['success'] && result['data'] != null) {
          final appointments = result['data']['data'] ?? [];
          // Add service type to each appointment
          for (var appointment in appointments) {
            appointment['service_type'] = _getServiceTypeFromResult(result);
          }
          allAppointments.addAll(appointments);
        }
      }

      // Sort by date (newest first)
      allAppointments.sort((a, b) {
        final dateA = DateTime.parse(a['appointment_date']);
        final dateB = DateTime.parse(b['appointment_date']);
        return dateB.compareTo(dateA);
      });

      _appointments.value = allAppointments;
      _filterAppointments();

    } catch (e) {
      print('Error loading user appointments: $e');
      Get.snackbar('Error', 'Failed to load appointments');
    } finally {
      _isLoading.value = false;
    }
  }

  String _getServiceTypeFromResult(Map<String, dynamic> result) {
    final url = result['request_url']?.toString() ?? '';
    if (url.contains('cleaner')) return 'Cleaner';
    if (url.contains('plumber')) return 'Plumber';
    if (url.contains('electrician')) return 'Electrician';
    return 'Unknown';
  }

  void _filterAppointments() {
    if (_selectedTab.value == 0) {
      // Show all appointments
      _filteredAppointments.value = _appointments;
    } else {
      // Filter by status
      final status = _tabs[_selectedTab.value].toLowerCase();
      _filteredAppointments.value = _appointments.where((appt) =>
      appt['status'] == status).toList();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningColor;
      case 'confirmed':
        return AppColors.successColor;
      case 'completed':
        return AppColors.infoColor;
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.greyColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return Colors.blue;
      case 'plumber':
        return Colors.orange;
      case 'electrician':
        return Colors.purple;
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cleaner':
        return Icons.cleaning_services;
      case 'plumber':
        return Icons.plumbing;
      case 'electrician':
        return Icons.electrical_services;
      default:
        return Icons.home_repair_service;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: AppTextStyles.heading6.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserAppointments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab.value == index;

                  return InkWell(
                    onTap: () {
                      _selectedTab.value = index;
                      _filterAppointments();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppColors.primaryColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryColor : AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )),
          ),

          // Appointments List
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return _buildShimmerLoading();
              }

              if (_filteredAppointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: AppColors.greyColor.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No ${_selectedTab.value == 0 ? '' : _tabs[_selectedTab.value].toLowerCase()} appointments',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyColor),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Book services to see your appointments here',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadUserAppointments,
                backgroundColor: AppColors.primaryColor,
                color: Colors.white,
                child: ListView.separated(
                  itemCount: _filteredAppointments.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.lightGrey),
                  itemBuilder: (context, index) {
                    final appointment = _filteredAppointments[index];
                    return _buildAppointmentCard(appointment);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(16),
        child: LoadingShimmer.card(),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final appointmentDate = DateTime.parse(appointment['appointment_date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final status = appointment['status'];
    final serviceType = appointment['service_type'] ?? 'Unknown Service';
    final provider = appointment['provider'] ?? {};
    final providerName = provider['name'] ?? 'Unknown Provider';
    final providerImage = provider['profile_image'];
    final price = appointment['price'] is String
        ? double.tryParse(appointment['price']) ?? 0.0
        : (appointment['price']?.toDouble() ?? 0.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Show appointment details
            _showAppointmentDetails(appointment);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Service Info and Status
                Row(
                  children: [
                    // Service Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getServiceColor(serviceType).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getServiceIcon(serviceType),
                        color: _getServiceColor(serviceType),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),

                    // Service Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceType,
                            style: AppTextStyles.subtitle1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'with $providerName',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyColor),
                          ),
                        ],
                      ),
                    ),

                    // Status Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(status), size: 14, color: _getStatusColor(status)),
                          SizedBox(width: 4),
                          Text(
                            status.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),
                Divider(color: AppColors.lightGrey),

                // Appointment Details
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkColor),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      formattedTime,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkColor),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment['address'] ?? 'No address provided',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                if (status == 'pending')
                  SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      _cancelAppointment(appointment['id'].toString(), serviceType.toLowerCase());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.errorColor),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Cancel Request',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final appointmentDate = DateTime.parse(appointment['appointment_date']);
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final status = appointment['status'];
    final serviceType = appointment['service_type'] ?? 'Unknown Service';
    final provider = appointment['provider'] ?? {};
    final providerName = provider['name'] ?? 'Unknown Provider';
    final providerImage = provider['profile_image'];
    final providerPhone = provider['phone_number'] ?? 'Not available';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service and Provider Info
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getServiceColor(serviceType).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getServiceIcon(serviceType),
                      color: _getServiceColor(serviceType),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceType,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text('Provider: $providerName'),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              Divider(),

              // Appointment Details
              _buildDetailRow('Date', formattedDate),
              _buildDetailRow('Time', formattedTime),
              _buildDetailRow('Address', appointment['address'] ?? 'Not specified'),
              _buildDetailRow('Price', '\$${appointment['price']?.toStringAsFixed(2) ?? '0.00'}'),
              _buildDetailRow('Status', status.toUpperCase(),
                  textColor: _getStatusColor(status)),

              // Provider Contact
              SizedBox(height: 16),
              Text('Provider Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailRow('Phone', providerPhone),

              // Problem Description
              if (appointment['description'] != null) ...[
                SizedBox(height: 16),
                Text('Problem Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(appointment['description']),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          if (status == 'pending')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(appointment['id'].toString(), serviceType.toLowerCase());
              },
              child: Text('Cancel Appointment', style: TextStyle(color: AppColors.errorColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(String appointmentId, String serviceType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment'),
        content: Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _isLoading.value = true;
        final response = await _apiService.cancelAppointment(serviceType, appointmentId);

        if (response['success']) {
          Get.snackbar('Success', 'Appointment cancelled successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.successColor,
              colorText: Colors.white);
          await _loadUserAppointments(); // Refresh the list
        } else {
          Get.snackbar('Error', response['message'] ?? 'Failed to cancel appointment',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorColor,
              colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to cancel appointment: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white);
      } finally {
        _isLoading.value = false;
      }
    }
  }
}