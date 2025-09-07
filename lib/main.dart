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
    return Scaffold(
      appBar: AppBar(title: const Text('Records')),
      body: _records.isEmpty
          ? const Center(child: Text('No records yet'))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return ListTile(
                  title: Text('Investment: \$${record.investment}, Return: \$${record.returnAmount}'),
                  subtitle: Text('Profit: \$${record.profit}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        tooltip: 'Add Record',
        child: const Icon(Icons.add),
      ),
    );
  }
}
