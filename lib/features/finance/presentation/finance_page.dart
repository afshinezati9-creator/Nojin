import 'package:flutter/material.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('مالی')),
      body: Center(child: Text('هسته مالی در فازهای بعدی پیاده‌سازی می‌شود.')),
    );
  }
}
