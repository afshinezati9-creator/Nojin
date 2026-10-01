import 'package:flutter/material.dart';

import '../../../core/theme/nojin_tokens.dart';

class NojinSurface extends StatelessWidget {
  const NojinSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NojinSpacing.lg),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(NojinRadii.md),
        border: Border.all(
          color: dark ? NojinColors.darkBorder : NojinColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 2),
            color: Color(0x0F0F172A),
          ),
        ],
      ),
      child: child,
    );
  }
}

class NojinGradientSurface extends StatelessWidget {
  const NojinGradientSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NojinSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: dark ? NojinGradients.darkSoft : NojinGradients.soft,
        borderRadius: BorderRadius.circular(NojinRadii.lg),
      ),
      child: child,
    );
  }
}
