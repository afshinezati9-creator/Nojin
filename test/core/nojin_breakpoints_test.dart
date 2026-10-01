import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/core/layout/nojin_breakpoints.dart';

void main() {
  test('classifies compact, medium and expanded widths', () {
    expect(NojinBreakpoints.isCompact(599), isTrue);
    expect(NojinBreakpoints.isMedium(600), isTrue);
    expect(NojinBreakpoints.isMedium(839), isTrue);
    expect(NojinBreakpoints.isExpanded(840), isTrue);
    expect(NojinBreakpoints.isWide(1200), isTrue);
  });

  test('grid scales from one to four columns', () {
    expect(NojinBreakpoints.gridColumns(390), 1);
    expect(NojinBreakpoints.gridColumns(700), 2);
    expect(NojinBreakpoints.gridColumns(1000), 3);
    expect(NojinBreakpoints.gridColumns(1400), 4);
  });

  test('wide content remains bounded', () {
    expect(NojinBreakpoints.contentMaxWidth(1400), 1180);
    expect(NojinBreakpoints.contentMaxWidth(1000), 1040);
    expect(NojinBreakpoints.contentMaxWidth(700), double.infinity);
  });
}
