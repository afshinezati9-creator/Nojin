import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/nojin_tokens.dart';

class NojinAppShell extends StatelessWidget {
  const NojinAppShell({super.key, required this.child});
  final Widget child;

  static const destinations = <({String label, String path, IconData icon})>[
    (label: 'خانه', path: '/', icon: Icons.home_rounded),
    (label: 'یادداشت‌ها', path: '/notes', icon: Icons.notes_rounded),
    (label: 'مالی', path: '/finance', icon: Icons.account_balance_wallet_rounded),
    (label: 'برنامه‌ریزی', path: '/planning', icon: Icons.event_note_rounded),
    (label: 'اطلاعات', path: '/info', icon: Icons.inventory_2_rounded),
  ];

  int _index(String location) {
    final index = destinations.indexWhere((item) => item.path != '/' && location.startsWith(item.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _index(GoRouterState.of(context).uri.path);
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      appBar: AppBar(
        title: const Text('نوژین'),
        actions: [
          IconButton(tooltip: 'جستجو', onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          const SizedBox(width: NojinSpacing.sm),
        ],
      ),
      body: Row(
        children: [
          if (wide) _buildRail(context, selected),
          Expanded(child: SafeArea(top: false, child: child)),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) => context.go(destinations[index].path),
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(icon: Icon(destination.icon), label: destination.label),
              ],
            ),
    );
  }

  Widget _buildRail(BuildContext context, int selected) {
    return NavigationRail(
      selectedIndex: selected,
      onDestinationSelected: (index) => context.go(destinations[index].path),
      labelType: NavigationRailLabelType.all,
      groupAlignment: -0.85,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: NojinSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: NojinGradients.primary,
            borderRadius: BorderRadius.circular(NojinRadii.md),
          ),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
        ),
      ),
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.icon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
