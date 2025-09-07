/// 1件の稼働記録を表すクラス
class Record {
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

  const Record({
    required this.date,
    required this.investment,
    required this.returnAmount,
    this.startTime,
    this.endTime,
    this.note,
  });

  /// 収支（回収額 − 投資額）
  int get profit => returnAmount - investment;

  /// 稼働時間
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }
}
