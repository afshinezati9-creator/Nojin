import 'package:flutter/material.dart';

import '../../../core/theme/nojin_tokens.dart';

class NojinSectionHeader extends StatelessWidget {
  const NojinSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: NojinSpacing.xs),
                Text(subtitle!, style: textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: NojinSpacing.md),
          action!,
        ],
      ],
    );
  }
}
