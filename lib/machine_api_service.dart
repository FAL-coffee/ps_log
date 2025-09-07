import 'dart:convert';
import 'package:http/http.dart' as http;

/// WikipediaのオープンサーチAPIを利用して機種名の候補を取得するサービス
class MachineApiService {
  static const _endpoint = 'https://ja.wikipedia.org/w/api.php';

  /// 指定したクエリにマッチする機種名候補を取得する
  static Future<List<String>> fetchSuggestions(String query) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'action': 'opensearch',
      'search': query,
      'limit': '10',
      'format': 'json',
    });
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;
        final titles = data[1] as List<dynamic>;
        return titles.cast<String>();
      }
    } catch (_) {
      // 通信エラーなどは空リストを返す
    }
    return [];
  }
}
