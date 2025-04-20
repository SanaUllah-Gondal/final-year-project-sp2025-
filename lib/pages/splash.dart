import 'package:flutter/material.dart';
import 'package:plumber_project/pages/login.dart';
import 'dart:async';
// import 'home.dart'; // Make sure this points to your HomeScreen file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds, then navigate
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_service, color: Colors.black, size: 80),
            SizedBox(height: 20),
            Text(
              'Skill-Link',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.cyan),
          ],
        ),
      ),
    );
  }
}
