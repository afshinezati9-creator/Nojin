import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('یادداشت‌ها')),
      body: Center(child: Text('هسته یادداشت‌ها در فازهای بعدی پیاده‌سازی می‌شود.')),
    );
  }
}
