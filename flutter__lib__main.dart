import 'package:flutter/material.dart';
import 'screens/home.dart';
void main() => runApp(const SkillLinkApp());

class SkillLinkApp extends StatelessWidget {
  const SkillLinkApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillLink',
      home: const HomeScreen(),
    );
  }
}
