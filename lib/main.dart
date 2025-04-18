// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/splash.dart';
// import 'package:plumber_project/pages/theme.dart';
// // Import the login screen

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   static _MyAppState? of(BuildContext context) =>
//       context.findAncestorStateOfType<_MyAppState>();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Removes the debug banner
//       title: 'Flutter Login App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: SplashScreen(), // Set LoginScreen as the home screen
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:plumber_project/pages/splash.dart';
import 'package:plumber_project/pages/theme.dart'; // Make sure you import your AppTheme class

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plumber Project',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
