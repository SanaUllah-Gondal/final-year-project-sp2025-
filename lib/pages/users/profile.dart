import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plumber_project/pages/chat_list.dart';
import 'package:plumber_project/pages/cleaner/cleaner_dashboard.dart';
import 'package:plumber_project/pages/users/dashboard.dart';
import 'package:plumber_project/pages/electrition/electrition_dashboard.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/authentication/login.dart';
import 'package:plumber_project/pages/plumber/plumber_dashboard.dart';
import 'package:plumber_project/pages/privacy.dart';
import 'package:plumber_project/pages/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);
final Color lightTeal = Color(0xFFE0F7FA);
final Color cardColor = Color(0xFFF8F9FA);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  int _selectedIndex = 2; // Profile is selected by default
  String _userName = 'Loading...';
  String _userRole = '';
  String _userId = '';
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _userName = prefs.getString('name') ?? 'Guest';
      _userRole = prefs.getString('role') ?? '';
      _userId = prefs.getString('userId') ?? _auth.currentUser?.uid ?? '';
    });

    await _fetchUserDataFromFirebase();
  }

  Future<void> _fetchUserDataFromFirebase() async {
    try {
      String collectionName = _getCollectionName();

      if (_userId.isEmpty) {
        _userId = _auth.currentUser?.uid ?? '';
        if (_userId.isEmpty) {
          throw Exception('User ID not found');
        }
      }

      DocumentSnapshot userDoc = await _firestore
          .collection(collectionName)
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _populateControllers();
          _isLoading = false;
        });

        await _updateSharedPreferences();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('User data not found in $collectionName collection');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading user data: $e');
    }
  }

  String _getCollectionName() {
    switch (_userRole.toLowerCase()) {
      case 'plumber':
        return 'plumber';
      case 'electrician':
        return 'electrician';
      case 'cleaner':
        return 'cleaner';
      default:
        return 'user';
    }
  }

  void _populateControllers() {
    _nameController.text = _userData['fullName'] ?? _userData['name'] ?? '';
    _emailController.text = _userData['email'] ?? '';
    _phoneController.text = _userData['contactNumber'] ?? _userData['phone'] ?? '';
    _addressController.text = _userData['serviceArea'] ?? _userData['address'] ?? '';

    // Professional fields (only for service providers)
    if (_userRole != 'user') {
      _serviceController.text = _userData['serviceType'] ?? _userData['specialization'] ?? '';
      _experienceController.text = _userData['experience']?.toString() ?? '';
      _skillsController.text = _userData['skills'] ?? '';
    }
  }

  Future<void> _updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String collectionName = _getCollectionName();

        Map<String, dynamic> updateData = {
          'fullName': _nameController.text,
          'email': _emailController.text,
          'contactNumber': _phoneController.text,
          'serviceArea': _addressController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add professional fields only for service providers
        if (_userRole != 'user') {
          updateData.addAll({
            'skills': _skillsController.text,
            'experience': _experienceController.text,
            'serviceType': _serviceController.text,
          });
        }

        await _firestore
            .collection(collectionName)
            .doc(_userId)
            .update(updateData);

        await _updateSharedPreferences();

        setState(() {
          _userName = _nameController.text;
          _isLoading = false;
          _isEditing = false;
        });

        _showSuccessSnackBar('Profile updated successfully!');

      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error updating profile: $e');
      }
    }
  }

  void _clearProfileData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Profile Data'),
          content: Text('Are you sure you want to clear all profile data? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllFields();
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _clearAllFields() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _serviceController.clear();
      _experienceController.clear();
      _skillsController.clear();
    });
    _showSuccessSnackBar('All fields cleared!');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildProfileImage() {
    String? profileImage = _userData['profileImage'];

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: tealBlue, width: 3),
            gradient: LinearGradient(
              colors: [tealBlue, darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: profileImage != null && profileImage.isNotEmpty
              ? CircleAvatar(
            radius: 56,
            backgroundImage: MemoryImage(_decodeImage(profileImage)),
          )
              : CircleAvatar(
            radius: 56,
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tealBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
      ],
    );
  }

  Uint8List _decodeImage(String base64Image) {
    return base64Decode(base64Image);
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightTeal, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileImage(),
              SizedBox(height: 20),
              Text(
                _userData['fullName'] ?? 'No Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: tealBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tealBlue),
                ),
                child: Text(
                  _userRole.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    color: tealBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_userData['experience'] != null)
                _buildInfoItem(
                  icon: Icons.work_outline,
                  title: 'Experience',
                  value: '${_userData['experience']} years',
                ),
              if (_userData['serviceArea'] != null)
                _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  title: 'Service Area',
                  value: _userData['serviceArea'] ?? 'Not specified',
                ),
              if (_userData['email'] != null)
                _buildInfoItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: _userData['email']!,
                ),
              if (_userData['contactNumber'] != null)
                _buildInfoItem(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: _userData['contactNumber']!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String title, required String value}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tealBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tealBlue, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? Colors.orange : tealBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              label: Text(_isEditing ? 'Cancel Edit' : 'Edit Profile'),
            ),
          ),
          SizedBox(width: 12),
          if (_isEditing)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: Icon(Icons.cleaning_services),
                label: Text('Clear All'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalFields() {
    if (_userRole == 'user') {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        _buildFormField(
          controller: _serviceController,
          label: 'Service Type',
          icon: Icons.work_outline,
          enabled: _isEditing,
        ),
        SizedBox(height: 16),
        _buildFormField(
          controller: _experienceController,
          label: 'Experience (years)',
          icon: Icons.timeline_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        _buildFormField(
          controller: _skillsController,
          label: 'Skills',
          icon: Icons.build_outlined,
          enabled: _isEditing,
          maxLines: 3,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? tealBlue.withOpacity(0.3) : Colors.grey[300]!,
        ),
        boxShadow: enabled ? [
          BoxShadow(
            color: tealBlue.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ] : [],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: tealBlue),
          prefixIcon: Icon(icon, color: tealBlue),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(color: darkBlue),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        _navigateToHome();
        break;
      case 1: // Chat/Emergency
        _navigateToMiddleOption();
        break;
      case 2: // Profile - already here
        break;
    }
  }

  void _navigateToHome() {
    Widget homePage;
    switch (_userRole) {
      case 'plumber':
        homePage = PlumberDashboard();
        break;
      case 'electrician':
        homePage = ElectricianDashboard();
        break;
      case 'cleaner':
        homePage = CleanerDashboard();
        break;
      default:
        homePage = HomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => homePage),
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToMiddleOption() {
    if (_userRole == 'plumber' || _userRole == 'electrician' || _userRole == 'cleaner') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatListScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergencyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _userRole.isNotEmpty
              ? _userRole[0].toUpperCase() + _userRole.substring(1) + ' Profile'
              : 'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: tealBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu, color: Colors.white),
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: tealBlue),
            SizedBox(height: 16),
            Text(
              'Loading Profile...',
              style: TextStyle(color: darkBlue, fontSize: 16),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserInfoSection(),
            SizedBox(height: 24),
            _buildActionButtons(),
            SizedBox(height: 24),
            if (_isEditing) ...[
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, cardColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Edit Profile Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildFormField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            enabled: _isEditing,
                          ),
                          SizedBox(height: 16),
                          _buildFormField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            enabled: _isEditing,
                          ),
                          SizedBox(height: 16),
                          _buildFormField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 16),
                          _buildFormField(
                            controller: _addressController,
                            label: 'Address/Service Area',
                            icon: Icons.location_on_outlined,
                            enabled: _isEditing,
                            maxLines: 2,
                          ),
                          SizedBox(height: 16),
                          _buildProfessionalFields(),
                          SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tealBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: tealBlue.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container( 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
   ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tealBlue, darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tealBlue, darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: tealBlue, size: 30),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _userName,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userRole.toUpperCase(),
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy & Terms',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyTermsScreen()),
                );
              },
            ),
            Divider(color: Colors.white.withOpacity(0.3), height: 1),
            _buildDrawerItem(
              icon: Icons.logout_outlined,
              title: 'Logout',
              color: Colors.red,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('name');
    await prefs.remove('phone');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.setBool('remember_me', false);
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}