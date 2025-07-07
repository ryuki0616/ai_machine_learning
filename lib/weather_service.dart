import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '0d03bf8435dceed4d7f2a7aa3ed5cd6b'; // OpenWeatherMap APIキーを設定
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> getWeatherData(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=ja'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('天気情報の取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ネットワークエラー: $e');
    }
  }

  static String getWeatherIcon(String weatherId) {
    // OpenWeatherMapの天気IDに基づくアイコン
    switch (weatherId) {
      case '01d': // 晴れ（昼）
        return '☀️';
      case '01n': // 晴れ（夜）
        return '🌙';
      case '02d': // 部分的に曇り（昼）
        return '⛅';
      case '02n': // 部分的に曇り（夜）
        return '☁️';
      case '03d': // 曇り
      case '03n':
        return '☁️';
      case '04d': // 曇り
      case '04n':
        return '☁️';
      case '09d': // 小雨
      case '09n':
        return '🌦️';
      case '10d': // 雨（昼）
        return '🌧️';
      case '10n': // 雨（夜）
        return '🌧️';
      case '11d': // 雷雨（昼）
      case '11n': // 雷雨（夜）
        return '⛈️';
      case '13d': // 雪（昼）
      case '13n': // 雪（夜）
        return '❄️';
      case '50d': // 霧（昼）
      case '50n': // 霧（夜）
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  static Future<List<Map<String, dynamic>>> getTodayForecast(String city) async {
    final apiKey = 'YOUR_API_KEY';
    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=ja';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final now = DateTime.now();
      // 今日の日付だけ抽出
      final todayList = (data['list'] as List)
        .where((item) => DateTime.parse(item['dt_txt']).day == now.day)
        .toList();
      return todayList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('天気予報の取得に失敗しました');
    }
  }
} 