import 'package:flutter/material.dart';
import 'weather_widget.dart';
import 'settings_page.dart';
import 'config_manager.dart';
import 'json_viewer_page.dart';

void main() {
  runApp(const MyApp());
}

Future<String> loadCityName() async {
  return await ConfigManager.getCity();
}

Future<void> saveCityName(String city) async {
  await ConfigManager.setCity(city);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天気アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.white,
          surface: Colors.black,
          background: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _city = 'Tokyo';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final city = await loadCityName();
    setState(() {
      _city = city;
      _loading = false;
    });
  }

  void _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(initialCity: _city),
      ),
    );
    if (result != null && result is String && result.isNotEmpty) {
      print('都市名を変更: $_city → $result');
      await saveCityName(result);
      setState(() {
        _city = result;
      });
      print('都市名更新完了: $_city');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'start',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JsonViewerPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.code,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'JSONファイルを表示',
          ),
          const SizedBox(width: 8), // 右端の余白
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: WeatherWidget(city: _city),
      ),
    );
  }
}
