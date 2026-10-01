import 'package:flutter/material.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مالی')),
      body: const Center(
        child: Text('هسته مالی در فازهای بعدی پیاده‌سازی می‌شود.'),
      ),
    );
  }
}
