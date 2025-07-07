import 'package:flutter/material.dart';
import 'weather_widget.dart';
import 'settings_page.dart';
import 'config_manager.dart';
import 'json_viewer_page.dart';
import 'news_widget.dart';
import 'news_service.dart';

void main() {
  NewsService.initialize();
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
  String _newsCategory1 = 'テクノロジー';
  String _newsCategory2 = 'ビジネス';
  String _newsCategory3 = 'エンターテイメント';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final settings = await ConfigManager.load();
    setState(() {
      _city = settings['city'] ?? 'Tokyo';
      _newsCategory1 = settings['news_category1'] ?? 'テクノロジー';
      _newsCategory2 = settings['news_category2'] ?? 'ビジネス';
      _newsCategory3 = settings['news_category3'] ?? 'エンターテイメント';
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
      print('設定を更新');
      await _loadCity(); // 設定を再読み込み
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            WeatherWidget(city: _city),
            const SizedBox(height: 20),
            NewsWidget(category: _newsCategory1),
            NewsWidget(category: _newsCategory2),
            NewsWidget(category: _newsCategory3),
          ],
        ),
      ),
    );
  }
}
