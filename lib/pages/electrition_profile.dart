//00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 Simple form only
// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/dashboard.dart';

// class ElectricianProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const ElectricianProfilePage({super.key, this.onSuccess});

//   @override
//   _ElectricianProfilePageState createState() => _ElectricianProfilePageState();
// }

// class _ElectricianProfilePageState extends State<ElectricianProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController experienceController = TextEditingController();
//   final TextEditingController expertiseController = TextEditingController();
//   final TextEditingController areaController = TextEditingController();
//   final TextEditingController rateController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
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

//   @override
//   void dispose() {
//     areaFocusNode.dispose();
//     nameController.dispose();
//     experienceController.dispose();
//     expertiseController.dispose();
//     areaController.dispose();
//     rateController.dispose();
//     contactController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Electrician Profile",
//           style: TextStyle(color: Colors.black),
//         ),
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
//             _buildLabeledTextField(
//               "Area of Expertise (e.g. wiring, panel installation)",
//               expertiseController,
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
//                   print("Name: ${nameController.text}");
//                   print("Expertise: ${expertiseController.text}");
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

//000000000000000000000000000000000000000000000000000000000000 complete code with the post the datails in the database000000000000000000000000

// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/electrition_dashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/dashboard.dart';

// class ElectricianProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const ElectricianProfilePage({super.key, this.onSuccess});

//   @override
//   _ElectricianProfilePageState createState() => _ElectricianProfilePageState();
// }

// class _ElectricianProfilePageState extends State<ElectricianProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController experienceController = TextEditingController();
//   final TextEditingController expertiseController = TextEditingController();
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
//     request.fields['skill'] = expertiseController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'electrician_image',
//           _profileImage!.path,
//         ),
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
//           MaterialPageRoute(builder: (context) => ElectricianDashboard()),
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
//     expertiseController.dispose();
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
//         title: Text(
//           "Electrician Profile",
//           style: TextStyle(color: Colors.black),
//         ),
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
//             _buildLabeledTextField("Area of Expertise", expertiseController),
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

// import 'dart:convert';
// import 'dart:math';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/electrition_dashboard.dart';

// class ElectricianProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const ElectricianProfilePage({super.key, this.onSuccess});

//   @override
//   _ElectricianProfilePageState createState() => _ElectricianProfilePageState();
// }

// class _ElectricianProfilePageState extends State<ElectricianProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController experienceController = TextEditingController();
//   final TextEditingController expertiseController = TextEditingController();
//   final TextEditingController areaController = TextEditingController();
//   final TextEditingController rateController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode areaFocusNode = FocusNode();

//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   String? _currentAddress;
//   Position? _currentPosition;

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
//     _getCurrentLocation();
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

//   Future<void> _getCurrentLocation() async {
//     var permission = await Permission.location.request();
//     if (permission.isGranted) {
//       _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _currentAddress =
//             "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
//       });
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Location permission denied')));
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
//     request.fields['skill'] = expertiseController.text;
//     request.fields['service_area'] = areaController.text;
//     request.fields['hourly_rate'] = rateController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_currentPosition != null) {
//       request.fields['latitude'] = _currentPosition!.latitude.toString();
//       request.fields['longitude'] = _currentPosition!.longitude.toString();
//     }

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'electrician_image',
//           _profileImage!.path,
//         ),
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
//           MaterialPageRoute(builder: (context) => ElectricianDashboard()),
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
//     expertiseController.dispose();
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
//         title: Text(
//           "Electrician Profile",
//           style: TextStyle(color: Colors.black),
//         ),
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
//             _buildLabeledTextField("Area of Expertise", expertiseController),
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
//             if (_currentAddress != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Live Location",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     TextField(
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         hintText: _currentAddress,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
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

// 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000 this code get the live location of the user
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/electrition_dashboard.dart';

class ElectricianProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;

  const ElectricianProfilePage({Key? key, this.onSuccess}) : super(key: key);

  @override
  _ElectricianProfilePageState createState() => _ElectricianProfilePageState();
}

class _ElectricianProfilePageState extends State<ElectricianProfilePage> {
  final nameController = TextEditingController();
  final experienceController = TextEditingController();
  final expertiseController = TextEditingController();
  final rateController = TextEditingController();
  final contactController = TextEditingController();
  final roleController = TextEditingController();

  File? _profileImage;
  String? _bearerToken;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getLocationAndAddress();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    roleController.text = prefs.getString('role') ?? 'Unknown';
    _bearerToken = prefs.getString('token');
  }

  Future<void> _getLocationAndAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location services are disabled')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission permanently denied. Open settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Position fetched: ${position.latitude}, ${position.longitude}");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        print("Detected Address: $address");

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No address found')));
      }
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  Future<void> _pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('File'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFileImage();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _pickFileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _profileImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_bearerToken == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Token not found')));
      return;
    }

    final url = Uri.parse('$baseUrl/api/profile/');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_bearerToken';

    request.fields.addAll({
      'full_name': nameController.text,
      'experience': experienceController.text,
      'skill': expertiseController.text,
      'hourly_rate': rateController.text,
      'contact_number': contactController.text,
      'role': roleController.text,
      if (_currentAddress != null) 'service_area': _currentAddress!,
      if (_currentPosition != null) ...{
        'latitude': _currentPosition!.latitude.toString(),
        'longitude': _currentPosition!.longitude.toString(),
      },
    });

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'electrician_image',
          _profileImage!.path,
        ),
      );
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile saved')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ElectricianDashboard()),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile')));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile')));
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            readOnly: readOnly,
            inputFormatters: formatters,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Electrician Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
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
            _buildField("Full Name", nameController),
            _buildField(
              "Experience (Years)",
              experienceController,
              type: TextInputType.number,
            ),
            _buildField("Skills ", expertiseController),
            _buildField(
              "Hourly Rate (PKR)",
              rateController,
              type: TextInputType.number,
            ),
            _buildField(
              "Contact Number",
              contactController,
              type: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),
            _buildField("Role", roleController, readOnly: true),
            if (_currentAddress != null)
              _buildField(
                "Live Location",
                TextEditingController(text: _currentAddress),
                readOnly: true,
              ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
