/// 1件の稼働記録を表すクラス
/// カウントログ1件を表すクラス
class CountEntry {
  /// 項目名
  final String name;

  /// 回数
  final int count;

  const CountEntry({required this.name, required this.count});
}

class Record {
  /// 選択したホール名
  final String hall;

  /// 選択した機種名
  final String machine;

  /// 日付
  final DateTime date;

  /// 投資額（円）
  final int investment;

  /// 回収額（円）
  final int returnAmount;

  /// 開始時刻
  final DateTime? startTime;

  /// 終了時刻
  final DateTime? endTime;

  /// メモ
  final String? note;

  /// タグ一覧
  final List<String> tags;

  /// カウントログ一覧
  final List<CountEntry> counts;

  const Record({
    required this.date,
    required this.hall,
    required this.machine,
    required this.investment,
    required this.returnAmount,
    this.startTime,
    this.endTime,
    this.note,
    this.tags = const [],
    this.counts = const [],
  });

  /// 収支（回収額 − 投資額）
  int get profit => returnAmount - investment;

  /// 稼働時間
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }
}
