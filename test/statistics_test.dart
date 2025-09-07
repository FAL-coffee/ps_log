import 'package:flutter_test/flutter_test.dart';
import 'package:ps_log/record.dart';
import 'package:ps_log/statistics.dart';

void main() {
  test('タグ別収支集計', () {
    final records = [
      Record(
        hall: 'A',
        machine: 'M1',
        date: DateTime(2024),
        investment: 1000,
        returnAmount: 1500,
        tags: ['A', 'B'],
      ),
      Record(
        hall: 'B',
        machine: 'M2',
        date: DateTime(2024),
        investment: 500,
        returnAmount: 300,
        tags: ['A'],
      ),
    ];
    final result = aggregateProfitByTag(records);
    expect(result['A'], 300);
    expect(result['B'], 500);
  });

  test('カウント集計（マスタのみ）', () {
    final records = [
      Record(
        hall: 'A',
        machine: 'M1',
        date: DateTime(2024),
        investment: 0,
        returnAmount: 0,
        counts: [
          CountEntry(name: '回転', count: 100),
          CountEntry(name: '大当たり', count: 2),
        ],
      ),
      Record(
        hall: 'B',
        machine: 'M2',
        date: DateTime(2024),
        investment: 0,
        returnAmount: 0,
        counts: [
          CountEntry(name: '回転', count: 80),
          CountEntry(name: '即席', count: 5),
        ],
      ),
    ];
    final master = ['回転', '大当たり'];
    final result = aggregateCounts(records, master);
    expect(result['回転'], 180);
    expect(result['大当たり'], 2);
    expect(result.containsKey('即席'), false);
  });
}
