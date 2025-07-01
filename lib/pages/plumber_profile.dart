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

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';

// import 'package:plumber_project/pages/dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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

//   File? plumber_image;

//   Future<void> _pickImageOption() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromCamera();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromGallery();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.insert_drive_file),
//                 title: Text('File'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromFile();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         plumber_image = File(result.files.single.path!);
//       });
//       widget.onSuccess?.call();
//     }
//   }

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
//                     backgroundImage:
//                         plumber_image != null
//                             ? FileImage(plumber_image!)
//                             : null,
//                     backgroundColor: Colors.grey,
//                     child:
//                         plumber_image == null
//                             ? Icon(Icons.person, size: 60, color: Colors.white)
//                             : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: _pickImageOption,
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
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => HomeScreen()),
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

//000000000000000000000000000000000000000000000000000000 code when the data can upload to the database then they can not display loading 0000000000000000000000000000000000000
// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? plumber_image;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";

//   @override
//   void initState() {
//     super.initState();

//     areaController.addListener(() {
//       _onChanged();
//     });

//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   void getSuggestion(String input) async {
//     const String PLACES_APIS_KEY = "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q";
//     try {
//       String baseURL =
//           'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       } else {
//         throw Exception('Failed to load prediction');
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _submitProfile() async {
//     final String name = nameController.text.trim();
//     final String experience = experienceController.text.trim();
//     final String skills = skillsController.text.trim();
//     final String area = areaController.text.trim();
//     final String rate = rateController.text.trim();
//     final String contact = contactController.text.trim();
//     final String role = roleController.text.trim();

//     if (name.isEmpty ||
//         skills.isEmpty ||
//         area.isEmpty ||
//         rate.isEmpty ||
//         contact.isEmpty ||
//         role.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
//       return;
//     }

//     try {
//       var uri = Uri.parse("http://10.0.2.2:8000/api/profile/");
//       var request = http.MultipartRequest("POST", uri);

//       // Add fields
//       request.fields['name'] = name;
//       request.fields['experience'] = experience;
//       request.fields['skills'] = skills;
//       request.fields['area'] = area;
//       request.fields['rate'] = rate;
//       request.fields['contact'] = contact;
//       request.fields['role'] = role;

//       // Attach profile image if selected
//       if (plumber_image != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'profile_image',
//             plumber_image!.path,
//           ),
//         );
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Profile saved successfully")));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         String errorMessage = "Failed to save profile";
//         try {
//           final responseData = json.decode(response.body);
//           if (responseData is Map && responseData.containsKey('message')) {
//             errorMessage = responseData['message'];
//           } else if (responseData is Map && responseData.containsKey('error')) {
//             errorMessage = responseData['error'];
//           }
//         } catch (e) {
//           print("Failed to parse error: $e");
//         }

//         _showErrorDialog("Error", errorMessage);
//       }
//     } catch (e) {
//       print("Exception: $e");
//       _showErrorDialog("Exception", "Something went wrong. Please try again.");
//     }
//   }

//   // Error AlertDialog
//   void _showErrorDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text("OK"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _pickImageOption() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromCamera();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromGallery();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.insert_drive_file),
//                 title: Text('File'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromFile();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         plumber_image = File(result.files.single.path!);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     areaController.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     skillsController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

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
//                     backgroundImage:
//                         plumber_image != null
//                             ? FileImage(plumber_image!)
//                             : null,
//                     backgroundColor: Colors.grey,
//                     child:
//                         plumber_image == null
//                             ? Icon(Icons.person, size: 60, color: Colors.white)
//                             : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: _pickImageOption,
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
//             _buildLabeledTextField(
//               "Service Area",
//               areaController,
//               focusNode: areaFocusNode,
//             ),
//             if (_placeList.isNotEmpty)
//               ListView.builder(
//                 physics: NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: _placeList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_placeList[index]["description"]),
//                     onTap: () {
//                       areaController.text = _placeList[index]["description"];
//                       setState(() {
//                         _placeList = [];
//                       });
//                     },
//                   );
//                 },
//               ),
//             _buildLabeledTextField(
//               "Role",
//               roleController,
//               type: TextInputType.text,
//             ),
//             _buildLabeledTextField(
//               "Hourly Rate (PKR)",
//               rateController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Contact Number",
//               contactController,
//               type: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(11),
//               ],
//             ),
//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: () {
//                   _submitProfile();
//                   print("Name: ${nameController.text}");
//                   print("Skills: ${skillsController.text}");
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => HomeScreen()),
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
//     List<TextInputFormatter>? inputFormatters,
//     FocusNode? focusNode,
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
//             focusNode: focusNode,
//             inputFormatters: inputFormatters,
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

// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? plumber_image;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";

//   @override
//   void initState() {
//     super.initState();

//     areaController.addListener(() {
//       _onChanged();
//     });

//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   void getSuggestion(String input) async {
//     const String PLACES_APIS_KEY = "YOUR_GOOGLE_PLACES_API_KEY";
//     try {
//       String baseURL =
//           'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       } else {
//         throw Exception('Failed to load prediction');
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   // Future<void> _submitProfile() async {
//   //   final String name = nameController.text.trim();
//   //   final String experience = experienceController.text.trim();
//   //   final String skills = skillsController.text.trim();
//   //   final String area = areaController.text.trim();
//   //   final String rate = rateController.text.trim();
//   //   final String contact = contactController.text.trim();
//   //   final String role = roleController.text.trim();

//   //   print(
//   //     "Form data: name=$name, experience=$experience, skills=$skills, area=$area, rate=$rate, contact=$contact, role=$role",
//   //   );

//   //   if (name.isEmpty ||
//   //       skills.isEmpty ||
//   //       area.isEmpty ||
//   //       rate.isEmpty ||
//   //       contact.isEmpty ||
//   //       role.isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text("Please fill in all fields.")),
//   //     );
//   //     return;
//   //   }

//   //   try {
//   //     SharedPreferences prefs = await SharedPreferences.getInstance();
//   //     String? token = prefs.getString('token');

//   //     if (token == null) {
//   //       ScaffoldMessenger.of(
//   //         context,
//   //       ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
//   //       return;
//   //     }

//   //     var uri = Uri.parse('http://10.0.2.2:8000/api/profile/');
//   //     var request = http.MultipartRequest('POST', uri);

//   //     request.headers.addAll({'Authorization': 'Bearer $token'});

//   //     request.fields['name'] = name;
//   //     request.fields['experience'] = experience;
//   //     request.fields['skills'] = skills;
//   //     request.fields['area'] = area;
//   //     request.fields['rate'] = rate;
//   //     request.fields['contact'] = contact;
//   //     request.fields['role'] = role;

//   //     if (plumber_image != null) {
//   //       try {
//   //         print("Attaching image: ${plumber_image!.path}");
//   //         request.files.add(
//   //           await http.MultipartFile.fromPath(
//   //             'plumber_image',
//   //             plumber_image!.path,
//   //           ),
//   //         );
//   //       } catch (e) {
//   //         print("Image upload error: $e");
//   //       }
//   //     }

//   //     var streamedResponse = await request.send();
//   //     var response = await http.Response.fromStream(streamedResponse);
//   //     final decodedBody = utf8.decode(response.bodyBytes);

//   //     print("Response status: ${response.statusCode}");
//   //     print("Response body: $decodedBody");

//   //     if (response.statusCode == 200) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text("Profile Updated Successfully")),
//   //       );
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text("Failed to update profile: $decodedBody")),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text("Error: $e")));
//   //   }
//   // }

//   Future<void> _submitProfile() async {
//     final String name = nameController.text.trim();
//     final String experience = experienceController.text.trim();
//     final String skills = skillsController.text.trim();
//     final String area = areaController.text.trim();
//     final String rate = rateController.text.trim();
//     final String contact = contactController.text.trim();
//     final String role = roleController.text.trim();

//     print(
//       "Form data: name=$name, experience=$experience, skills=$skills, area=$area, rate=$rate, contact=$contact, role=$role",
//     );

//     if (name.isEmpty ||
//         skills.isEmpty ||
//         area.isEmpty ||
//         rate.isEmpty ||
//         contact.isEmpty ||
//         role.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill in all fields.")),
//       );
//       return;
//     }

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
//         return;
//       }

//       var uri = Uri.parse('http://10.0.2.2:8000/api/profile/');
//       var request = http.MultipartRequest('POST', uri);

//       request.headers.addAll({'Authorization': 'Bearer $token'});

//       // ✅ Updated field names to match Laravel backend
//       request.fields['full_name'] = name;
//       request.fields['experience'] = experience;
//       request.fields['skill'] = skills;
//       request.fields['service_area'] = area;
//       request.fields['hourly_rate'] = rate;
//       request.fields['contact_number'] = contact;
//       request.fields['role'] = role;

//       if (plumber_image != null) {
//         try {
//           print("Attaching image: ${plumber_image!.path}");
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'plumber_image',
//               plumber_image!.path,
//             ),
//           );
//         } catch (e) {
//           print("Image upload error: $e");
//         }
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       final decodedBody = utf8.decode(response.bodyBytes);

//       print("Response status: ${response.statusCode}");
//       print("Response body: $decodedBody");

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile Updated Successfully")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to update profile: $decodedBody")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         plumber_image = File(result.files.single.path!);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   void _showImageSourceSelection(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder:
//           (_) => Padding(
//             padding: const EdgeInsets.all(16),
//             child: Wrap(
//               children: [
//                 const Text(
//                   "Choose Image Source",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.camera_alt),
//                   title: const Text('Camera'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromCamera();
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.photo),
//                   title: const Text('Gallery'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromGallery();
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.folder),
//                   title: const Text('Files'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromFile();
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Plumber Profile"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: <Widget>[
//             Center(
//               child: GestureDetector(
//                 onTap: () => _showImageSourceSelection(context),
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundImage:
//                       plumber_image != null
//                           ? FileImage(plumber_image!)
//                           : const AssetImage('assets/default_avatar.png')
//                               as ImageProvider,
//                   child:
//                       plumber_image == null
//                           ? const Icon(Icons.camera_alt, size: 50)
//                           : null,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: "Name"),
//             ),
//             TextFormField(
//               controller: experienceController,
//               decoration: const InputDecoration(labelText: "Experience"),
//             ),
//             TextFormField(
//               controller: skillsController,
//               decoration: const InputDecoration(labelText: "Skills"),
//             ),
//             TextFormField(
//               controller: areaController,
//               decoration: const InputDecoration(labelText: "Area"),
//             ),
//             TextFormField(
//               controller: rateController,
//               decoration: const InputDecoration(labelText: "Rate per hour"),
//             ),
//             TextFormField(
//               controller: contactController,
//               decoration: const InputDecoration(labelText: "Contact"),
//             ),
//             TextFormField(
//               controller: roleController,
//               decoration: const InputDecoration(labelText: "Role"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submitProfile,

//               child: const Text("Save Profile"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//000000000000000000000000000000000000000000000000000000 code when the data can upload to the database then they can be display loading 0000000000000000000000000000000000000
// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? plumber_image;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";

//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadRoleFromLocalStorage();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//   }

//   Future<void> _loadRoleFromLocalStorage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? role = prefs.getString('role');
//     if (role != null) {
//       setState(() {
//         roleController.text = role;
//       });
//     }
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   void getSuggestion(String input) async {
//     const String PLACES_APIS_KEY =
//         "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q"; // Replace
//     try {
//       String baseURL =
//           'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       } else {
//         throw Exception('Failed to load prediction');
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _submitProfile() async {
//     final String name = nameController.text.trim();
//     final String experience = experienceController.text.trim();
//     final String skills = skillsController.text.trim();
//     final String area = areaController.text.trim();
//     final String rate = rateController.text.trim();
//     final String contact = contactController.text.trim();
//     final String role = roleController.text.trim();

//     if (name.isEmpty ||
//         skills.isEmpty ||
//         area.isEmpty ||
//         rate.isEmpty ||
//         contact.isEmpty ||
//         role.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill in all fields.")),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
//         return;
//       }

//       var uri = Uri.parse('http://10.0.2.2:8000/api/profile/');
//       var request = http.MultipartRequest('POST', uri);
//       request.headers.addAll({'Authorization': 'Bearer $token'});

//       request.fields['full_name'] = name;
//       request.fields['experience'] = experience;
//       request.fields['skill'] = skills;
//       request.fields['service_area'] = area;
//       request.fields['hourly_rate'] = rate;
//       request.fields['contact_number'] = contact;
//       request.fields['role'] = role;

//       if (plumber_image != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'plumber_image',
//             plumber_image!.path,
//           ),
//         );
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       final decodedBody = utf8.decode(response.bodyBytes);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile Updated Successfully")),
//         );
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberDashboard()),
//         );
//         widget.onSuccess?.call();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to update profile: $decodedBody")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         plumber_image = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         plumber_image = File(result.files.single.path!);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   void _showImageSourceSelection(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder:
//           (_) => Padding(
//             padding: const EdgeInsets.all(16),
//             child: Wrap(
//               children: [
//                 const Text(
//                   "Choose Image Source",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.camera_alt),
//                   title: const Text('Camera'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromCamera();
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.photo),
//                   title: const Text('Gallery'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromGallery();
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.folder),
//                   title: const Text('Files'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromFile();
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Plumber Profile"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: <Widget>[
//                 Center(
//                   child: GestureDetector(
//                     onTap: () => _showImageSourceSelection(context),
//                     child: CircleAvatar(
//                       radius: 50,
//                       backgroundImage:
//                           plumber_image != null
//                               ? FileImage(plumber_image!)
//                               : const AssetImage('assets/default_avatar.png')
//                                   as ImageProvider,
//                       child:
//                           plumber_image == null
//                               ? const Icon(Icons.camera_alt, size: 50)
//                               : null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: nameController,
//                   decoration: const InputDecoration(labelText: "Name"),
//                 ),
//                 TextFormField(
//                   controller: experienceController,
//                   decoration: const InputDecoration(labelText: "Experience"),
//                 ),
//                 TextFormField(
//                   controller: skillsController,
//                   decoration: const InputDecoration(labelText: "Skills"),
//                 ),
//                 TextFormField(
//                   controller: areaController,
//                   decoration: const InputDecoration(labelText: "Area"),
//                 ),
//                 TextFormField(
//                   controller: rateController,
//                   decoration: const InputDecoration(labelText: "Rate per hour"),
//                 ),
//                 TextFormField(
//                   controller: contactController,
//                   decoration: const InputDecoration(labelText: "Contact"),
//                 ),
//                 TextFormField(
//                   controller: roleController,
//                   readOnly: true,
//                   decoration: const InputDecoration(labelText: "Role"),
//                 ),

//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: isLoading ? null : _submitProfile,
//                   child: const Text("Save Profile"),
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }
// }

//0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();
//   File? plumber_image;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadRoleFromLocalStorage();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//   }

//   Future<void> _loadRoleFromLocalStorage() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? role = prefs.getString('role');
//       if (role != null) {
//         setState(() {
//           roleController.text = role;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading role: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to load user role.")),
//       );
//     }
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   Future<void> getSuggestion(String input) async {
//     const String PLACES_APIS_KEY =
//         "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q"; // Replace

//     if (input.isEmpty) return;

//     try {
//       String baseURL =
//           'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));

//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       } else {
//         debugPrint(
//           'Failed to fetch predictions. Status Code: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       debugPrint('Error fetching suggestions: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to fetch area suggestions.")),
//       );
//     }
//   }

//   Future<void> _submitProfile() async {
//     final String name = nameController.text.trim();
//     final String experience = experienceController.text.trim();
//     final String skills = skillsController.text.trim();
//     final String area = areaController.text.trim();
//     final String rate = rateController.text.trim();
//     final String contact = contactController.text.trim();
//     final String role = roleController.text.trim();

//     if (name.isEmpty ||
//         skills.isEmpty ||
//         area.isEmpty ||
//         rate.isEmpty ||
//         contact.isEmpty ||
//         role.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill in all fields.")),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       if (token == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
//         return;
//       }

//       var uri = Uri.parse('http://10.0.2.2:8000/api/profile/');
//       var request = http.MultipartRequest('POST', uri);
//       request.headers.addAll({'Authorization': 'Bearer $token'});

//       request.fields['full_name'] = name;
//       request.fields['experience'] = experience;
//       request.fields['skill'] = skills;
//       request.fields['service_area'] = area;
//       request.fields['hourly_rate'] = rate;
//       request.fields['contact_number'] = contact;
//       request.fields['role'] = role;

//       if (plumber_image != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'plumber_image',
//             plumber_image!.path,
//           ),
//         );
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       final decodedBody = utf8.decode(response.bodyBytes);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile Updated Successfully")),
//         );
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberDashboard()),
//         );
//         widget.onSuccess?.call();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to update profile: $decodedBody")),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error submitting profile: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error submitting profile: $e")));
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         setState(() {
//           plumber_image = File(pickedFile.path);
//         });
//         widget.onSuccess?.call();
//       }
//     } on PlatformException catch (e) {
//       debugPrint('Camera permission denied: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
//     } catch (e) {
//       debugPrint('Error picking image from camera: $e');
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           plumber_image = File(pickedFile.path);
//         });
//         widget.onSuccess?.call();
//       }
//     } on PlatformException catch (e) {
//       debugPrint('Gallery access denied: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Gallery access denied")));
//     } catch (e) {
//       debugPrint('Error picking image from gallery: $e');
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(type: FileType.image);
//       if (result != null && result.files.single.path != null) {
//         setState(() {
//           plumber_image = File(result.files.single.path!);
//         });
//         widget.onSuccess?.call();
//       }
//     } catch (e) {
//       debugPrint('Error picking file: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Failed to pick file")));
//     }
//   }

//   void _showImageSourceSelection(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder:
//           (_) => Padding(
//             padding: const EdgeInsets.all(16),
//             child: Wrap(
//               children: [
//                 const Text(
//                   "Choose Image Source",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.camera_alt),
//                   title: const Text('Camera'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromCamera();
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.photo),
//                   title: const Text('Gallery'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromGallery();
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.folder),
//                   title: const Text('Files'),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromFile();
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Plumber Profile"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: <Widget>[
//                 Center(
//                   child: GestureDetector(
//                     onTap: () => _showImageSourceSelection(context),
//                     child: CircleAvatar(
//                       radius: 50,
//                       backgroundImage:
//                           plumber_image != null
//                               ? FileImage(plumber_image!)
//                               : const AssetImage('assets/default_avatar.png')
//                                   as ImageProvider,
//                       child:
//                           plumber_image == null
//                               ? const Icon(Icons.camera_alt, size: 50)
//                               : null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildTextField(nameController, "Name"),
//                 _buildTextField(experienceController, "Experience"),
//                 _buildTextField(skillsController, "Skills"),
//                 _buildTextField(areaController, "Area"),
//                 _buildTextField(rateController, "Rate per hour"),
//                 _buildTextField(contactController, "Contact"),
//                 _buildTextField(roleController, "Role", readOnly: true),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: isLoading ? null : _submitProfile,
//                   child: const Text("Save Profile"),
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool readOnly = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       decoration: InputDecoration(labelText: label),
//     );
//   }
// }

//000000000000000000000000000000000000000000000000000000000000000 this code can be set the location with user

// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   @override
//   void initState() {
//     super.initState();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//     _loadLocalData();
//   }

//   Future<void> _loadLocalData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('role') ?? 'Unknown';
//     final token = prefs.getString('token');
//     setState(() {
//       roleController.text = role;
//       _bearerToken = token;
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   Future<void> getSuggestion(String input) async {
//     const String PLACES_APIS_KEY =
//         "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q"; // Replace with your correct key
//     try {
//       String baseURL =
//           'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _pickImageOption() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromCamera();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromGallery();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.insert_drive_file),
//                 title: Text('File'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromFile();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _profileImage = File(result.files.single.path!);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _submitProfile() async {
//     final url = Uri.parse('http://10.0.2.2:8000/api/profile/');

//     final request = http.MultipartRequest('POST', url);
//     request.headers['Authorization'] = 'Bearer $_bearerToken';

//     request.fields['full_name'] = nameController.text;
//     request.fields['experience'] = experienceController.text;
//     request.fields['skill'] = skillsController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
//       );
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Profile saved successfully')));
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberDashboard()),
//         );
//       } else {
//         print('Failed to save profile: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to save profile')));
//       }
//     } catch (e) {
//       print('Error during save: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error saving profile')));
//     }
//   }

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     skillsController.dispose();
//     areaController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

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
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage:
//                         _profileImage != null
//                             ? FileImage(_profileImage!)
//                             : null,
//                     backgroundColor: Colors.grey,
//                     child:
//                         _profileImage == null
//                             ? Icon(Icons.person, size: 60, color: Colors.white)
//                             : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: _pickImageOption,
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
//             _buildLabeledTextField("Skills", skillsController),
//             _buildLabeledTextField(
//               "Service Area",
//               areaController,
//               focusNode: areaFocusNode,
//             ),
//             if (_placeList.isNotEmpty)
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: _placeList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_placeList[index]["description"]),
//                     onTap: () {
//                       areaController.text = _placeList[index]["description"];
//                       setState(() {
//                         _placeList = [];
//                       });
//                     },
//                   );
//                 },
//               ),
//             _buildLabeledTextField(
//               "Hourly Rate (PKR)",
//               rateController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Contact Number",
//               contactController,
//               type: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(11),
//               ],
//             ),
//             _buildLabeledTextField("Role", roleController, readOnly: true),
//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: _submitProfile,
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
//     List<TextInputFormatter>? inputFormatters,
//     FocusNode? focusNode,
//     bool readOnly = false,
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
//             inputFormatters: inputFormatters,
//             focusNode: focusNode,
//             readOnly: readOnly,
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

//0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart'; // ✅ UPDATED
// import 'package:geocoding/geocoding.dart'; // ✅ UPDATED
// import 'package:plumber_project/pages/plumber_dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   double? _latitude;
//   double? _longitude;

//   @override
//   void initState() {
//     super.initState();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//     _loadLocalData();
//     _getLiveLocation(); // ✅ Automatically get location on load
//   }

//   Future<void> _loadLocalData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('role') ?? 'Unknown';
//     final token = prefs.getString('token');
//     setState(() {
//       roleController.text = role;
//       _bearerToken = token;
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   Future<void> getSuggestion(String input) async {
//     const String PLACES_APIS_KEY = "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q";
//     try {
//       String baseURL =
//           'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _getLiveLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location services are disabled.")),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Location permission denied.")));
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location permission permanently denied.")),
//       );
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _latitude = position.latitude;
//       _longitude = position.longitude;

//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _latitude!,
//         _longitude!,
//       );
//       if (placemarks.isNotEmpty) {
//         String locationName =
//             placemarks.first.locality ??
//             placemarks.first.administrativeArea ??
//             '';
//         setState(() {
//           areaController.text =
//               locationName; // ✅ Automatically set service area
//         });
//       }
//     } catch (e) {
//       print("Location fetch error: $e");
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _profileImage = File(result.files.single.path!);
//       });
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _submitProfile() async {
//     final url = Uri.parse('http://10.0.2.2:8000/api/profile/');
//     final request = http.MultipartRequest('POST', url);
//     request.headers['Authorization'] = 'Bearer $_bearerToken';

//     request.fields['full_name'] = nameController.text;
//     request.fields['experience'] = experienceController.text;
//     request.fields['skill'] = skillsController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_latitude != null && _longitude != null) {
//       request.fields['latitude'] =
//           _latitude.toString(); // ✅ Include coordinates
//       request.fields['longitude'] = _longitude.toString();
//     }

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
//       );
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Profile saved successfully')));
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberDashboard()),
//         );
//       } else {
//         print('Failed to save profile: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to save profile')));
//       }
//     } catch (e) {
//       print('Error during save: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error saving profile')));
//     }
//   }

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     skillsController.dispose();
//     areaController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

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
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage:
//                         _profileImage != null
//                             ? FileImage(_profileImage!)
//                             : null,
//                     backgroundColor: Colors.grey,
//                     child:
//                         _profileImage == null
//                             ? Icon(Icons.person, size: 60, color: Colors.white)
//                             : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: () => _pickImageFromGallery(),
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
//             _buildLabeledTextField("Skills", skillsController),
//             _buildLabeledTextField(
//               "Service Area",
//               areaController,
//               focusNode: areaFocusNode,
//               readOnly: true,
//             ), // ✅ readOnly so user can't overwrite
//             _buildLabeledTextField(
//               "Hourly Rate (PKR)",
//               rateController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Contact Number",
//               contactController,
//               type: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(11),
//               ],
//             ),
//             _buildLabeledTextField("Role", roleController, readOnly: true),
//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: _submitProfile,
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
//     List<TextInputFormatter>? inputFormatters,
//     FocusNode? focusNode,
//     bool readOnly = false,
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
//             inputFormatters: inputFormatters,
//             focusNode: focusNode,
//             readOnly: readOnly,
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

//0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 this code sucessfully create the data in the database with current live location can be display in the text fields
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   double? _latitude;
//   double? _longitude;

//   @override
//   void initState() {
//     super.initState();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//     _loadLocalData();
//     _getLiveLocation(); // Auto location
//   }

//   Future<void> _loadLocalData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('role') ?? 'Unknown';
//     final token = prefs.getString('token');
//     setState(() {
//       roleController.text = role;
//       _bearerToken = token;
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   Future<void> getSuggestion(String input) async {
//     const String PLACES_APIS_KEY = "YOUR_API_KEY_HERE";
//     try {
//       String baseURL =
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _getLiveLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location services are disabled.")),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Location permission denied.")));
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location permission permanently denied.")),
//       );
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _latitude = position.latitude;
//       _longitude = position.longitude;

//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _latitude!,
//         _longitude!,
//       );
//       if (placemarks.isNotEmpty) {
//         String locationName =
//             placemarks.first.locality ??
//             placemarks.first.administrativeArea ??
//             '';
//         setState(() {
//           areaController.text = locationName;
//         });
//       }
//     } catch (e) {
//       print("Location fetch error: $e");
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _submitProfile() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       print('Error: Bearer token is null or empty');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Authentication token is missing')),
//       );
//       return;
//     }

//     final url = Uri.parse('$baseUrl/api/profile/');
//     final request = http.MultipartRequest('POST', url);

//     request.headers.addAll({
//       'Authorization': 'Bearer $_bearerToken',
//       'Accept': 'application/json',
//     });

//     // Add text fields
//     request.fields['full_name'] = nameController.text;
//     request.fields['experience'] = experienceController.text;
//     request.fields['skill'] = skillsController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     // Optional coordinates
//     if (_latitude != null && _longitude != null) {
//       request.fields['latitude'] = _latitude.toString();
//       request.fields['longitude'] = _longitude.toString();
//     }

//     // Image if selected
//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
//       );
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Profile saved successfully')));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => PlumberDashboard()),
//         );
//       } else {
//         print('Failed: ${response.statusCode}');
//         print('Body: ${response.body}');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to save profile')));
//       }
//     } catch (e) {
//       print('Error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error saving profile')));
//     }
//   }

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     skillsController.dispose();
//     areaController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

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
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage:
//                         _profileImage != null
//                             ? FileImage(_profileImage!)
//                             : null,
//                     backgroundColor: Colors.grey,
//                     child:
//                         _profileImage == null
//                             ? Icon(Icons.person, size: 60, color: Colors.white)
//                             : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: _pickImageFromGallery,
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
//             _buildLabeledTextField("Skills", skillsController),
//             _buildLabeledTextField(
//               "Service Area",
//               areaController,
//               readOnly: true,
//             ),
//             _buildLabeledTextField(
//               "Hourly Rate (PKR)",
//               rateController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Contact Number",
//               contactController,
//               type: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(11),
//               ],
//             ),
//             _buildLabeledTextField("Role", roleController, readOnly: true),
//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _submitProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
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
//     List<TextInputFormatter>? inputFormatters,
//     bool readOnly = false,
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
//             inputFormatters: inputFormatters,
//             readOnly: readOnly,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Enter $label',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// is code may background color white hai
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   double? _latitude;
//   double? _longitude;

//   @override
//   void initState() {
//     super.initState();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//     _loadLocalData();
//     _getLiveLocation(); // Auto location
//   }

//   Future<void> _loadLocalData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('role') ?? 'Unknown';
//     final token = prefs.getString('bearer_token');
//     setState(() {
//       roleController.text = role;
//       _bearerToken = token;
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   Future<void> getSuggestion(String input) async {
//     const String PLACES_APIS_KEY = "YOUR_API_KEY_HERE";
//     try {
//       String baseURL =
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _getLiveLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location services are disabled.")),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Location permission denied.")));
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location permission permanently denied.")),
//       );
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _latitude = position.latitude;
//       _longitude = position.longitude;

//       // Reverse geocode to get area name
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _latitude!,
//         _longitude!,
//       );
//       if (placemarks.isNotEmpty) {
//         String locationName = placemarks.first.locality ??
//             placemarks.first.administrativeArea ??
//             '';
//         setState(() {
//           areaController.text = locationName;
//         });
//       }

//       // NEW: Send location to backend
//       await _updateLocationOnServer(_latitude!, _longitude!);
//     } catch (e) {
//       print("Location fetch error: $e");
//     }
//   }

//   // NEW METHOD to update location on backend
//   Future<void> _updateLocationOnServer(double lat, double lng) async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       print("Bearer token missing, can't update location");
//       return;
//     }

//     final url = Uri.parse('$baseUrl/api/profile/update-location');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $_bearerToken',
//           'Accept': 'application/json',
//         },
//         body: {'latitude': lat.toString(), 'longitude': lng.toString()},
//       );

//       if (response.statusCode == 200) {
//         print('Location updated on server');
//       } else {
//         print('Failed to update location on server: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error updating location on server: $e');
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _submitProfile() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       print('Error: Bearer token is null or empty');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Authentication token is missing')),
//       );
//       return;
//     }

//     final url = Uri.parse('$baseUrl/api/profile/');
//     final request = http.MultipartRequest('POST', url);

//     request.headers.addAll({
//       'Authorization': 'Bearer $_bearerToken',
//       'Accept': 'application/json',
//     });

//     // Add text fields
//     request.fields['full_name'] = nameController.text;
//     request.fields['experience'] = experienceController.text;
//     request.fields['skill'] = skillsController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     // Optional coordinates
//     if (_latitude != null && _longitude != null) {
//       request.fields['latitude'] = _latitude.toString();
//       request.fields['longitude'] = _longitude.toString();
//     }

//     // Image if selected
//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
//       );
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Profile saved successfully')));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => PlumberDashboard()),
//         );
//       } else {
//         print('Failed: ${response.statusCode}');
//         print('Body: ${response.body}');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to save profile')));
//       }
//     } catch (e) {
//       print('Error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error saving profile')));
//     }
//   }

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     skillsController.dispose();
//     areaController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

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
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _profileImage != null
//                         ? FileImage(_profileImage!)
//                         : null,
//                     backgroundColor: Colors.grey,
//                     child: _profileImage == null
//                         ? Icon(Icons.person, size: 60, color: Colors.white)
//                         : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: _pickImageFromGallery,
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
//             _buildLabeledTextField("Skills", skillsController),
//             // Keep readOnly true so user cannot manually edit area (optional)
//             _buildLabeledTextField(
//               "Service Area",
//               areaController,
//               readOnly: true,
//             ),
//             _buildLabeledTextField(
//               "Hourly Rate (PKR)",
//               rateController,
//               type: TextInputType.number,
//             ),
//             _buildLabeledTextField(
//               "Contact Number",
//               contactController,
//               type: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(11),
//               ],
//             ),
//             _buildLabeledTextField("Role", roleController, readOnly: true),
//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _submitProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
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
//     List<TextInputFormatter>? inputFormatters,
//     bool readOnly = false,
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
//             inputFormatters: inputFormatters,
//             readOnly: readOnly,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Enter $label',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// is code may background white aa raha hai
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class PlumberProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const PlumberProfilePage({super.key, this.onSuccess});

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
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   double? _latitude;
//   double? _longitude;

//   @override
//   void initState() {
//     super.initState();
//     areaController.addListener(_onChanged);
//     areaFocusNode.addListener(() {
//       if (!areaFocusNode.hasFocus) {
//         setState(() {
//           _placeList = [];
//         });
//       }
//     });
//     _loadLocalData();
//     _getLiveLocation();
//   }

//   Future<void> _loadLocalData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('role') ?? 'Unknown';
//     final token = prefs.getString('bearer_token');
//     setState(() {
//       roleController.text = role;
//       _bearerToken = token;
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       setState(() {
//         _sessionToken = Random().nextInt(100000).toString();
//       });
//     }
//     getSuggestion(areaController.text);
//   }

//   Future<void> getSuggestion(String input) async {
//     const String PLACES_APIS_KEY = "YOUR_API_KEY_HERE";
//     try {
//       String baseURL =
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//       String request =
//           '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _getLiveLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location services are disabled.")),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Location permission denied.")));
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location permission permanently denied.")),
//       );
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _latitude = position.latitude;
//       _longitude = position.longitude;

//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _latitude!,
//         _longitude!,
//       );
//       if (placemarks.isNotEmpty) {
//         String locationName = placemarks.first.locality ??
//             placemarks.first.administrativeArea ??
//             '';
//         setState(() {
//           areaController.text = locationName;
//         });
//       }

//       await _updateLocationOnServer(_latitude!, _longitude!);
//     } catch (e) {
//       print("Location fetch error: $e");
//     }
//   }

//   Future<void> _updateLocationOnServer(double lat, double lng) async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       print("Bearer token missing, can't update location");
//       return;
//     }

//     final url = Uri.parse('$baseUrl/api/profile/update-location');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $_bearerToken',
//           'Accept': 'application/json',
//         },
//         body: {'latitude': lat.toString(), 'longitude': lng.toString()},
//       );

//       if (response.statusCode == 200) {
//         print('Location updated on server');
//       } else {
//         print('Failed to update location on server: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error updating location on server: $e');
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _submitProfile() async {
//     if (_bearerToken == null || _bearerToken!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Authentication token is missing')),
//       );
//       return;
//     }

//     final url = Uri.parse('$baseUrl/api/profile/');
//     final request = http.MultipartRequest('POST', url);

//     request.headers.addAll({
//       'Authorization': 'Bearer $_bearerToken',
//       'Accept': 'application/json',
//     });

//     request.fields['full_name'] = nameController.text;
//     request.fields['experience'] = experienceController.text;
//     request.fields['skill'] = skillsController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_latitude != null && _longitude != null) {
//       request.fields['latitude'] = _latitude.toString();
//       request.fields['longitude'] = _longitude.toString();
//     }

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
//       );
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Profile saved successfully')));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => PlumberDashboard()),
//         );
//       } else {
//         print('Failed: ${response.statusCode}');
//         print('Body: ${response.body}');
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to save profile')));
//       }
//     } catch (e) {
//       print('Error: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error saving profile')));
//     }
//   }

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     skillsController.dispose();
//     areaController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

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
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _profileImage != null
//                         ? FileImage(_profileImage!)
//                         : null,
//                     backgroundColor: Colors.grey,
//                     child: _profileImage == null
//                         ? Icon(Icons.person, size: 60, color: Colors.white)
//                         : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextButton.icon(
//                     onPressed: _pickImageFromGallery,
//                     icon: Icon(Icons.camera_alt),
//                     label: Text("Update Photo"),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             _buildLabeledTextField("Full Name", nameController),
//             _buildLabeledTextField("Experience (Years)", experienceController,
//                 type: TextInputType.number),
//             _buildLabeledTextField("Skills", skillsController),
//             _buildLabeledTextField("Service Area", areaController,
//                 readOnly: true),
//             _buildLabeledTextField("Hourly Rate (PKR)", rateController,
//                 type: TextInputType.number),
//             _buildLabeledTextField("Contact Number", contactController,
//                 type: TextInputType.phone,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(11),
//                 ]),
//             _buildLabeledTextField("Role", roleController, readOnly: true),
//             SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _submitProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
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
//     List<TextInputFormatter>? inputFormatters,
//     bool readOnly = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             keyboardType: type,
//             inputFormatters: inputFormatters,
//             readOnly: readOnly,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Enter $label',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ✅ Custom Plumber Dashboard with Gradient Background
// class PlumberDashboard extends StatelessWidget {
//   final Color darkBlue = Color(0xFF003E6B);
//   final Color tealBlue = Color(0xFF00A8A8);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [darkBlue, tealBlue],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             'Welcome to the Plumber Dashboard',
//             style: TextStyle(color: Colors.white, fontSize: 24),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/plumber_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  final TextEditingController roleController = TextEditingController();

  final FocusNode areaFocusNode = FocusNode();

  File? _profileImage;
  List<dynamic> _placeList = [];
  String _sessionToken = "1234567890";
  String? _bearerToken;

  double? _latitude;
  double? _longitude;

  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    areaController.addListener(_onChanged);
    areaFocusNode.addListener(() {
      if (!areaFocusNode.hasFocus) {
        setState(() {
          _placeList = [];
        });
      }
    });
    _loadLocalData();
    _getLiveLocation();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'Unknown';
    final token = prefs.getString('bearer_token');
    setState(() {
      roleController.text = role;
      _bearerToken = token;
    });
  }

  void _onChanged() {
    if (_sessionToken == "1234567890") {
      setState(() {
        _sessionToken = Random().nextInt(100000).toString();
      });
    }
    getSuggestion(areaController.text);
  }

  Future<void> getSuggestion(String input) async {
    const String PLACES_APIS_KEY = "YOUR_API_KEY_HERE";
    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location permission denied.")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission permanently denied.")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );
      if (placemarks.isNotEmpty) {
        String locationName = placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            '';
        setState(() {
          areaController.text = locationName;
        });
      }

      await _updateLocationOnServer(_latitude!, _longitude!);
    } catch (e) {
      print("Location fetch error: $e");
    }
  }

  Future<void> _updateLocationOnServer(double lat, double lng) async {
    if (_bearerToken == null || _bearerToken!.isEmpty) {
      print("Bearer token missing, can't update location");
      return;
    }

    final url = Uri.parse('$baseUrl/api/profile/update-location');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Accept': 'application/json',
        },
        body: {'latitude': lat.toString(), 'longitude': lng.toString()},
      );

      if (response.statusCode == 200) {
        print('Location updated on server');
      } else {
        print('Failed to update location on server: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating location on server: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_bearerToken == null || _bearerToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token is missing')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/api/profile/');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $_bearerToken',
      'Accept': 'application/json',
    });

    request.fields['full_name'] = nameController.text;
    request.fields['experience'] = experienceController.text;
    request.fields['skill'] = skillsController.text;
    request.fields['service_area'] = areaController.text;
    request.fields['hourly_rate'] = rateController.text;
    request.fields['contact_number'] = contactController.text;
    request.fields['role'] = roleController.text;

    if (_latitude != null && _longitude != null) {
      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();
    }

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('plumber_image', _profileImage!.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile saved successfully')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlumberDashboard()),
        );
      } else {
        print('Failed: ${response.statusCode}');
        print('Body: ${response.body}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save profile')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving profile')));
    }
  }

  @override
  void dispose() {
    areaFocusNode.dispose();
    nameController.dispose();
    experienceController.dispose();
    skillsController.dispose();
    areaController.dispose();
    rateController.dispose();
    contactController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plumber Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBlue, tealBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      backgroundColor: Colors.grey,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text("Update Photo",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildLabeledTextField("Full Name", nameController),
              _buildLabeledTextField("Experience (Years)", experienceController,
                  type: TextInputType.number),
              _buildLabeledTextField("Skills", skillsController),
              _buildLabeledTextField("Service Area", areaController,
                  readOnly: true),
              _buildLabeledTextField("Hourly Rate (PKR)", rateController,
                  type: TextInputType.number),
              _buildLabeledTextField("Contact Number", contactController,
                  type: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ]),
              _buildLabeledTextField("Role", roleController, readOnly: true),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text("Save Profile", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Custom Plumber Dashboard with Gradient Background
// class PlumberDashboard extends StatelessWidget {
//   final Color darkBlue = const Color(0xFF003E6B);
//   final Color tealBlue = const Color(0xFF00A8A8);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [darkBlue, tealBlue],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             'Welcome to the Plumber Dashboard',
//             style: TextStyle(color: Colors.white, fontSize: 24),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }
// }
