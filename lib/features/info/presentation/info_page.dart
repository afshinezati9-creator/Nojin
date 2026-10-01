import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('اطلاعات')),
      body: Center(child: Text('مخزن اطلاعات در فازهای بعدی پیاده‌سازی می‌شود.')),
    );
  }
}
