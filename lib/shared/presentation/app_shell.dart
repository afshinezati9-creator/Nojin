import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/nojin_icon_button.dart';
import '../../core/icons/nojin_icons.dart';
import '../../core/theme/nojin_tokens.dart';

class NojinAppShell extends StatelessWidget {
  const NojinAppShell({super.key, required this.child});
  final Widget child;

  static const destinations = <({String label, String path, NojinIconName icon})>[
    (label: 'خانه', path: '/', icon: NojinIconName.home),
    (label: 'یادداشت‌ها', path: '/notes', icon: NojinIconName.notes),
    (label: 'مالی', path: '/finance', icon: NojinIconName.finance),
    (label: 'برنامه‌ریزی', path: '/planning', icon: NojinIconName.planning),
    (label: 'اطلاعات', path: '/info', icon: NojinIconName.info),
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
          NojinIconButton(icon: NojinIconName.search, onPressed: () {}, tooltip: 'جستجو'),
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
                  NavigationDestination(
                    icon: NojinIcon(destination.icon),
                    selectedIcon: NojinIcon(destination.icon, color: NojinColors.indigo),
                    label: destination.label,
                  ),
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
            child: NojinIcon(NojinIconName.sparkle, color: Colors.white),
          ),
        ),
      ),
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: NojinIcon(destination.icon),
            selectedIcon: NojinIcon(destination.icon, color: NojinColors.indigo),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
