import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/nojin_theme.dart';
import 'router/app_router.dart';

class NojinApp extends ConsumerWidget {
  const NojinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'نوژین',
      debugShowCheckedModeBanner: false,
      theme: NojinTheme.light,
      darkTheme: NojinTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
