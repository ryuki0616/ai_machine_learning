import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ConfigManager {
  static const String _fileName = 'app_settings.json';
  
  // デフォルト設定をアセットから読み込む
  static Future<Map<String, dynamic>> _loadDefaultSettings() async {
    try {
      final jsonString = await rootBundle.loadString('assets/default_settings.json');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('デフォルト設定の読み込みエラー: $e');
      // フォールバック用のデフォルト設定
      return {
        'city_name': 'Tokyo',
        'temperature_unit': 'celsius',
        'language': 'ja',
        'theme': 'dark',
        'notifications_enabled': true,
        'update_interval': 30,
      };
    }
  }

  // 設定ファイルのパスを取得
  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  // 設定を読み込む
  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final settings = json.decode(jsonString) as Map<String, dynamic>;
        // デフォルト値とマージ
        final defaultSettings = await _loadDefaultSettings();
        return {...defaultSettings, ...settings};
      } else {
        // ファイルが存在しない場合はデフォルト設定を保存
        final defaultSettings = await _loadDefaultSettings();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }
    } catch (e) {
      print('設定読み込みエラー: $e');
      return await _loadDefaultSettings();
    }
  }

  // 設定を保存する
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      
      final jsonString = json.encode(settings);
      await file.writeAsString(jsonString);
      print('設定を保存しました: $filePath');
    } catch (e) {
      print('設定保存エラー: $e');
    }
  }

  // 特定の設定値を取得
  static Future<T> getValue<T>(String key, T defaultValue) async {
    final settings = await loadSettings();
    return settings[key] as T? ?? defaultValue;
  }

  // 特定の設定値を設定
  static Future<void> setValue<T>(String key, T value) async {
    final settings = await loadSettings();
    settings[key] = value;
    await saveSettings(settings);
  }

  // 都市名を取得
  static Future<String> getCityName() async {
    return await getValue<String>('city_name', 'Tokyo');
  }

  // 都市名を設定
  static Future<void> setCityName(String cityName) async {
    await setValue<String>('city_name', cityName);
  }

  // 設定ファイルの内容を表示用に取得
  static Future<String> getSettingsAsString() async {
    try {
      final settings = await loadSettings();
      return const JsonEncoder.withIndent('  ').convert(settings);
    } catch (e) {
      return 'エラー: $e';
    }
  }

  // 設定をリセット
  static Future<void> resetSettings() async {
    final defaultSettings = await _loadDefaultSettings();
    await saveSettings(defaultSettings);
  }
} 