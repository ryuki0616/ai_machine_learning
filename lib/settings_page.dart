import 'package:flutter/material.dart';
import 'config_manager.dart';

class SettingsPage extends StatefulWidget {
  final String initialCity;
  const SettingsPage({Key? key, required this.initialCity}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _cityController;
  String _temperatureUnit = 'celsius';
  String _language = 'ja';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialCity);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ConfigManager.loadSettings();
      setState(() {
        _cityController.text = settings['city_name'] ?? 'Tokyo';
        _temperatureUnit = settings['temperature_unit'] ?? 'celsius';
        _language = settings['language'] ?? 'ja';
        _isLoading = false;
      });
    } catch (e) {
      print('設定読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'city_name': _cityController.text,
        'temperature_unit': _temperatureUnit,
        'language': _language,
      };
      
      await ConfigManager.saveSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定をJSONファイルに保存しました')),
        );
        Navigator.pop(context, _cityController.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定の保存に失敗しました: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        actions: [
          IconButton(
            onPressed: () async {
              await ConfigManager.resetSettings();
              await _loadSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('設定をリセットしました')),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: '設定をリセット',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基本設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: '都市名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              '表示設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _temperatureUnit,
              decoration: const InputDecoration(
                labelText: '温度単位',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'celsius', child: Text('摂氏 (°C)')),
                DropdownMenuItem(value: 'fahrenheit', child: Text('華氏 (°F)')),
              ],
              onChanged: (value) {
                setState(() {
                  _temperatureUnit = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(
                labelText: '言語',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ja', child: Text('日本語')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('JSONファイルに保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 