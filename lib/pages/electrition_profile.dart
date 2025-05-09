import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plumber_project/pages/dashboard.dart';

class ElectricianProfilePage extends StatefulWidget {
  final VoidCallback? onSuccess;

  const ElectricianProfilePage({super.key, this.onSuccess});

  @override
  _ElectricianProfilePageState createState() => _ElectricianProfilePageState();
}

class _ElectricianProfilePageState extends State<ElectricianProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController expertiseController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final FocusNode areaFocusNode = FocusNode();

  File? _profileImage;
  List<dynamic> _placeList = [];
  String _sessionToken = "1234567890";

  @override
  void initState() {
    super.initState();

    areaController.addListener(() {
      _onChanged();
    });

    areaFocusNode.addListener(() {
      if (!areaFocusNode.hasFocus) {
        setState(() {
          _placeList = [];
        });
      }
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

  void getSuggestion(String input) async {
    const String PLACES_APIS_KEY = "AlzaSy-OlLUpEPkMXTNGdJFOW7sDNm1n9Rdk87Q";
    try {
      String baseURL =
          'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_APIS_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load prediction');
      }
    } catch (e) {
      print(e);
    }
  }

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
  void dispose() {
    areaFocusNode.dispose();
    nameController.dispose();
    experienceController.dispose();
    expertiseController.dispose();
    areaController.dispose();
    rateController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Electrician Profile",
          style: TextStyle(color: Colors.black),
        ),
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
              "Area of Expertise (e.g. wiring, panel installation)",
              expertiseController,
            ),
            _buildLabeledTextField(
              "Service Area",
              areaController,
              focusNode: areaFocusNode,
            ),
            if (_placeList.isNotEmpty)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _placeList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_placeList[index]["description"]),
                    onTap: () {
                      areaController.text = _placeList[index]["description"];
                      setState(() {
                        _placeList = [];
                      });
                    },
                  );
                },
              ),
            _buildLabeledTextField(
              "Hourly Rate (PKR)",
              rateController,
              type: TextInputType.number,
            ),
            _buildLabeledTextField(
              "Contact Number",
              contactController,
              type: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
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
                  print("Expertise: ${expertiseController.text}");
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
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
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
            focusNode: focusNode,
            inputFormatters: inputFormatters,
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
