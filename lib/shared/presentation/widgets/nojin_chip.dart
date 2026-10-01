import 'package:flutter/material.dart';

import '../../../core/theme/nojin_tokens.dart';

class NojinChip extends StatelessWidget {
  const NojinChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onSelected,
  });

  final String label;
  final Widget? icon;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(NojinRadii.pill),
        onTap: onSelected,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: NojinSpacing.md,
            vertical: NojinSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: selected ? NojinGradients.primary : null,
            color: selected ? null : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(NojinRadii.pill),
            border: selected
                ? null
                : Border.all(
                    color: dark ? NojinColors.darkBorder : NojinColors.border,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: NojinSpacing.xs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? Colors.white : NojinColors.text2,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
