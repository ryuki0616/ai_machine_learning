import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ConfigManager {
  static const String _fileName = 'settings.json';
  
  // デフォルト設定
  static const Map<String, dynamic> _defaults = {
    'city': 'Tokyo',
    'unit': 'celsius',
    'lang': 'ja',
    'theme': 'dark',
    'news_category1': 'テクノロジー',
    'news_category2': 'ビジネス',
    'news_category3': 'エンターテイメント',
  };

  // 設定を読み込む
  static Future<Map<String, dynamic>> load() async {
    try {
      final file = File('${(await getApplicationDocumentsDirectory()).path}/$_fileName');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        return {..._defaults, ...data};
      } else {
        await save(_defaults);
        return _defaults;
      }
    } catch (e) {
      print('設定読み込みエラー: $e');
      return _defaults;
    }
  }

  // 設定を保存
  static Future<void> save(Map<String, dynamic> settings) async {
    try {
      final file = File('${(await getApplicationDocumentsDirectory()).path}/$_fileName');
      await file.writeAsString(json.encode(settings));
    } catch (e) {
      print('設定保存エラー: $e');
    }
  }

  // 値を取得
  static Future<T> get<T>(String key, T defaultValue) async {
    final settings = await load();
    return settings[key] as T? ?? defaultValue;
  }

  // 値を設定
  static Future<void> set<T>(String key, T value) async {
    final settings = await load();
    settings[key] = value;
    print('ConfigManager: 設定更新 - $key: $value');
    await save(settings);
  }

  // 都市名を取得
  static Future<String> getCity() async {
    return await get<String>('city', 'Tokyo');
  }

  // 都市名を設定
  static Future<void> setCity(String city) async {
    print('ConfigManager: 都市名設定 - $city');
    await set<String>('city', city);
  }

  // 設定をリセット
  static Future<void> reset() async {
    await save(_defaults);
  }

  // JSON文字列として取得
  static Future<String> asJson() async {
    try {
      final settings = await load();
      return const JsonEncoder.withIndent('  ').convert(settings);
    } catch (e) {
      return 'エラー: $e';
    }
  }
} 