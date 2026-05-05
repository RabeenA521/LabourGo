import 'package:flutter/material.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(child: ListTile(title: Text('Rating: 4.5'))),
            Card(child: ListTile(title: Text('Jobs Completed: 10'))),
            Card(child: ListTile(title: Text('Reviews: Coming Soon'))),
          ],
        ),
      ),
    );
  }
}
