import 'package:flutter/material.dart';

import '../../../core/theme/nojin_tokens.dart';
import 'nojin_surface.dart';

class NojinStatCard extends StatelessWidget {
  const NojinStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent = NojinColors.indigo,
  });

  final String label;
  final String value;
  final Widget? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return NojinSurface(
      padding: const EdgeInsets.all(NojinSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: accent, size: 18),
                  child: icon!,
                ),
                const SizedBox(width: NojinSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: NojinSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
