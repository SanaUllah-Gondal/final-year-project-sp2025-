import 'package:flutter/material.dart';
import '../services/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List workers = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      workers = await Api.fetchWorkers();
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SkillLink')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: workers.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(workers[i]['name'] ?? 'Worker'),
                subtitle: Text('Skill: ${workers[i]['skill'] ?? 'N/A'}'),
              ),
            ),
    );
  }
}
