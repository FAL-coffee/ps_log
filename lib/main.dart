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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('investmentField'),
                controller: investmentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Investment'),
              ),
              TextField(
                key: const Key('returnField'),
                controller: returnController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Return'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final investment = int.tryParse(investmentController.text) ?? 0;
                final returnAmount = int.tryParse(returnController.text) ?? 0;
                setState(() {
                  _records.add(Record(
                    date: _selectedDate,
                    investment: investment,
                    returnAmount: returnAmount,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
      appBar: AppBar(title: const Text('Records')),
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
                ? const Center(child: Text('No records for selected day'))
                : ListView.builder(
                    itemCount: dayRecords.length,
                    itemBuilder: (context, index) {
                      final record = dayRecords[index];
                      return ListTile(
                        title: Text(
                            'Investment: \$${record.investment}, Return: \$${record.returnAmount}'),
                        subtitle: Text('Profit: \$${record.profit}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        tooltip: 'Add Record',
        child: const Icon(Icons.add),
      ),
    );
  }
}
