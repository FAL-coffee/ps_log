class Record {
  final DateTime date;
  final int investment;
  final int returnAmount;
  final String? note;

  const Record({
    required this.date,
    required this.investment,
    required this.returnAmount,
    this.note,
  });

  int get profit => returnAmount - investment;
}
