import 'package:flutter/material.dart';
import 'package:plumber_project/pages/splash.dart';
// Import the login screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'Flutter Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Set LoginScreen as the home screen
    );
  }
}
