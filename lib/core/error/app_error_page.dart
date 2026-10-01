import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppErrorPage extends StatelessWidget {
  const AppErrorPage({required this.error, super.key});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              const Text(
                'صفحه موردنظر در دسترس نیست',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'خطای ناشناخته',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('بازگشت به خانه'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
