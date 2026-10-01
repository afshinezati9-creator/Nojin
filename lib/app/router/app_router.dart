import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/app_error_page.dart';
import '../../features/finance/presentation/finance_page.dart';
import '../../features/info/presentation/info_page.dart';
import '../../features/notes/presentation/notes_page.dart';
import '../../features/planning/presentation/planning_page.dart';
import '../../shared/presentation/app_shell.dart';
import '../../shared/presentation/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => AppErrorPage(error: state.error),
    routes: [
      ShellRoute(
        builder: (context, state, child) => NojinAppShell(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: (context, state) => const HomePage()),
          GoRoute(path: '/notes', name: 'notes', builder: (context, state) => const NotesPage()),
          GoRoute(path: '/finance', name: 'finance', builder: (context, state) => const FinancePage()),
          GoRoute(path: '/planning', name: 'planning', builder: (context, state) => const PlanningPage()),
          GoRoute(path: '/info', name: 'info', builder: (context, state) => const InfoPage()),
        ],
      ),
    ],
  );
});
