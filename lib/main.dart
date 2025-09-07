import 'package:flutter/material.dart';
import 'record.dart';
import 'machine_master.dart';
import 'machine_api_service.dart';
import 'tag_management.dart';
import 'count_master_management.dart';
import 'statistics.dart';
import 'hall.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PsLogApp());
}

class PsLogApp extends StatefulWidget {
  const PsLogApp({super.key});

  @override
  State<PsLogApp> createState() => _PsLogAppState();
}

class _PsLogAppState extends State<PsLogApp> {
  DisplayMode? _mode;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('display_mode');
    setState(() {
      _mode = index != null ? DisplayMode.values[index] : null;
    });
  }

  void _updateMode(DisplayMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'psLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _mode == null
          ? ModeSelectionPage(onSelected: (m) {
              _updateMode(m);
              SharedPreferences.getInstance()
                  .then((p) => p.setInt('display_mode', m.index));
            })
          : RecordListPage(
              mode: _mode!,
              onModeChanged: _updateMode,
            ),
    );
  }
}

class RecordListPage extends StatefulWidget {
  final DisplayMode mode;
  final ValueChanged<DisplayMode> onModeChanged;
  const RecordListPage({super.key, required this.mode, required this.onModeChanged});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  final List<Record> _records = [];
  final List<String> _halls = [];
  final List<String> _tags = [];
  final List<String> _countMaster = [];
  DateTime _selectedDate = DateTime.now();

  static const String _placesApiKey =
      String.fromEnvironment('PLACES_API_KEY', defaultValue: 'YOUR_API_KEY');

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _manageTags() async {
    final updated = await Navigator.push<List<String>>(context,
        MaterialPageRoute(builder: (_) => TagManagementPage(tags: _tags)));
    if (updated != null) {
      setState(() {
        _tags
          ..clear()
          ..addAll(updated);
      });
    }
  }

  Future<void> _manageMachines() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MachineMasterPage()),
    );
    setState(() {});
  }

  Future<void> _manageCountMaster() async {
    final updated = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => CountMasterPage(counts: _countMaster),
      ),
    );
    if (updated != null) {
      setState(() {
        _countMaster
          ..clear()
          ..addAll(updated);
      });
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          mode: widget.mode,
          onModeChanged: (m) {
            widget.onModeChanged(m);
            setState(() {});
          },
          records: _records,
          onRecordsRestored: (restored) {
            setState(() {
              _records
                ..clear()
                ..addAll(restored);
            });
          },
        ),
      ),
    );
    setState(() {});
  }

  void _addRecord() {
    final formKey = GlobalKey<FormState>();

    // Controllers
    late TextEditingController hallController;
    late TextEditingController machineController;
    final investmentController = TextEditingController();
    final returnController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final noteController = TextEditingController();
    final tagInputController = TextEditingController();
    final List<String> selectedTags = [];
    final List<CountEntry> countEntries = [];
    // 機種名の候補
    List<String> machineSuggestions = [];

    void _addCountEntryDialog(
        List<CountEntry> list, void Function(void Function()) setStateDialog) {
      final nameController = TextEditingController();
      final countController = TextEditingController();
      bool addToMaster = false;
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateInner) {
              return AlertDialog(
                title: const Text('カウント追加'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue tev) {
                        final q = tev.text.trim().toLowerCase();
                        return _countMaster
                            .where((c) => c.toLowerCase().contains(q));
                      },
                      onSelected: (c) => nameController.text = c,
                      fieldViewBuilder:
                          (context, textController, focusNode, _) {
                        return TextField(
                          controller: textController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: '項目',
                            suffixIcon: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (value) {
                                textController.text = value;
                              },
                              itemBuilder: (context) => _countMaster
                                  .map((e) => PopupMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    TextField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '回数'),
                    ),
                    CheckboxListTile(
                      value: addToMaster,
                      title: const Text('マスタに追加'),
                      onChanged: (v) =>
                          setStateInner(() => addToMaster = v ?? false),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final cnt = int.tryParse(countController.text) ?? 0;
                      if (name.isNotEmpty) {
                        setStateDialog(() {
                          list.add(CountEntry(name: name, count: cnt));
                          if (addToMaster && !_countMaster.contains(name)) {
                            _countMaster.add(name);
                          }
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('追加'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        void addTag(String t) {
          final tag = t.trim();
          if (tag.isEmpty) return;
          if (!selectedTags.contains(tag)) {
            selectedTags.add(tag);
          }
          if (!_tags.contains(tag)) {
            _tags.add(tag);
          }
          tagInputController.clear();
        }

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('記録を追加'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ホールオートコンプリート（ユーザー登録）
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue tev) {
                          final q = tev.text.trim().toLowerCase();
                          if (q.isEmpty) {
                            return _halls;
                          }
                          return _halls
                              .where((h) => h.toLowerCase().contains(q));
                        },
                        onSelected: (h) => hallController.text = h,
                        fieldViewBuilder:
                            (context, textController, focusNode, _) {
                          hallController = textController;
                          return TextFormField(
                            key: const Key('hallField'),
                            controller: textController,
                            focusNode: focusNode,
                            decoration:
                                const InputDecoration(labelText: 'ホール'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'ホールを入力してください'
                                    : null,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // 機種オートコンプリート（外部API利用）
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue tev) {
                          final q = tev.text.trim();
                          if (q.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return machineSuggestions;
                        },
                        onSelected: (m) => machineController.text = m,
                        fieldViewBuilder:
                            (context, textController, focusNode, _) {
                          machineController = textController;
                          void updateSuggestions() async {
                            final q = textController.text.trim();
                            if (q.length < 2) {
                              setStateDialog(() => machineSuggestions = []);
                              return;
                            }
                            final results =
                                await MachineApiService.fetchSuggestions(q);
                            setStateDialog(() => machineSuggestions = results);
                          }

                          textController.addListener(updateSuggestions);

                          return TextFormField(
                            key: const Key('machineField'),
                            controller: textController,
                            focusNode: focusNode,
                            decoration:
                                const InputDecoration(labelText: '機種'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? '機種を入力してください'
                                    : null,
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('タグ'),
                      ),
                      Wrap(
                        spacing: 4.0,
                        children: selectedTags
                            .map((t) => InputChip(
                                  label: Text(t),
                                  onDeleted: () => setStateDialog(
                                      () => selectedTags.remove(t)),
                                ))
                            .toList(),
                      ),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue tev) {
                          final q = tev.text.trim().toLowerCase();
                          return _tags
                              .where((t) => t.toLowerCase().contains(q));
                        },
                        onSelected: (t) => setStateDialog(() => addTag(t)),
                        fieldViewBuilder:
                            (context, textController, focusNode, _) {
                          tagInputController.text = textController.text;
                          return TextField(
                            controller: textController,
                            focusNode: focusNode,
                            decoration:
                                const InputDecoration(labelText: 'タグを追加'),
                            onSubmitted: (v) =>
                                setStateDialog(() => addTag(v)),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('カウント'),
                      ),
                      Column(
                        children: countEntries
                            .map(
                              (e) => ListTile(
                                title: Text(e.name),
                                trailing: Text(e.count.toString()),
                                leading: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => setStateDialog(
                                      () => countEntries.remove(e)),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _addCountEntryDialog(countEntries, setStateDialog),
                        icon: const Icon(Icons.add),
                        label: const Text('カウントを追加'),
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
                    final hallName = hallController.text.trim();
                    final machineInput = machineController.text.trim();

                    // 機種名の決定（マスタ検索→入力そのまま）
                    String machineName;
                    try {
                      machineName = machineMaster
                          .firstWhere((m) =>
                              m.name == machineInput ||
                              m.aliases.contains(machineInput))
                          .name;
                    } catch (_) {
                      machineName = machineInput;
                    }

                    setState(() {
                      if (!_halls.contains(hallName)) {
                        _halls.add(hallName);
                      }
                      _records.add(Record(
                        date: _selectedDate,
                        hall: hallName,
                        machine: machineName,
                        investment: investment,
                        returnAmount: returnAmount,
                        startTime: startTime,
                        endTime: endTime,
                        note: note.isEmpty ? null : note,
                        tags: List.from(selectedTags),
                        counts: List.from(countEntries),
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
      appBar: AppBar(
        title: const Text('記録一覧'),
        actions: [
          if (widget.mode == DisplayMode.detailed)
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsPage(
                    records: _records,
                    countMaster: _countMaster,
                  ),
                ),
              ),
            ),
          if (widget.mode == DisplayMode.detailed)
            IconButton(
              icon: const Icon(Icons.store),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HallSearchPage(apiKey: _placesApiKey),
                ),
              ),
            ),
          if (widget.mode == DisplayMode.detailed)
            IconButton(
              icon: const Icon(Icons.videogame_asset),
              onPressed: _manageMachines,
            ),
          if (widget.mode == DisplayMode.detailed)
            IconButton(
              icon: const Icon(Icons.label),
              onPressed: _manageTags,
            ),
          if (widget.mode == DisplayMode.detailed)
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              onPressed: _manageCountMaster,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          )
        ],
      ),
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
                            Text('ホール: ${record.hall}'),
                            Text(
                                '投資: ${record.investment}円, 回収: ${record.returnAmount}円'),
                            Text('収支: ${record.profit}円'),
                            if (record.startTime != null &&
                                record.endTime != null)
                              Text(
                                  '開始: ${_formatTime(record.startTime!)}, 終了: ${_formatTime(record.endTime!)}'),
                            if (record.note != null) Text('メモ: ${record.note}'),
                            if (record.tags.isNotEmpty)
                              Text('タグ: ${record.tags.join(', ')}'),
                            if (record.counts.isNotEmpty)
                              Text('カウント: ${record.counts.map((e) => '${e.name}:${e.count}').join(', ')}'),
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
