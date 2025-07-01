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

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:plumber_project/pages/splash.dart';
// import 'package:plumber_project/pages/dashboard.dart'; // Your HomeScreen
// import 'package:plumber_project/pages/theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   bool rememberMe = prefs.getBool('remember_me') ?? false;
//   String? token = prefs.getString('token');

//   // 👇 Check for saved token and remember flag
//   Widget initialScreen;
//   if (rememberMe && token != null && token.isNotEmpty) {
//     initialScreen = HomeScreen(); // ✅ Skip login
//   } else {
//     initialScreen = SplashScreen(); // Or LoginScreen if you prefer
//   }

//   runApp(MyApp(initialScreen: initialScreen));
// }

// class MyApp extends StatefulWidget {
//   final Widget initialScreen;
//   const MyApp({super.key, required this.initialScreen});

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
//       home: widget.initialScreen,
//     );
//   }
// }

//00000000000000000000000000000000000000000000000000000000000000000000000000000000 this code run sucessfully
import 'package:flutter/material.dart';
import 'package:plumber_project/pages/emergency.dart';
import 'package:plumber_project/pages/maps_screen.dart';
import 'package:plumber_project/pages/userservice/plumberservice.dart';
import 'package:plumber_project/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:plumber_project/pages/splash.dart';
import 'package:plumber_project/pages/theme.dart';
import 'package:plumber_project/pages/login.dart';
import 'package:plumber_project/pages/plumber_dashboard.dart' as dash;
import 'package:plumber_project/pages/electrition_dashboard.dart';
import 'package:plumber_project/pages/dashboard.dart';
import 'package:plumber_project/pages/plumber_profile.dart' as profile;
import 'package:plumber_project/pages/electrition_profile.dart';
import 'package:plumber_project/pages/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool rememberMe = prefs.getBool('remember_me') ?? false;
  String? token = prefs.getString('token');
  String? role = prefs.getString('role');
  int? userId = prefs.getInt('user_id');

  Widget initialScreen = LoginScreen();

  if (rememberMe && token != null && role != null && userId != null) {
    bool hasProfile = await checkUserProfile(userId, token);
    if (role == 'plumber') {
      initialScreen =
          hasProfile ? dash.PlumberDashboard() : profile.PlumberProfilePage();
    } else if (role == 'electrician') {
      initialScreen =
          hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
    } else {
      initialScreen = hasProfile ? HomeScreen() : UserProfilePage();
    }
  } else {
    initialScreen = SplashScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

Future<bool> checkUserProfile(int userId, String token) async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/check-profile/$userId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['profile_exists'] == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
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
      title: 'Skill-Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      // home: PlumberPage(),
      home: widget.initialScreen,
      // home: MapsScreen(),
    );
  }
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:plumber_project/pages/common/globs.dart';
// import 'package:plumber_project/pages/common/my_http_override.dart';
// import 'package:plumber_project/pages/common/service_call.dart';
// import 'package:plumber_project/pages/common/socket_manager.dart';
// import 'package:plumber_project/pages/emergency.dart';
// import 'package:plumber_project/pages/maps_screen.dart';
// import 'package:plumber_project/pages/userservice/plumberservice.dart';
// import 'package:plumber_project/test.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// import 'package:plumber_project/pages/splash.dart';
// import 'package:plumber_project/pages/theme.dart';
// import 'package:plumber_project/pages/login.dart';
// import 'package:plumber_project/pages/plumber_dashboard.dart';
// import 'package:plumber_project/pages/electrition_dashboard.dart';
// import 'package:plumber_project/pages/dashboard.dart';
// import 'package:plumber_project/pages/plumber_profile.dart';
// import 'package:plumber_project/pages/electrition_profile.dart';
// import 'package:plumber_project/pages/user_profile.dart';
// import 'package:uuid/uuid.dart';

// late SharedPreferences prefs;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Set up HTTP override for bad certificates (dev/testing only)
//   HttpOverrides.global = MyHttpOverrides();

//   prefs = await SharedPreferences.getInstance();
//   ServiceCall.userUUID = Globs.udValueString("uuid");

//   if (ServiceCall.userUUID == "") {
//     ServiceCall.userUUID = const Uuid().v6();
//     Globs.udStringSet(ServiceCall.userUUID, "uuid");
//   }

//   bool rememberMe = prefs.getBool('remember_me') ?? false;
//   String? token = prefs.getString('token');
//   String? role = prefs.getString('role');
//   int? userId = prefs.getInt('user_id');

//   Widget initialScreen = LoginScreen();

//   if (rememberMe && token != null && role != null && userId != null) {
//     bool hasProfile = await checkUserProfile(userId, token);
//     if (role == 'plumber') {
//       initialScreen = hasProfile ? PlumberDashboard() : PlumberProfilePage();
//     } else if (role == 'electrician') {
//       initialScreen =
//           hasProfile ? ElectricianDashboard() : ElectricianProfilePage();
//     } else {
//       initialScreen = hasProfile ? HomeScreen() : UserProfilePage();
//     }
//   } else {
//     initialScreen = SplashScreen();
//   }

//   SocketManager.shared.initSocket();

//   runApp(MyApp(initialScreen: initialScreen));
// }

// Future<bool> checkUserProfile(int userId, String token) async {
//   try {
//     final response = await http.get(
//       Uri.parse('http://10.0.2.2:8000/api/check-profile/$userId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['profile_exists'] == true;
//     } else {
//       return false;
//     }
//   } catch (e) {
//     return false;
//   }
// }

// class MyApp extends StatefulWidget {
//   final Widget initialScreen;
//   const MyApp({super.key, required this.initialScreen});

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
//       home: widget.initialScreen, // <- Restore this to show correct screen
//       // home: MapsScreen(),
//     );
//   }
// }
