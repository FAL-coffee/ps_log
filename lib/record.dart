class Record {
  final int investment;
  final int returnAmount;
  final String? note;

  const Record({
    required this.investment,
    required this.returnAmount,
    this.note,
  });

  int get profit => returnAmount - investment;
}
