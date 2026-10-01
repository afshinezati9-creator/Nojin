import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('یادداشت‌ها', '/notes', Icons.notes_rounded),
      ('مالی', '/finance', Icons.account_balance_wallet_rounded),
      ('برنامه‌ریزی', '/planning', Icons.event_note_rounded),
      ('اطلاعات', '/info', Icons.inventory_2_rounded),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('نوژین')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.go(item.$2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$3, size: 34),
                    const SizedBox(height: 12),
                    Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
