import 'package:flutter/material.dart';
import 'pages/login.dart'; // Import the login screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'Flutter Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Set LoginScreen as the home screen
    );
  }
}
