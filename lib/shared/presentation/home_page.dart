import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/nojin_icons.dart';
import '../../core/layout/nojin_breakpoints.dart';
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
        final width = constraints.maxWidth;
        final columns = NojinBreakpoints.gridColumns(width);
        final maxWidth = NojinBreakpoints.contentMaxWidth(width);
        final pagePadding = NojinBreakpoints.pagePadding(width);

        return ListView(
          padding: pagePadding,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دستیار هوشمند زندگی',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: NojinSpacing.sm),
                    Text(
                      'زندگی نو، تولد دوباره',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: NojinSpacing.xxl),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: NojinSpacing.lg,
                        mainAxisSpacing: NojinSpacing.lg,
                        childAspectRatio: columns == 1
                            ? 2.0
                            : columns == 2
                                ? 1.45
                                : 1.25,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return NojinSurface(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(NojinRadii.md),
                            onTap: () => context.go(item.path),
                            child: Padding(
                              padding: const EdgeInsets.all(NojinSpacing.lg),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: NojinGradients.primary,
                                      borderRadius: BorderRadius.circular(NojinRadii.md),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(NojinSpacing.md),
                                      child: NojinIcon(
                                        item.icon,
                                        color: Colors.white,
                                        size: width < 600 ? 26 : 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: NojinSpacing.md),
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
