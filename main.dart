void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('SkillLink Home')));
}