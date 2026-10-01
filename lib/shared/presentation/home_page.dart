import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/nojin_icons.dart';
import '../../core/theme/nojin_tokens.dart';
import 'widgets/nojin_components.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (title: 'یادداشت‌ها', path: '/notes', icon: NojinIconName.notes),
      (title: 'مالی', path: '/finance', icon: NojinIconName.finance),
      (title: 'برنامه‌ریزی', path: '/planning', icon: NojinIconName.planning),
      (title: 'اطلاعات', path: '/info', icon: NojinIconName.info),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 560 ? 2 : 1;

        return ListView(
          padding: const EdgeInsets.all(NojinSpacing.xxl),
          children: [
            Text('دستیار هوشمند زندگی', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: NojinSpacing.sm),
            Text('زندگی نو، تولد دوباره', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: NojinSpacing.xxl),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: NojinSpacing.lg,
                mainAxisSpacing: NojinSpacing.lg,
                childAspectRatio: columns == 1 ? 2.2 : 1.35,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return NojinSurface(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(NojinRadii.md),
                    onTap: () => context.go(item.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: NojinGradients.primary,
                            borderRadius: BorderRadius.circular(NojinRadii.md),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(NojinSpacing.md),
                            child: NojinIcon(item.icon, color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(height: NojinSpacing.md),
                        Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
