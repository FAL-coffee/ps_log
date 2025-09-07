import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ps_log/main.dart';

void main() {
  testWidgets('Adding a record displays it in the list', (WidgetTester tester) async {
    await tester.pumpWidget(const PsLogApp());

    expect(find.byType(ListTile), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('investmentField')), '1000');
    await tester.enterText(find.byKey(const Key('returnField')), '1500');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Investment: \$1000'), findsOneWidget);
    expect(find.textContaining('Profit: \$500'), findsOneWidget);
  });
}
