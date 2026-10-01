import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/app/app.dart';

void main() {
  testWidgets('NOJÎN boots with the home shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NojinApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('نوژین'), findsOneWidget);
    expect(find.text('یادداشت‌ها'), findsOneWidget);
    expect(find.text('مالی'), findsOneWidget);
    expect(find.text('برنامه‌ریزی'), findsOneWidget);
    expect(find.text('اطلاعات'), findsOneWidget);
  });
}
