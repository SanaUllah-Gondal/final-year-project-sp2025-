import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/userservice/plumberservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../select_location_map.dart';
import 'plumbermodel.dart';

class PlumberDetailPage extends StatefulWidget {
  final Plumber plumber;

  const PlumberDetailPage({Key? key, required this.plumber}) : super(key: key);

  @override
  State<PlumberDetailPage> createState() => _PlumberDetailPageState();
}

class _PlumberDetailPageState extends State<PlumberDetailPage> {
  File? _selectedImage;
  final FocusNode locationFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userName = prefs.getString('user_name');
    if (userName != null) {
      _userNameController.text = userName;
    }
  }

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

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location.')),
      );
      return;
    }

    if (_userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid plumber ID.')),
        );
        return;
      }

      final uri = Uri.parse('$baseUrl/api/plumber_appointment');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['plumber_p_id'] = plumberId.toString()
        ..fields['user_p_id'] = userProfileId.toString()
        ..fields['description'] = _problemController.text
        ..fields['location'] = _locationController.text
        ..fields['user_name'] = _userNameController.text;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'p_problem_image',
          _selectedImage!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Problem submitted successfully!')),
        );

        setState(() {
          _problemController.clear();
          _locationController.clear();
          _selectedImage = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PlumberPage()),
        );
      } else {
        final body = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit problem: $body')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    _locationController.dispose();
    _userNameController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final plumber = widget.plumber;

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

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: tealBlue,
        title: Text(plumber.fullName),
      ),
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
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                        : Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              plumber.fullName,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            buildDetailRow('Experience', '${plumber.experience} years'),
            buildDetailRow('Hourly Rate', 'Rs: ${plumber.hourlyRate}/hr'),
            const SizedBox(height: 30),

            // User Name Field
            TextField(
              controller: _userNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location Field
            _buildLabeledTextField(
              "Location",
              _locationController,
              focusNode: locationFocusNode,
              readOnly: true,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SelectLocationMap()),
                );
                if (result != null) {
                  setState(() {
                    _locationController.text = result['address'];
                    // optionally: store lat/lng as well if needed
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Problem Description Field
            TextField(
              controller: _problemController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Problem Description',
                hintText: 'Describe your plumbing issue...',
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.report_problem, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upload Image Button
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

            // Selected Image Preview
            if (_selectedImage != null) ...[
              const Text('Selected Image Preview:',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Image.file(_selectedImage!, width: 150, height: 150),
              const SizedBox(height: 20),
            ],

            // Submit Button
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
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}