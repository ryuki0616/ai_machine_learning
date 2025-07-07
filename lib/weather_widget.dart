import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final String city;
  const WeatherWidget({super.key, required this.city});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
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
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (widget.city.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final weatherData = await WeatherService.getWeatherData(widget.city);
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 検索バー削除
          const SizedBox(height: 20),
          // ローディング表示
          if (_isLoading)
            const CircularProgressIndicator(color: Colors.white)
          else if (_error.isNotEmpty)
            // エラー表示
            Container(
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
            )
          else if (_weatherData != null)
            // 天気情報表示
            Column(
              children: [
                // 都市名
                Text(
                  _weatherData!['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_weatherData!['sys']['country']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 天気アイコンと気温
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      WeatherService.getWeatherIcon(_weatherData!['weather'][0]['icon']),
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData!['main']['temp'].round()}°C',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _weatherData!['weather'][0]['description'],
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
                
                // 体感温度
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '体感温度: ${_weatherData!['main']['feels_like'].round()}°C',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 詳細情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem(
                      '湿度',
                      '${_weatherData!['main']['humidity']}%',
                      Icons.water_drop,
                    ),
                    _buildDetailItem(
                      '風速',
                      '${(_weatherData!['wind']['speed'] * 3.6).round()} km/h',
                      Icons.air,
                    ),
                    _buildDetailItem(
                      '気圧',
                      '${_weatherData!['main']['pressure']} hPa',
                      Icons.compress,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 追加情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem(
                      '視界',
                      '${(_weatherData!['visibility'] / 1000).round()} km',
                      Icons.visibility,
                    ),
                    _buildDetailItem(
                      '最高気温',
                      '${_weatherData!['main']['temp_max'].round()}°C',
                      Icons.thermostat,
                    ),
                    _buildDetailItem(
                      '最低気温',
                      '${_weatherData!['main']['temp_min'].round()}°C',
                      Icons.thermostat_outlined,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
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