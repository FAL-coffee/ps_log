import 'package:flutter/material.dart';
import 'record.dart';
import 'machine_master.dart';

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
    final formKey = GlobalKey<FormState>();

    // Controllers
    late TextEditingController machineController;
    final investmentController = TextEditingController();
    final returnController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final noteController = TextEditingController();

    // Autocomplete selection
    Machine? selectedMachine;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('記録を追加'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 機種オートコンプリート（alias対応）
                  Autocomplete<Machine>(
                    optionsBuilder: (TextEditingValue tev) {
                      final q = tev.text.trim().toLowerCase();
                      if (q.isEmpty) return const Iterable<Machine>.empty();
                      return machineMaster.where((m) {
                        final nameMatch = m.name.toLowerCase().contains(q);
                        final aliasMatch = m.aliases
                            .any((a) => a.toLowerCase().contains(q));
                        return nameMatch || aliasMatch;
                      });
                    },
                    displayStringForOption: (m) => m.name,
                    onSelected: (m) => selectedMachine = m,
                    fieldViewBuilder: (context, textController, focusNode, _) {
                      machineController = textController;
                      return TextFormField(
                        key: const Key('machineField'),
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: '機種'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? '機種を入力してください' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('investmentField'),
                    controller: investmentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '投資額'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '投資額を入力してください';
                      }
                      if (int.tryParse(value) == null) {
                        return '数値を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('returnField'),
                    controller: returnController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '回収額'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '回収額を入力してください';
                      }
                      if (int.tryParse(value) == null) {
                        return '数値を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('startField'),
                    controller: startController,
                    keyboardType: TextInputType.datetime,
                    decoration:
                        const InputDecoration(labelText: '開始時間 (HH:mm)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('endField'),
                    controller: endController,
                    keyboardType: TextInputType.datetime,
                    decoration:
                        const InputDecoration(labelText: '終了時間 (HH:mm)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('noteField'),
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'メモ'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final investment = int.parse(investmentController.text);
                final returnAmount = int.parse(returnController.text);

                DateTime? startTime;
                DateTime? endTime;

                DateTime? _parseHM(String s) {
                  final parts = s.split(':');
                  if (parts.length != 2) return null;
                  final h = int.tryParse(parts[0]);
                  final m = int.tryParse(parts[1]);
                  if (h == null || m == null) return null;
                  return DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    h,
                    m,
                  );
                }

                if (startController.text.isNotEmpty) {
                  startTime = _parseHM(startController.text);
                }
                if (endController.text.isNotEmpty) {
                  endTime = _parseHM(endController.text);
                }

                final note = noteController.text.trim();
                final machineInput = machineController.text.trim();

                // 機種名の決定（選択優先→マスタ検索→入力そのまま）
                String machineName;
                if (selectedMachine != null &&
                    selectedMachine!.name == machineInput) {
                  machineName = selectedMachine!.name;
                } else {
                  try {
                    machineName = machineMaster
                        .firstWhere((m) =>
                            m.name == machineInput ||
                            m.aliases.contains(machineInput))
                        .name;
                  } catch (_) {
                    machineName = machineInput;
                  }
                }

                setState(() {
                  _records.add(Record(
                    date: _selectedDate,
                    machine: machineName,
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
    final totalInvestment =
        dayRecords.fold<int>(0, (sum, r) => sum + r.investment);
    final totalReturn =
        dayRecords.fold<int>(0, (sum, r) => sum + r.returnAmount);
    final totalProfit = totalReturn - totalInvestment;

    String _formatTime(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('記録一覧')),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() => _selectedDate = date);
            },
          ),
          Expanded(
            child: dayRecords.isEmpty
                ? const Center(child: Text('選択した日に記録はありません'))
                : ListView.builder(
                    itemCount: dayRecords.length,
                    itemBuilder: (context, index) {
                      final record = dayRecords[index];
                      return ListTile(
                        title: Text(record.machine),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '投資: ${record.investment}円, 回収: ${record.returnAmount}円'),
                            Text('収支: ${record.profit}円'),
                            if (record.startTime != null &&
                                record.endTime != null)
                              Text(
                                  '開始: ${_formatTime(record.startTime!)}, 終了: ${_formatTime(record.endTime!)}'),
                            if (record.note != null) Text('メモ: ${record.note}'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '総投資額: ${totalInvestment}円, 総回収額: ${totalReturn}円, 総収支: ${totalProfit}円',
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
