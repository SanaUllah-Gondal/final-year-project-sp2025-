import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:plumber_project/pages/users/user_profile_controlller.dart';

class UserProfilePage extends StatelessWidget {
  final UserProfileController controller = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.profileExists.value ? "Update Profile" : "Create Profile",
          style: TextStyle(color: Colors.white),
        )),
        backgroundColor: controller.darkBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [controller.darkBlue, controller.tealBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileImageSection(),
                    SizedBox(height: 20),
                    _buildProfileForm(),
                    SizedBox(height: 30),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() => CircleAvatar(
                radius: 50,
                backgroundImage: controller.profileImage.value != null
                    ? FileImage(controller.profileImage.value!)
                    : null,
                backgroundColor: Colors.grey,
                child: controller.profileImage.value == null
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              )),
            ],
          ),
          SizedBox(height: 10),
          TextButton.icon(
            onPressed: controller.isLoading.value ? null : () => controller.pickImage(),
            icon: Icon(Icons.camera_alt, color: Colors.white),
            label: Obx(() => Text(
              controller.profileExists.value ? "Change Photo" : "Upload Photo",
              style: TextStyle(color: Colors.white),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField("Full Name", controller.nameController),
        _buildTextField("Short Bio", controller.bioController, maxLines: 3),
        _buildLocationField("Location", controller.locationController),
        _buildTextField("Contact Number", controller.contactController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ]),
        _buildMessages(),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController textController, {
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white
          )),
          SizedBox(height: 8),
          TextField(
            controller: textController,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            enabled: !controller.isLoading.value,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(String label, TextEditingController textController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white
          )),
          SizedBox(height: 8),
          TextField(
            controller: textController,
            readOnly: true,
            enabled: !controller.isLoading.value,
            onTap: controller.isLoading.value ? null : () => controller.getLiveLocation(),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: 'Tap to get current location',
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: Icon(Icons.location_on, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Column(
      children: [
        Obx(() {
          if (controller.errorMessage.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(child: Text(controller.errorMessage.value)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => controller.errorMessage.value = '',
                    iconSize: 18,
                  )
                ],
              ),
            );
          }
          return SizedBox();
        }),
        Obx(() {
          if (controller.successMessage.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(child: Text(controller.successMessage.value)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => controller.successMessage.value = '',
                    iconSize: 18,
                  )
                ],
              ),
            );
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: controller.isLoading.value ? null : () => controller.submitProfile(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Obx(() => Text(
        controller.profileExists.value ? "Update Profile" : "Create Profile",
        style: TextStyle(fontSize: 16),
      )),
    );
  }
}