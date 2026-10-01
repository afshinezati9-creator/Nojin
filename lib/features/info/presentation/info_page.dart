import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اطلاعات')),
      body: const Center(
        child: Text('مخزن اطلاعات در فازهای بعدی پیاده‌سازی می‌شود.'),
      ),
    );
  }
}
