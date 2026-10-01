import 'package:flutter/material.dart';

import 'nojin_icons.dart';

class NojinIconButton extends StatelessWidget {
  const NojinIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 24,
  });

  final NojinIconName icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip ?? icon.label,
      onPressed: onPressed,
      icon: NojinIcon(icon, size: size),
    );
  }
}
