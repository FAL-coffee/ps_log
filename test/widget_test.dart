import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ps_log/main.dart';

void main() {
  testWidgets('記録を追加すると一覧に表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const PsLogApp());

    expect(find.byType(ListTile), findsNothing);
    expect(find.textContaining('Total Profit: \$0'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('investmentField')), '1000');
    await tester.enterText(find.byKey(const Key('returnField')), '1500');
    await tester.enterText(find.byKey(const Key('noteField')), '良い日');

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.textContaining('投資: 1000円'), findsOneWidget);
    expect(find.textContaining('収支: 500円'), findsOneWidget);
    expect(find.textContaining('メモ: 良い日'), findsOneWidget);
  });
}
