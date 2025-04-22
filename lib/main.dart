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


// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/splash.dart';
// import 'package:plumber_project/pages/theme.dart'; // Make sure you import your AppTheme class

// void main() async{
//    WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   static _MyAppState? of(BuildContext context) =>
//       context.findAncestorStateOfType<_MyAppState>();

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _isDarkTheme = false;

//   void toggleTheme(bool isDark) {
//     setState(() {
//       _isDarkTheme = isDark;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Plumber Project',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
//       home: SplashScreen(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumber_project/pages/splash.dart';
import 'package:plumber_project/pages/dashboard.dart'; // Your HomeScreen
import 'package:plumber_project/pages/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool rememberMe = prefs.getBool('remember_me') ?? false;
  String? token = prefs.getString('token');

  // 👇 Check for saved token and remember flag
  Widget initialScreen;
  if (rememberMe && token != null && token.isNotEmpty) {
    initialScreen = HomeScreen(); // ✅ Skip login
  } else {
    initialScreen = SplashScreen(); // Or LoginScreen if you prefer
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatefulWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

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
      home: widget.initialScreen,
    );
  }
}
