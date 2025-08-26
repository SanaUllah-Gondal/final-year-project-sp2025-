// SkillLink Code File 1
import 'package:flutter/material.dart';

void main() {
  runApp(SkillLinkApp1());
}

class SkillLinkApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SkillLink File 1')),
        body: Center(child: Text('Hello from SkillLink!')),
      ),
    );
  }
}
