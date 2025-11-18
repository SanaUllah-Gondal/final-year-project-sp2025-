import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/electrician_profile_controller.dart';

class ElectricianProfilePage extends StatelessWidget {
  final ElectricianProfileController controller = Get.put(ElectricianProfileController());

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
                    ? Icon(Icons.electrical_services, size: 60, color: Colors.white)
                    : null,
              )),
              // Face detection status indicator - ADD THIS
              Obx(() {
                if (!controller.faceService.isServiceReady.value) {
                  return Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.face, size: 20, color: Colors.white),
                    ),
                  );
                }
                return controller.isFaceDetected.value
                    ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.face, size: 20, color: Colors.white),
                  ),
                )
                    : controller.profileImage.value != null && !controller.isFaceDetected.value
                    ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.warning, size: 20, color: Colors.white),
                  ),
                )
                    : SizedBox();
              }),
            ],
          ),
          SizedBox(height: 10),
          // UPDATED: Camera and gallery buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : () => controller.pickImage(),
                icon: Icon(Icons.photo_library, size: 20),
                label: Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : () => controller.pickImage(),
                icon: Icon(Icons.camera_alt, size: 20),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          // NEW: Face status message
          Obx(() => controller.faceStatus.isNotEmpty
              ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: controller.isFaceDetected.value
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.isFaceDetected.value ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isFaceDetected.value ? Icons.check_circle : Icons.info,
                  color: controller.isFaceDetected.value ? Colors.green : Colors.orange,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.faceStatus.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
              : SizedBox()),
          // NEW: Face analysis details
          Obx(() => controller.isFaceDetected.value && controller.faceResults.isNotEmpty
              ? _buildFaceAnalysisDetails()
              : SizedBox()),
        ],
      ),
    );
  }

  // NEW: Face analysis details widget
  Widget _buildFaceAnalysisDetails() {
    final result = controller.faceResults.first;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Face Analysis Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildExpressionRow('Smiling', result.expressions['smiling']),
          _buildExpressionRow('Left Eye Open', result.expressions['left_eye_open']),
          _buildExpressionRow('Right Eye Open', result.expressions['right_eye_open']),
          _buildExpressionRow('Mouth Open', result.expressions['mouth_open']),
          _buildExpressionRow('Eyebrow Raised', result.expressions['eyebrow_raised']),
          SizedBox(height: 4),
          Text(
            'Features Detected: ${result.features.length}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Expression row widget
  Widget _buildExpressionRow(String label, double? value) {
    if (value == null) return SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      value > 0.7 ? Colors.green : value > 0.4 ? Colors.orange : Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField("Full Name", controller.nameController),
        _buildTextField("Email", controller.emailController,
            keyboardType: TextInputType.emailAddress),
        _buildTextField("Experience (Years)", controller.experienceController,
            keyboardType: TextInputType.number),
        _buildTextField("Skills", controller.skillsController),
        _buildLocationField("Service Area", controller.areaController),
        _buildTextField("Hourly Rate", controller.rateController,
            keyboardType: TextInputType.numberWithOptions(decimal: true)),
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
            enabled: !controller.isLoading.value,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow),
                borderRadius: BorderRadius.circular(8),
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
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow),
                borderRadius: BorderRadius.circular(8),
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
        // NEW: Model loading status
        Obx(() {
          if (!controller.faceService.isServiceReady.value) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Face Recognition',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          controller.faceService.statusMessage.value,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox();
        }),
        // NEW: Face verification requirement note
        Obx(() {
          if (!controller.profileExists.value && !controller.isFaceDetected.value && controller.profileImage.value != null) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Face not detected. Please upload a clear photo with your face visible for identity verification.',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox();
        }),
        // Error messages
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
        // Success messages
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
    return Obx(() => Column(
      children: [
        // NEW: Face verification requirement note
        if (!controller.profileExists.value && !controller.isFaceDetected.value && controller.profileImage.value != null)
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Face verification required to create profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ElevatedButton(
          onPressed: controller.isLoading.value ? null : () => controller.submitProfile(),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isLoading.value
                ? Colors.grey
                : (!controller.profileExists.value && !controller.isFaceDetected.value && controller.profileImage.value != null)
                ? Colors.orange
                : Colors.yellow,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
          ),
          child: controller.isLoading.value
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          )
              : Obx(() => Text(
            controller.profileExists.value ? "Update Profile" : "Create Profile",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          )),
        ),
      ],
    ));
  }
}