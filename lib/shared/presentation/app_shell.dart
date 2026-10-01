import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/nojin_icon_button.dart';
import '../../core/icons/nojin_icons.dart';
import '../../core/layout/nojin_breakpoints.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = NojinBreakpoints.isCompact(width);
        final selected = _index(GoRouterState.of(context).uri.path);

        return Scaffold(
          appBar: AppBar(
            title: const Text('نوژین'),
            actions: [
              NojinIconButton(
                icon: NojinIconName.search,
                onPressed: () {},
                tooltip: 'جستجو',
              ),
              const SizedBox(width: NojinSpacing.sm),
            ],
          ),
          body: Row(
            children: [
              if (!compact) _buildRail(context, selected),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: child,
                ),
              ),
            ],
          ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) => context.go(destinations[index].path),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: NojinIcon(destination.icon),
                        selectedIcon: NojinIcon(
                          destination.icon,
                          color: NojinColors.indigo,
                        ),
                        label: destination.label,
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildRail(BuildContext context, int selected) {
    final width = MediaQuery.sizeOf(context).width;
    final expanded = NojinBreakpoints.isWide(width);

    return NavigationRail(
      selectedIndex: selected,
      onDestinationSelected: (index) => context.go(destinations[index].path),
      extended: expanded,
      labelType: expanded ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      groupAlignment: -0.85,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: NojinSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: NojinGradients.primary,
            borderRadius: BorderRadius.circular(NojinRadii.md),
          ),
          child: SizedBox(
            width: expanded ? 176 : 44,
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NojinIcon(NojinIconName.sparkle, color: Colors.white),
                if (expanded) ...[
                  const SizedBox(width: NojinSpacing.sm),
                  Text(
                    'نوژین',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ],
            ),
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
