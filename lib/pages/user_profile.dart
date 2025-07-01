//000000000000000000000000000000000000000000000000000000000000 this code can be display only the user profile data

// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:plumber_project/pages/dashboard.dart';

// class UserProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const UserProfilePage({super.key, this.onSuccess});

//   @override
//   _UserProfilePageState createState() => _UserProfilePageState();
// }

// class _UserProfilePageState extends State<UserProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController bioController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();

//   final FocusNode locationFocusNode = FocusNode();
//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";

//   @override
//   void initState() {
//     super.initState();
//     locationController.addListener(() => _onChanged());
//     locationFocusNode.addListener(() {
//       if (!locationFocusNode.hasFocus) {
//         setState(() => _placeList = []);
//       }
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       _sessionToken = Random().nextInt(100000).toString();
//     }
//     getSuggestion(locationController.text);
//   }

//   void getSuggestion(String input) async {
//     const String PLACES_API_KEY = "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q";
//     String baseURL = 'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//     String request =
//         '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
//     try {
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print("Error getting suggestions: $e");
//     }
//   }

//   Future<void> _pickImageOption() async {
//     showModalBottomSheet(
//       context: context,
//       builder:
//           (_) => SafeArea(
//             child: Wrap(
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.camera_alt),
//                   title: Text('Camera'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromCamera();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.photo_library),
//                   title: Text('Gallery'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromGallery();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.insert_drive_file),
//                   title: Text('File'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromFile();
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() => _profileImage = File(pickedFile.path));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _profileImage = File(pickedFile.path));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() => _profileImage = File(result.files.single.path!));
//       widget.onSuccess?.call();
//     }
//   }

//   @override
//   void dispose() {
//     locationFocusNode.dispose();
//     nameController.dispose();
//     bioController.dispose();
//     locationController.dispose();
//     contactController.dispose();
//     super.dispose();
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("User Profile", style: TextStyle(color: Colors.black)),
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
//             _buildLabeledTextField("Short Bio", bioController),
//             _buildLabeledTextField(
//               "Location",
//               locationController,
//               focusNode: locationFocusNode,
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
//                       locationController.text =
//                           _placeList[index]["description"];
//                       setState(() => _placeList = []);
//                     },
//                   );
//                 },
//               ),
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
//                   backgroundColor: Colors.black,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: () {
//                   // Save profile logic here
//                   print("Profile saved");
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => HomeScreen()),
//                   );
//                 },
//                 child: Text(
//                   "Save Profile",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//00000000000000000000000000000000000000000000000000000000000 this code can be correctly working according to the backend
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:plumber_project/pages/dashboard.dart';

// class UserProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const UserProfilePage({super.key, this.onSuccess});

//   @override
//   _UserProfilePageState createState() => _UserProfilePageState();
// }

// class _UserProfilePageState extends State<UserProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController bioController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode locationFocusNode = FocusNode();
//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   @override
//   void initState() {
//     super.initState();
//     _loadRoleAndToken();
//     locationController.addListener(() => _onChanged());
//     locationFocusNode.addListener(() {
//       if (!locationFocusNode.hasFocus) {
//         setState(() => _placeList = []);
//       }
//     });
//   }

//   Future<void> _loadRoleAndToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       roleController.text = prefs.getString('role') ?? 'Unknown';
//       _bearerToken = prefs.getString('token');
//     });
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       _sessionToken = Random().nextInt(100000).toString();
//     }
//     getSuggestion(locationController.text);
//   }

//   void getSuggestion(String input) async {
//     const String PLACES_API_KEY = "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q";
//     String baseURL = 'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
//     String request =
//         '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
//     try {
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print("Error getting suggestions: $e");
//     }
//   }

//   Future<void> _pickImageOption() async {
//     showModalBottomSheet(
//       context: context,
//       builder:
//           (_) => SafeArea(
//             child: Wrap(
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.camera_alt),
//                   title: Text('Camera'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromCamera();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.photo_library),
//                   title: Text('Gallery'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromGallery();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.insert_drive_file),
//                   title: Text('File'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromFile();
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() => _profileImage = File(pickedFile.path));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _profileImage = File(pickedFile.path));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() => _profileImage = File(result.files.single.path!));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _submitProfile() async {
//     if (_bearerToken == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Bearer token not found")));
//       return;
//     }

//     var uri = Uri.parse("http://10.0.2.2:8000/api/profile/");
//     var request = http.MultipartRequest("POST", uri);
//     request.headers['Authorization'] = 'Bearer $_bearerToken';

//     request.fields['full_name'] = nameController.text;
//     request.fields['short_bio'] = bioController.text;
//     request.fields['location'] = locationController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('user_image', _profileImage!.path),
//       );
//     }

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Profile uploaded successfully");
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         print("Failed to upload profile: ${response.statusCode}");
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Failed to upload profile")));
//       }
//     } catch (e) {
//       print("Error uploading profile: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error uploading profile")));
//     }
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
//             focusNode: focusNode,
//             readOnly: readOnly,
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

//   @override
//   void dispose() {
//     locationFocusNode.dispose();
//     nameController.dispose();
//     bioController.dispose();
//     locationController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("User Profile", style: TextStyle(color: Colors.black)),
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
//             _buildLabeledTextField("Short Bio", bioController),
//             _buildLabeledTextField(
//               "Location",
//               locationController,
//               focusNode: locationFocusNode,
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
//                       locationController.text =
//                           _placeList[index]["description"];
//                       setState(() => _placeList = []);
//                     },
//                   );
//                 },
//               ),
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
//                   backgroundColor: Colors.black,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: _submitProfile,
//                 child: Text(
//                   "Save Profile",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000 this code get the live location of the user and show me the background color is white
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'package:plumber_project/pages/dashboard.dart';

// class UserProfilePage extends StatefulWidget {
//   final VoidCallback? onSuccess;

//   const UserProfilePage({super.key, this.onSuccess});

//   @override
//   _UserProfilePageState createState() => _UserProfilePageState();
// }

// class _UserProfilePageState extends State<UserProfilePage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController bioController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();
//   final TextEditingController roleController = TextEditingController();

//   final FocusNode locationFocusNode = FocusNode();
//   File? _profileImage;
//   List<dynamic> _placeList = [];
//   String _sessionToken = "1234567890";
//   String? _bearerToken;

//   Position? _currentPosition;
//   String? _currentAddress;

//   @override
//   void initState() {
//     super.initState();
//     _loadRoleAndToken();
//     _getLocationAndAddress();
//     locationController.addListener(() => _onChanged());
//     locationFocusNode.addListener(() {
//       if (!locationFocusNode.hasFocus) {
//         setState(() => _placeList = []);
//       }
//     });
//   }

//   Future<void> _loadRoleAndToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       roleController.text = prefs.getString('role') ?? 'Unknown';
//       _bearerToken = prefs.getString('bearer_token');
//     });
//   }

//   Future<void> _getLocationAndAddress() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//         final address =
//             "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

//         setState(() {
//           _currentPosition = position;
//           _currentAddress = address;
//           locationController.text = address;
//         });
//       }
//     } catch (e) {
//       print("Error fetching location: $e");
//     }
//   }

//   void _onChanged() {
//     if (_sessionToken == "1234567890") {
//       _sessionToken = Random().nextInt(100000).toString();
//     }
//     getSuggestion(locationController.text);
//   }

//   void getSuggestion(String input) async {
//     const String PLACES_API_KEY = "YOUR_GOOGLE_API_KEY_HERE";
//     String baseURL =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//     String request =
//         '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
//     try {
//       var response = await http.get(Uri.parse(request));
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       }
//     } catch (e) {
//       print("Error getting suggestions: $e");
//     }
//   }

//   Future<void> _pickImageOption() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: Icon(Icons.camera_alt),
//               title: Text('Camera'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.photo_library),
//               title: Text('Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.insert_drive_file),
//               title: Text('File'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImageFromFile();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() => _profileImage = File(pickedFile.path));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _pickImageFromFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null && result.files.single.path != null) {
//       setState(() => _profileImage = File(result.files.single.path!));
//       widget.onSuccess?.call();
//     }
//   }

//   Future<void> _submitProfile() async {
//     if (_bearerToken == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Bearer token not found")));
//       return;
//     }

//     var uri = Uri.parse("$baseUrl/api/profile/");
//     var request = http.MultipartRequest("POST", uri);
//     request.headers['Authorization'] = 'Bearer $_bearerToken';

//     request.fields['full_name'] = nameController.text;
//     request.fields['short_bio'] = bioController.text;
//     request.fields['location'] = locationController.text;
//     request.fields['contact_number'] = contactController.text;
//     request.fields['role'] = roleController.text;

//     if (_currentPosition != null) {
//       request.fields['latitude'] = _currentPosition!.latitude.toString();
//       request.fields['longitude'] = _currentPosition!.longitude.toString();
//     }

//     if (_profileImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('user_image', _profileImage!.path),
//       );
//     }

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         print("Failed to upload: ${response.statusCode}");
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Failed to upload profile")));
//       }
//     } catch (e) {
//       print("Upload error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error uploading profile")));
//     }
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
//             focusNode: focusNode,
//             readOnly: readOnly,
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

//   @override
//   void dispose() {
//     locationFocusNode.dispose();
//     nameController.dispose();
//     bioController.dispose();
//     locationController.dispose();
//     contactController.dispose();
//     roleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("User Profile", style: TextStyle(color: Colors.black)),
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
//                     onPressed: _pickImageOption,
//                     icon: Icon(Icons.camera_alt),
//                     label: Text("Update Photo"),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             _buildLabeledTextField("Full Name", nameController),
//             _buildLabeledTextField("Short Bio", bioController),
//             _buildLabeledTextField(
//               "Location",
//               locationController,
//               focusNode: locationFocusNode,
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
//                       locationController.text =
//                           _placeList[index]["description"];
//                       setState(() => _placeList = []);
//                     },
//                   );
//                 },
//               ),
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
//                   backgroundColor: Colors.black,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 onPressed: _submitProfile,
//                 child: Text(
//                   "Save Profile",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/select_location_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plumber_project/pages/dashboard.dart';

class UserProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;
  const UserProfilePage({super.key, this.onSuccess});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final FocusNode locationFocusNode = FocusNode();
  File? _profileImage;
  List<dynamic> _placeList = [];
  String _sessionToken = "1234567890";
  String? _bearerToken;

  Position? _currentPosition;
  String? _currentAddress;

  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    _loadRoleAndToken();
    _getLocationAndAddress();
    locationFocusNode.addListener(() {
      if (!locationFocusNode.hasFocus) {
        setState(() => _placeList = []);
      }
    });
  }

  Future<void> _loadRoleAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roleController.text = prefs.getString('role') ?? 'Unknown';
      _bearerToken = prefs.getString('bearer_token');
    });
  }

  Future<void> _getLocationAndAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          locationController.text = address;
        });
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }



  Future<void> _pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
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
                _pickImageFromFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
      widget.onSuccess?.call();
    }
  }

  Future<void> _pickImageFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _profileImage = File(result.files.single.path!));
      widget.onSuccess?.call();
    }
  }

  Future<void> _submitProfile() async {
    if (_bearerToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bearer token not found")),
      );
      return;
    }

    var uri = Uri.parse("$baseUrl/api/profile/");
    var request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $_bearerToken';

    request.fields['full_name'] = nameController.text;
    request.fields['short_bio'] = bioController.text;
    request.fields['location'] = locationController.text;
    request.fields['contact_number'] = contactController.text;
    request.fields['role'] = roleController.text;

    if (_currentPosition != null) {
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();
    }

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('user_image', _profileImage!.path),
      );
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile")),
        );
        print('Error with status code: ${response.statusCode}');

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading profile")),
      );
    }
  }

  Widget _buildLabeledTextField(
      String label,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        FocusNode? focusNode,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            focusNode: focusNode,
            readOnly: readOnly,
            onTap: onTap,
            inputFormatters: inputFormatters,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    locationFocusNode.dispose();
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    contactController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text("User Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: tealBlue,
        iconTheme: IconThemeData(color: Colors.white),
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
                    onPressed: _pickImageOption,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text("Update Photo",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildLabeledTextField("Full Name", nameController),
            _buildLabeledTextField("Short Bio", bioController),
            _buildLabeledTextField(
              "Location",
              locationController,
              focusNode: locationFocusNode,
              readOnly: true,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SelectLocationMap()),
                );
                if (result != null) {
                  setState(() {
                    locationController.text = result['address'];
                    // optionally: store lat/lng as well if needed
                  });
                }
              },
            ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: _submitProfile,
                child: Text("Save Profile", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
