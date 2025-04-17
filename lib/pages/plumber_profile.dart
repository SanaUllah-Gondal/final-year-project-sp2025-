// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   @override
//   _PlumberProfilePageState createState() => _PlumberProfilePageState();
// }

// class _PlumberProfilePageState extends State<PlumberProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController experienceController = TextEditingController();
//   final TextEditingController skillsController = TextEditingController();
//   final TextEditingController areaController = TextEditingController();
//   final TextEditingController rateController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Plumber Profile", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.grey,
//                     child: Icon(Icons.person, size: 60, color: Colors.white),
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: () {
//                       // Optional: Add image picker logic
//                     },
//                     icon: Icon(Icons.camera_alt),
//                     label: Text("Update Photo"),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),

//             _buildLabeledTextField("Full Name", nameController),
//             _buildLabeledTextField(
//               "Experience (Years)",
//               experienceController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Skills (e.g. pipe fitting, repair)",
//               skillsController,
//             ),
//             _buildLabeledTextField("Service Area", areaController),
//             _buildLabeledTextField(
//               "Hourly Rate (PKR)",
//               rateController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Contact Number",
//               contactController,
//               type: TextInputType.phone,
//             ),

//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: () {
//                   print("Name: ${nameController.text}");
//                   print("Skills: ${skillsController.text}");
//                    Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => HomeScreen()),
                    
//                   );
//                 },
//                 child: Text("Save Profile", style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLabeledTextField(
//     String label,
//     TextEditingController controller, {
//     TextInputType type = TextInputType.text,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             keyboardType: type,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.black),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:plumber_project/pages/dashboard.dart';

class PlumberProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;

  const PlumberProfilePage({super.key, this.onSuccess});

  @override
  _PlumberProfilePageState createState() => _PlumberProfilePageState();
}

class _PlumberProfilePageState extends State<PlumberProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  File? _profileImage;

  Future<void> _pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      widget.onSuccess?.call();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      widget.onSuccess?.call();
    }
  }

  Future<void> _pickImageFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _profileImage = File(result.files.single.path!);
      });
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plumber Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                    backgroundColor: Colors.grey,
                    child:
                        _profileImage == null
                            ? Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                  ),
                  SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _pickImageOption,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Update Photo"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildLabeledTextField("Full Name", nameController),
            _buildLabeledTextField(
              "Experience (Years)",
              experienceController,
              type: TextInputType.number,
            ),
            _buildLabeledTextField(
              "Skills (e.g. pipe fitting, repair)",
              skillsController,
            ),
            _buildLabeledTextField("Service Area", areaController),
            _buildLabeledTextField(
              "Hourly Rate (PKR)",
              rateController,
              type: TextInputType.number,
            ),
            _buildLabeledTextField(
              "Contact Number",
              contactController,
              type: TextInputType.phone,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () {
                  print("Name: ${nameController.text}");
                  print("Skills: ${skillsController.text}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text("Save Profile", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
