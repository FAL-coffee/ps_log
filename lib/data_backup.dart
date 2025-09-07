import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'record.dart';

/// データバックアップおよび復元を行うユーティリティ
class DataBackupService {
  static Future<File> _backupFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/pslog_backup.json');
  }

  /// 記録一覧をJSONとして保存する
  static Future<void> exportRecords(List<Record> records) async {
    final file = await _backupFile();
    final json = jsonEncode(records.map((e) => e.toJson()).toList());
    await file.writeAsString(json);
  }

  /// 保存されたJSONから記録一覧を復元する
  static Future<List<Record>> importRecords() async {
    final file = await _backupFile();
    if (!await file.exists()) return [];
    final jsonStr = await file.readAsString();
    final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;
    return data
        .map((e) => Record.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
