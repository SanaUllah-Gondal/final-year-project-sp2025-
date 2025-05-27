// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';

// class PlumberDetailPage extends StatelessWidget {
//   final Plumber plumber;

//   const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Build the full URL for the plumber image
//     final String imageUrl =
//         plumber.plumberImage != null
//             ? 'http://10.0.2.2:8000/uploads/plumber_image/${plumber.plumberImage}'
//             : '';

//     return Scaffold(
//       appBar: AppBar(title: Text(plumber.fullName)),
//       body: SingleChildScrollView(
//         // ✅ added scroll to avoid overflow
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ClipOval(
//                 child:
//                     plumber.plumberImage != null
//                         ? Image.network(
//                           imageUrl,
//                           width: 120,
//                           height: 120,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             // if image not found
//                             return Image.asset(
//                               'assets/images/placeholder.png',
//                               width: 120,
//                               height: 120,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         )
//                         : Image.asset(
//                           'assets/images/placeholder.png',
//                           width: 120,
//                           height: 120,
//                           fit: BoxFit.cover,
//                         ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               plumber.fullName,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             buildDetailRow('Experience', '${plumber.experience} years'),
//             buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
//             // buildDetailRow('Skill', plumber.skill ?? 'N/A'),
//             // buildDetailRow('Service Area', plumber.serviceArea ?? 'N/A'),
//             // buildDetailRow('Contact Number', plumber.contactNumber ?? 'N/A'),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper Widget for clean details
//   Widget buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "$title:",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }

//000000000000000000000000000000000000000000000000000000000000000000000000 this code only display the front end of the plumber detail
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';

// class PlumberDetailPage extends StatefulWidget {
//   final Plumber plumber;

//   const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

//   @override
//   State<PlumberDetailPage> createState() => _PlumberDetailPageState();
// }

// class _PlumberDetailPageState extends State<PlumberDetailPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _problemController = TextEditingController();

//   // Show image picker bottom sheet
//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.gallery);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text('Files'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   FilePickerResult? result =
//                       await FilePicker.platform.pickFiles(type: FileType.image);
//                   if (result != null && result.files.single.path != null) {
//                     setState(
//                         () => _selectedImage = File(result.files.single.path!));
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Submit problem (dummy implementation)
//   void _submitProblem() {
//     if (_problemController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the problem description.')),
//       );
//       return;
//     }

//     // Replace this with actual API call to submit data
//     print("Problem: ${_problemController.text}");
//     print("Selected Image: ${_selectedImage?.path}");

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Problem submitted successfully!')),
//     );

//     // Clear form
//     setState(() {
//       _problemController.clear();
//       _selectedImage = null;
//     });
//   }

//   @override
//   void dispose() {
//     _problemController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final plumber = widget.plumber;

//     // Plumber image URL from backend
//     final String imageUrl = plumber.plumberImage != null
//         ? 'http://10.0.2.2:8000/uploads/plumber_image/${plumber.plumberImage}'
//         : '';

//     return Scaffold(
//       appBar: AppBar(title: Text(plumber.fullName)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // 👤 Plumber profile image (server or selected)
//             Center(
//               child: ClipOval(
//                 child: _selectedImage != null
//                     // 📷 Show newly selected image
//                     ? Image.file(
//                         _selectedImage!,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                       )
//                     // 🌐 Fetch plumber image from server (if available)
//                     : (plumber.plumberImage != null
//                         ? Image.network(
//                             imageUrl,
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Image.asset(
//                                 'assets/images/placeholder.png',
//                                 width: 120,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               );
//                             },
//                           )
//                         // 🧱 Local placeholder if no image
//                         : Image.asset(
//                             'assets/images/placeholder.png',
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                           )),
//               ),
//             ),

//             const SizedBox(height: 20),
//             Text(
//               plumber.fullName,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             buildDetailRow('Experience', '${plumber.experience} years'),
//             buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),

//             const SizedBox(height: 30),

//             // 🔼 Upload new problem image
//             ElevatedButton.icon(
//               onPressed: _showImageSourceOptions,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload Problem Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber[700],
//                 foregroundColor: Colors.black,
//               ),
//             ),

//             const SizedBox(height: 20),

//             // 🖼️ Preview selected image
//             if (_selectedImage != null)
//               Column(
//                 children: [
//                   const Text('Selected Image Preview:'),
//                   const SizedBox(height: 10),
//                   Image.file(_selectedImage!, width: 150, height: 150),
//                 ],
//               ),

//             const SizedBox(height: 30),

//             // 📝 Problem description
//             TextField(
//               controller: _problemController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your problem',
//                 hintText: 'Describe your plumbing issue...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.report_problem),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // 🚀 Submit button
//             ElevatedButton.icon(
//               onPressed: _submitProblem,
//               icon: const Icon(Icons.send),
//               label: const Text('Submit Problem'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper to build profile detail rows
//   Widget buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "$title:",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';

// class PlumberDetailPage extends StatefulWidget {
//   final Plumber plumber;

//   const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

//   @override
//   State<PlumberDetailPage> createState() => _PlumberDetailPageState();
// }

// class _PlumberDetailPageState extends State<PlumberDetailPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _problemController = TextEditingController();

//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.gallery);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text('Files'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   FilePickerResult? result =
//                       await FilePicker.platform.pickFiles(type: FileType.image);
//                   if (result != null && result.files.single.path != null) {
//                     setState(
//                         () => _selectedImage = File(result.files.single.path!));
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _submitProblem() async {
//     if (_problemController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the problem description.')),
//       );
//       return;
//     }

//     try {
//       final prefs = await SharedPreferences.getInstance();

//       final String? token = prefs.getString('bearer_token');
//       final int? userId = prefs.getInt('user_id');

//       if (token == null || userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User not authenticated.')),
//         );
//         return;
//       }

//       var uri = Uri.parse('$baseUrl/api/plumber_appointment');
//       var request = http.MultipartRequest('POST', uri);

//       request.headers['Authorization'] = 'Bearer $token';

//       request.fields['user_p_id'] = userId.toString();
//       request.fields['plumber_p_id'] = widget.plumber.id.toString();
//       request.fields['description'] = _problemController.text;

//       if (_selectedImage != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'p_problem_image',
//           _selectedImage!.path,
//         ));
//       }

//       var response = await request.send();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Problem submitted successfully!')),
//         );

//         setState(() {
//           _problemController.clear();
//           _selectedImage = null;
//         });

//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberPage()),
//         );
//       } else {
//         final body = await response.stream.bytesToString();
//         print("Error: ${response.statusCode}, Body: $body");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print("Exception: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred. Please try again.')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _problemController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final plumber = widget.plumber;

//     final String imageUrl = plumber.plumberImage != null
//         ? '$baseUrl/uploads/plumber_image/${plumber.plumberImage}'
//         : '';

//     return Scaffold(
//       appBar: AppBar(title: Text(plumber.fullName)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ClipOval(
//                 child: _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                       )
//                     : (plumber.plumberImage != null
//                         ? Image.network(
//                             imageUrl,
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Image.asset(
//                                 'assets/images/placeholder.png',
//                                 width: 120,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               );
//                             },
//                           )
//                         : Image.asset(
//                             'assets/images/placeholder.png',
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                           )),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               plumber.fullName,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             buildDetailRow('Experience', '${plumber.experience} years'),
//             buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _showImageSourceOptions,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload Problem Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber[700],
//                 foregroundColor: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_selectedImage != null)
//               Column(
//                 children: [
//                   const Text('Selected Image Preview:'),
//                   const SizedBox(height: 10),
//                   Image.file(_selectedImage!, width: 150, height: 150),
//                 ],
//               ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _problemController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your problem',
//                 hintText: 'Describe your plumbing issue...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.report_problem),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _submitProblem,
//               icon: const Icon(Icons.send),
//               label: const Text('Submit Problem'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "$title:",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }

//0000000000000000000000000000000000000000000000000000000 yai code sirf plumber ki id nhi bhaij raha baaki saaara kuch bhaij raha hai
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/userservice/plumbermodel.dart';

// class PlumberDetailPage extends StatefulWidget {
//   final Plumber plumber;

//   const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

//   @override
//   State<PlumberDetailPage> createState() => _PlumberDetailPageState();
// }

// class _PlumberDetailPageState extends State<PlumberDetailPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _problemController = TextEditingController();

//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.gallery);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text('Files'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   FilePickerResult? result =
//                       await FilePicker.platform.pickFiles(type: FileType.image);
//                   if (result != null && result.files.single.path != null) {
//                     setState(
//                         () => _selectedImage = File(result.files.single.path!));
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _submitProblem() async {
//     if (_problemController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the problem description.')),
//       );
//       return;
//     }

//     try {
//       final prefs = await SharedPreferences.getInstance();

//       final String? token = prefs.getString('bearer_token');
//       final int? userId = prefs.getInt('user_id');

//       if (token == null || userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User not authenticated.')),
//         );
//         return;
//       }

//       var uri = Uri.parse('$baseUrl/api/plumber_appointment');
//       var request = http.MultipartRequest('POST', uri);

//       request.headers['Authorization'] = 'Bearer $token';

//       request.fields['user_p_id'] = userId.toString();
//       request.fields['plumber_p_id'] = widget.plumber.id.toString();
//       request.fields['description'] = _problemController.text;

//       if (_selectedImage != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'p_problem_image',
//           _selectedImage!.path,
//         ));
//       }

//       var response = await request.send();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Problem submitted successfully!')),
//         );

//         setState(() {
//           _problemController.clear();
//           _selectedImage = null;
//         });

//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberPage()),
//         );
//       } else {
//         final body = await response.stream.bytesToString();
//         print("Error: ${response.statusCode}, Body: $body");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print("Exception: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred. Please try again.')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _problemController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final plumber = widget.plumber;

//     // ✅ Fixed image URL construction
//     final String imageUrl = (plumber.plumberImage != null &&
//             !plumber.plumberImage!.startsWith('http'))
//         ? '$baseUrl/uploads/plumber_image/${plumber.plumberImage}'
//         : (plumber.plumberImage ?? '');

//     return Scaffold(
//       appBar: AppBar(title: Text(plumber.fullName)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ClipOval(
//                 child: _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                       )
//                     : (imageUrl.isNotEmpty
//                         ? Image.network(
//                             imageUrl,
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Image.asset(
//                                 'assets/images/placeholder.png',
//                                 width: 120,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               );
//                             },
//                           )
//                         : Image.asset(
//                             'assets/images/placeholder.png',
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                           )),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               plumber.fullName,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             buildDetailRow('Experience', '${plumber.experience} years'),
//             buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _showImageSourceOptions,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload Problem Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber[700],
//                 foregroundColor: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_selectedImage != null)
//               Column(
//                 children: [
//                   const Text('Selected Image Preview:'),
//                   const SizedBox(height: 10),
//                   Image.file(_selectedImage!, width: 150, height: 150),
//                 ],
//               ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _problemController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your problem',
//                 hintText: 'Describe your plumbing issue...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.report_problem),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _submitProblem,
//               icon: const Icon(Icons.send),
//               label: const Text('Submit Problem'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "$title:",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }

//00000000000000000000000000000000000000000000000000000000000000000000000000000 yai code plumber ki profile id bhaij raha hai
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'plumbermodel.dart'; // adjust the import path as needed

// class PlumberDetailPage extends StatefulWidget {
//   final Plumber plumber;

//   const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

//   @override
//   State<PlumberDetailPage> createState() => _PlumberDetailPageState();
// }

// class _PlumberDetailPageState extends State<PlumberDetailPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _problemController = TextEditingController();

//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.gallery);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text('Files'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   FilePickerResult? result =
//                       await FilePicker.platform.pickFiles(type: FileType.image);
//                   if (result != null && result.files.single.path != null) {
//                     setState(
//                         () => _selectedImage = File(result.files.single.path!));
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _submitProblem() async {
//     if (_problemController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the problem description.')),
//       );
//       return;
//     }

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('bearer_token');
//       final int? userId = prefs.getInt('user_id');

//       if (token == null || userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User not authenticated.')),
//         );
//         return;
//       }

//       final int plumberId = widget.plumber.id;
//       if (plumberId == 0) {
//         print("ERROR: Plumber ID is 0. This is likely a model or data issue.");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid plumber ID.')),
//         );
//         return;
//       }

//       print("Preparing to send plumber appointment:");
//       print("Plumber ID: $plumberId");
//       print("User ID: $userId");
//       print("Problem Description: ${_problemController.text}");

//       final uri = Uri.parse('$baseUrl/api/plumber_appointment');
//       final request = http.MultipartRequest('POST', uri)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['plumber_p_id'] = plumberId.toString()
//         ..fields['user_p_id'] = userId.toString()
//         ..fields['description'] = _problemController.text;

//       if (_selectedImage != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'p_problem_image',
//           _selectedImage!.path,
//         ));
//         print("Image attached: ${_selectedImage!.path}");
//       } else {
//         print("No image attached.");
//       }

//       final response = await request.send();

//       print('API Response Status: ${response.statusCode}');
//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Problem submitted successfully!')),
//         );

//         setState(() {
//           _problemController.clear();
//           _selectedImage = null;
//         });

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberPage()),
//         );
//       } else {
//         final body = await response.stream.bytesToString();
//         print("Error: ${response.statusCode}");
//         print("Response body: $body");

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   'Failed to submit problem. Status: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print("Exception during submit: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred. Please try again.')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _problemController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final plumber = widget.plumber;

//     final String imageUrl = (plumber.plumberImage != null &&
//             !plumber.plumberImage!.startsWith('http'))
//         ? '$baseUrl/uploads/plumber_image/${plumber.plumberImage}'
//         : (plumber.plumberImage ?? '');

//     return Scaffold(
//       appBar: AppBar(title: Text(plumber.fullName)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ClipOval(
//                 child: _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                       )
//                     : (imageUrl.isNotEmpty
//                         ? Image.network(
//                             imageUrl,
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Image.asset(
//                                 'assets/images/placeholder.png',
//                                 width: 120,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               );
//                             },
//                           )
//                         : Image.asset(
//                             'assets/images/placeholder.png',
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                           )),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               plumber.fullName,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             buildDetailRow('Experience', '${plumber.experience} years'),
//             buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _showImageSourceOptions,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload Problem Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber[700],
//                 foregroundColor: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_selectedImage != null)
//               Column(
//                 children: [
//                   const Text('Selected Image Preview:'),
//                   const SizedBox(height: 10),
//                   Image.file(_selectedImage!, width: 150, height: 150),
//                 ],
//               ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _problemController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your problem',
//                 hintText: 'Describe your plumbing issue...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.report_problem),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _submitProblem,
//               icon: const Icon(Icons.send),
//               label: const Text('Submit Problem'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "$title:",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }

//0000000000000000000000000000000000000000000000000000000000000000000000000 yai sirf picture nhi dikhaa rha plumber ki
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'plumbermodel.dart'; // adjust the import path as needed

// class PlumberDetailPage extends StatefulWidget {
//   final Plumber plumber;

//   const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

//   @override
//   State<PlumberDetailPage> createState() => _PlumberDetailPageState();
// }

// class _PlumberDetailPageState extends State<PlumberDetailPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _problemController = TextEditingController();

//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   final XFile? image =
//                       await _picker.pickImage(source: ImageSource.gallery);
//                   if (image != null) {
//                     setState(() => _selectedImage = File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text('Files'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   FilePickerResult? result =
//                       await FilePicker.platform.pickFiles(type: FileType.image);
//                   if (result != null && result.files.single.path != null) {
//                     setState(
//                         () => _selectedImage = File(result.files.single.path!));
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _submitProblem() async {
//     if (_problemController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the problem description.')),
//       );
//       return;
//     }

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('bearer_token');

//       // Fetch user_profile_id instead of user_id
//       final int? userProfileId = prefs.getInt('user_profile_id');

//       if (token == null || userProfileId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('User not authenticated or profile ID missing.')),
//         );
//         return;
//       }

//       final int plumberId = widget.plumber.id;
//       if (plumberId == 0) {
//         print("ERROR: Plumber ID is 0. This is likely a model or data issue.");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid plumber ID.')),
//         );
//         return;
//       }

//       print("Preparing to send plumber appointment:");
//       print("Plumber ID: $plumberId");
//       print("User Profile ID: $userProfileId");
//       print("Problem Description: ${_problemController.text}");

//       final uri = Uri.parse('$baseUrl/api/plumber_appointment');
//       final request = http.MultipartRequest('POST', uri)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['plumber_p_id'] = plumberId.toString()
//         ..fields['user_p_id'] = userProfileId.toString() // <-- changed here
//         ..fields['description'] = _problemController.text;

//       if (_selectedImage != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'p_problem_image',
//           _selectedImage!.path,
//         ));
//         print("Image attached: ${_selectedImage!.path}");
//       } else {
//         print("No image attached.");
//       }

//       final response = await request.send();

//       print('API Response Status: ${response.statusCode}');
//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Problem submitted successfully!')),
//         );

//         setState(() {
//           _problemController.clear();
//           _selectedImage = null;
//         });

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => PlumberPage()),
//         );
//       } else {
//         final body = await response.stream.bytesToString();
//         print("Error: ${response.statusCode}");
//         print("Response body: $body");

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   'Failed to submit problem. Status: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print("Exception during submit: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('An error occurred. Please try again.')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _problemController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final plumber = widget.plumber;

//     final String imageUrl = (plumber.plumberImage != null &&
//             !plumber.plumberImage!.startsWith('http'))
//         ? '$baseUrl/uploads/plumber_image/${plumber.plumberImage}'
//         : (plumber.plumberImage ?? '');

//     return Scaffold(
//       appBar: AppBar(title: Text(plumber.fullName)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ClipOval(
//                 child: _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                       )
//                     : (imageUrl.isNotEmpty
//                         ? Image.network(
//                             imageUrl,
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Image.asset(
//                                 'assets/images/placeholder.png',
//                                 width: 120,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               );
//                             },
//                           )
//                         : Image.asset(
//                             'assets/images/placeholder.png',
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                           )),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               plumber.fullName,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             buildDetailRow('Experience', '${plumber.experience} years'),
//             buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _showImageSourceOptions,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload Problem Image'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber[700],
//                 foregroundColor: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_selectedImage != null)
//               Column(
//                 children: [
//                   const Text('Selected Image Preview:'),
//                   const SizedBox(height: 10),
//                   Image.file(_selectedImage!, width: 150, height: 150),
//                 ],
//               ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _problemController,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your problem',
//                 hintText: 'Describe your plumbing issue...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.report_problem),
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _submitProblem,
//               icon: const Icon(Icons.send),
//               label: const Text('Submit Problem'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               "$title:",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/userservice/plumberservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plumbermodel.dart'; // adjust the import path as needed

class PlumberDetailPage extends StatefulWidget {
  final Plumber plumber;

  const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

  @override
  State<PlumberDetailPage> createState() => _PlumberDetailPageState();
}

class _PlumberDetailPageState extends State<PlumberDetailPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _problemController = TextEditingController();

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() => _selectedImage = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => _selectedImage = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Files'),
                onTap: () async {
                  Navigator.of(context).pop();
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.path != null) {
                    setState(
                        () => _selectedImage = File(result.files.single.path!));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitProblem() async {
    if (_problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the problem description.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('bearer_token');
      final int? userProfileId = prefs.getInt('user_profile_id');

      if (token == null || userProfileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User not authenticated or profile ID missing.')),
        );
        return;
      }

      final int plumberId = widget.plumber.id;
      if (plumberId == 0) {
        print("ERROR: Plumber ID is 0. This is likely a model or data issue.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid plumber ID.')),
        );
        return;
      }

      print("Preparing to send plumber appointment:");
      print("Plumber ID: $plumberId");
      print("User Profile ID: $userProfileId");
      print("Problem Description: ${_problemController.text}");

      final uri = Uri.parse('$baseUrl/api/plumber_appointment');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['plumber_p_id'] = plumberId.toString()
        ..fields['user_p_id'] = userProfileId.toString()
        ..fields['description'] = _problemController.text;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'p_problem_image',
          _selectedImage!.path,
        ));
        print("Image attached: ${_selectedImage!.path}");
      } else {
        print("No image attached.");
      }

      final response = await request.send();

      print('API Response Status: ${response.statusCode}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Problem submitted successfully!')),
        );

        setState(() {
          _problemController.clear();
          _selectedImage = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PlumberPage()),
        );
      } else {
        final body = await response.stream.bytesToString();
        print("Error: ${response.statusCode}");
        print("Response body: $body");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to submit problem. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Exception during submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plumber = widget.plumber;

    // Construct the image URL properly with checks
    String? imageUrl;
    if (plumber.plumberImage != null && plumber.plumberImage!.isNotEmpty) {
      if (plumber.plumberImage!.startsWith('http')) {
        imageUrl = plumber.plumberImage!;
      } else {
        final baseImageUrl = baseUrl.endsWith('/')
            ? '${baseUrl}uploads/plumber_image/'
            : '$baseUrl/uploads/plumber_image/';
        imageUrl = '$baseImageUrl${plumber.plumberImage}';
      }
    }

    print('Plumber Image URL: $imageUrl');

    return Scaffold(
      appBar: AppBar(title: Text(plumber.fullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : (imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Image loading failed: $error');
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              plumber.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildDetailRow('Experience', '${plumber.experience} years'),
            buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _showImageSourceOptions,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Problem Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Column(
                children: [
                  const Text('Selected Image Preview:'),
                  const SizedBox(height: 10),
                  Image.file(_selectedImage!, width: 150, height: 150),
                ],
              ),
            const SizedBox(height: 30),
            TextField(
              controller: _problemController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Enter your problem',
                hintText: 'Describe your plumbing issue...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.report_problem),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitProblem,
              icon: const Icon(Icons.send),
              label: const Text('Submit Problem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
