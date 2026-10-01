import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('یادداشت‌ها')),
      body: const Center(
        child: Text('هسته یادداشت‌ها در فازهای بعدی پیاده‌سازی می‌شود.'),
      ),
    );
  }
}
