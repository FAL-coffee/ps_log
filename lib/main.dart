import 'package:flutter/material.dart';
import 'record.dart';

void main() {
  runApp(const PsLogApp());
}

class PsLogApp extends StatelessWidget {
  const PsLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'psLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RecordListPage(),
    );
  }
}

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  final List<Record> _records = [];
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _addRecord() {
    final investmentController = TextEditingController();
    final returnController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('記録を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('investmentField'),
                controller: investmentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '投資額'),
              ),
              TextField(
                key: const Key('returnField'),
                controller: returnController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '回収額'),
              ),
              TextField(
                key: const Key('startField'),
                controller: startController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(labelText: '開始時間 (HH:mm)'),
              ),
              TextField(
                key: const Key('endField'),
                controller: endController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(labelText: '終了時間 (HH:mm)'),
              ),
              TextField(
                key: const Key('noteField'),
                controller: noteController,
                decoration: const InputDecoration(labelText: 'メモ'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final investment = int.tryParse(investmentController.text) ?? 0;
                final returnAmount = int.tryParse(returnController.text) ?? 0;
                DateTime? startTime;
                DateTime? endTime;
                if (startController.text.isNotEmpty) {
                  final parts = startController.text.split(':');
                  if (parts.length == 2) {
                    final h = int.tryParse(parts[0]);
                    final m = int.tryParse(parts[1]);
                    if (h != null && m != null) {
                      startTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          h,
                          m);
                    }
                  }
                }
                if (endController.text.isNotEmpty) {
                  final parts = endController.text.split(':');
                  if (parts.length == 2) {
                    final h = int.tryParse(parts[0]);
                    final m = int.tryParse(parts[1]);
                    if (h != null && m != null) {
                      endTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          h,
                          m);
                    }
                  }
                }
                final note = noteController.text;
                setState(() {
                  _records.add(Record(
                    date: _selectedDate,
                    investment: investment,
                    returnAmount: returnAmount,
                    startTime: startTime,
                    endTime: endTime,
                    note: note.isEmpty ? null : note,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayRecords =
        _records.where((r) => _isSameDay(r.date, _selectedDate)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('記録一覧')),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          Expanded(
            child: dayRecords.isEmpty
                ? const Center(child: Text('選択した日に記録はありません'))
                : ListView.builder(
                    itemCount: dayRecords.length,
                    itemBuilder: (context, index) {
                      final record = dayRecords[index];
                      String _formatTime(DateTime t) =>
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        title: Text(
                            '投資: ${record.investment}円, 回収: ${record.returnAmount}円'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('収支: ${record.profit}円'),
                            if (record.startTime != null && record.endTime != null)
                              Text(
                                  '開始: ${_formatTime(record.startTime!)}, 終了: ${_formatTime(record.endTime!)}'),
                            if (record.note != null)
                              Text('メモ: ${record.note}')
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        tooltip: '記録を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
