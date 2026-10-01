import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NojinIconName { home, notes, finance, planning, info, search, sparkle }

abstract final class NojinIconAssets {
  static const _root = 'assets/icons';

  static String path(NojinIconName name) => switch (name) {
        NojinIconName.home => '$_root/home.svg',
        NojinIconName.notes => '$_root/notes.svg',
        NojinIconName.finance => '$_root/finance.svg',
        NojinIconName.planning => '$_root/planning.svg',
        NojinIconName.info => '$_root/info.svg',
        NojinIconName.search => '$_root/search.svg',
        NojinIconName.sparkle => '$_root/sparkle.svg',
      };
}

class NojinIcon extends StatelessWidget {
  const NojinIcon(this.name, {super.key, this.size = 24, this.color, this.semanticLabel});

  final NojinIconName name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      NojinIconAssets.path(name),
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );
  }
}

extension NojinIconNameX on NojinIconName {
  String get label => switch (this) {
        NojinIconName.home => 'خانه',
        NojinIconName.notes => 'یادداشت‌ها',
        NojinIconName.finance => 'مالی',
        NojinIconName.planning => 'برنامه‌ریزی',
        NojinIconName.info => 'اطلاعات',
        NojinIconName.search => 'جستجو',
        NojinIconName.sparkle => 'نوژین',
      };
}
