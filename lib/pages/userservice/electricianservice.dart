import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:plumber_project/pages/userservice/electricianmodel.dart'; // <-- Updated model
import 'package:shared_preferences/shared_preferences.dart';

class ElectricianPage extends StatefulWidget {
  @override
  _ElectricianPageState createState() => _ElectricianPageState();
}

class _ElectricianPageState extends State<ElectricianPage> {
  List<Electrician> _electricians = [];
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
  }

  Future<void> loadTokenAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      fetchElectricians();
    } else {
      setState(() => _loading = false);
      _showError('Authentication token missing. Please login again.');
    }
  }

  Future<void> fetchElectricians() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['data'] != null && data['data'] is List) {
          final List<dynamic> allProfiles = data['data'];

          final electriciansJson =
              allProfiles
                  .where((profile) => profile['role'] == 'electrician')
                  .toList();

          setState(() {
            _electricians =
                electriciansJson
                    .map((json) => Electrician.fromJson(json))
                    .toList();
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
          _showError('Invalid data format received from server.');
        }
      } else {
        setState(() => _loading = false);
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to fetch electricians. Please check your connection.');
      print('Error fetching electricians: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Electrician Services')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _electricians.isEmpty
              ? Center(child: Text('No electricians found.'))
              : ListView.builder(
                itemCount: _electricians.length,
                itemBuilder: (context, index) {
                  final electrician = _electricians[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            electrician.electricianImage != null &&
                                    electrician.electricianImage.isNotEmpty
                                ? NetworkImage(
                                  'http://10.0.2.2:8000/uploads/electrician_image/${electrician.electricianImage}',
                                )
                                : AssetImage(
                                      'assets/images/default_profile.png',
                                    )
                                    as ImageProvider, // Default local image
                      ),
                      title: Text(electrician.fullName),
                      subtitle: Text(
                        '${electrician.experience} years experience',
                      ),
                      trailing: Text('\RS:${electrician.hourlyRate}/hr'),
                    ),
                  );
                },
              ),
    );
  }
}
