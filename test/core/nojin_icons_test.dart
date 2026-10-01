import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/core/icons/nojin_icons.dart';

void main() {
  group('NojinIconAssets', () {
    test('maps every icon name to an SVG asset', () {
      for (final name in NojinIconName.values) {
        expect(NojinIconAssets.path(name), startsWith('assets/icons/'));
        expect(NojinIconAssets.path(name), endsWith('.svg'));
      }
    });

    test('labels are Persian and stable', () {
      expect(NojinIconName.home.label, 'خانه');
      expect(NojinIconName.notes.label, 'یادداشت‌ها');
      expect(NojinIconName.finance.label, 'مالی');
      expect(NojinIconName.planning.label, 'برنامه‌ریزی');
      expect(NojinIconName.info.label, 'اطلاعات');
      expect(NojinIconName.search.label, 'جستجو');
    });
  });
}
