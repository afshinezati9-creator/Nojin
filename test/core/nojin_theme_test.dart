import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/core/theme/nojin_theme.dart';
import 'package:nojin/core/theme/nojin_tokens.dart';

void main() {
  test('golden reference color tokens are stable', () {
    expect(NojinColors.blue.value, 0xFF3B82F6);
    expect(NojinColors.indigo.value, 0xFF6366F1);
    expect(NojinColors.violet.value, 0xFF8B5CF6);
    expect(NojinColors.background.value, 0xFFF4F6FA);
    expect(NojinColors.darkBackground.value, 0xFF0A0F1C);
  });

  test('spacing and radii expose the shared design scale', () {
    expect(NojinSpacing.sm, 8);
    expect(NojinSpacing.lg, 16);
    expect(NojinRadii.md, 14);
    expect(NojinRadii.lg, 20);
  });

  testWidgets('light and dark themes build successfully', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: NojinTheme.light, home: const SizedBox.shrink()));
    expect(Theme.of(tester.element(find.byType(SizedBox))).brightness, Brightness.light);

    await tester.pumpWidget(MaterialApp(theme: NojinTheme.dark, home: const SizedBox.shrink()));
    expect(Theme.of(tester.element(find.byType(SizedBox))).brightness, Brightness.dark);
  });
}
