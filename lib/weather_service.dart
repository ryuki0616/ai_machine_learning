import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '0d03bf8435dceed4d7f2a7aa3ed5cd6b';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // コンパクトな天気データを取得
  static Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=ja'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 必要な情報のみを抽出
        return {
          'city': data['name'],
          'temp': data['main']['temp'].round(),
          'feels': data['main']['feels_like'].round(),
          'humidity': data['main']['humidity'],
          'wind': (data['wind']['speed'] * 3.6).round(),
          'description': data['weather'][0]['description'],
          'icon': _getIcon(data['weather'][0]['icon']),
        };
      } else {
        throw Exception('天気取得エラー: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ネットワークエラー: $e');
    }
  }

  // シンプルなアイコン取得
  static String _getIcon(String weatherId) {
    const icons = {
      '01': '☀️', '02': '⛅', '03': '☁️', '04': '☁️',
      '09': '🌦️', '10': '🌧️', '11': '⛈️', '13': '❄️', '50': '🌫️'
    };
    return icons[weatherId.substring(0, 2)] ?? '🌤️';
  }


} 