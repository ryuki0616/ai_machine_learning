import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final String city;
  const WeatherWidget({super.key, required this.city});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? _weather;
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didUpdateWidget(covariant WeatherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      print('WeatherWidget: 都市名変更検出 ${oldWidget.city} → ${widget.city}');
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (widget.city.isEmpty) return;
    print('WeatherWidget: 天気データ取得開始 - ${widget.city}');
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final weather = await WeatherService.getWeather(widget.city);
      print('WeatherWidget: 天気データ取得成功 - ${weather['city']}');
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      print('WeatherWidget: 天気データ取得エラー - $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey[900]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error.isNotEmpty
              ? _buildError()
              : _weather != null
                  ? _buildWeather()
                  : const SizedBox(),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Text(
        _error,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWeather() {
    return Column(
      children: [
        // 都市名
        Text(
          _weather!['city'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        // メイン情報
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getWeatherIcon(_weather!['description']),
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weather!['temp']}°C',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _weather!['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // 詳細情報
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDetail('体感', '${_weather!['feels']}°C', Icons.thermostat),
            _buildDetail('湿度', '${_weather!['humidity']}%', Icons.water_drop),
            _buildDetail('風速', '${_weather!['wind']} km/h', Icons.air),
          ],
        ),
      ],
    );
  }

  /// 天気の説明に基づいてアイコンを取得
  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    print('天気の説明: $desc'); // デバッグ用
    
    if (desc.contains('晴')) {
      return Icons.wb_sunny;
    } else if (desc.contains('曇') || desc.contains('雲') || desc.contains('厚い雲')) {
      return Icons.cloud;
    } else if (desc.contains('雨')) {
      return Icons.umbrella;
    } else if (desc.contains('雪')) {
      return Icons.ac_unit;
    } else if (desc.contains('霧') || desc.contains('もや')) {
      return Icons.cloud;
    } else if (desc.contains('雷')) {
      return Icons.flash_on;
    } else {
      return Icons.wb_sunny; // デフォルト
    }
  }

  Widget _buildDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
} 