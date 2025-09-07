import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'record.dart';
import 'data_backup.dart';

enum DisplayMode { simple, detailed }

class SettingsPage extends StatelessWidget {
  final DisplayMode mode;
  final ValueChanged<DisplayMode> onModeChanged;
  final List<Record> records;
  final ValueChanged<List<Record>> onRecordsRestored;

  const SettingsPage({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.records,
    required this.onRecordsRestored,
  });

  Future<void> _changeMode(DisplayMode m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('display_mode', m.index);
    onModeChanged(m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const ListTile(title: Text('表示モード')),
          RadioListTile<DisplayMode>(
            title: const Text('シンプル'),
            value: DisplayMode.simple,
            groupValue: mode,
            onChanged: (m) {
              if (m != null) _changeMode(m);
            },
          ),
          RadioListTile<DisplayMode>(
            title: const Text('詳細'),
            value: DisplayMode.detailed,
            groupValue: mode,
            onChanged: (m) {
              if (m != null) _changeMode(m);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('データバックアップ'),
            trailing: ElevatedButton(
              onPressed: () async {
                await DataBackupService.exportRecords(records);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('バックアップを作成しました')),
                  );
                }
              },
              child: const Text('バックアップ'),
            ),
          ),
          ListTile(
            title: const Text('データ復元'),
            trailing: ElevatedButton(
              onPressed: () async {
                final restored = await DataBackupService.importRecords();
                onRecordsRestored(restored);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('データを復元しました')),
                  );
                }
              },
              child: const Text('復元'),
            ),
          ),
        ],
      ),
    );
  }
}

class ModeSelectionPage extends StatelessWidget {
  final ValueChanged<DisplayMode> onSelected;

  const ModeSelectionPage({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表示モード選択')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => onSelected(DisplayMode.simple),
              child: const Text('シンプルに始める'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onSelected(DisplayMode.detailed),
              child: const Text('細かく管理する'),
            ),
          ],
        ),
      ),
    );
  }
}
