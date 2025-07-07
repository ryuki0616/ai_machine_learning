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
  bool _loading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialCity);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ConfigManager.load();
      setState(() {
        _cityController.text = settings['city'] ?? 'Tokyo';
        _loading = false;
        _hasChanges = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'city': _cityController.text,
      };
      print('SettingsPage: 設定保存開始 - ${settings['city']}');
      await ConfigManager.save(settings);
      print('SettingsPage: 設定保存完了');
      setState(() => _hasChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定を保存しました')),
        );
        Navigator.pop(context, _cityController.text);
      }
    } catch (e) {
      print('SettingsPage: 設定保存エラー - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存エラー: $e')),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    await ConfigManager.reset();
    await _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リセットしました')),
      );
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('都市設定'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            onPressed: _resetSettings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: '都市名',
                border: OutlineInputBorder(),
                hintText: '例: Tokyo, Osaka, Kyoto',
              ),
              onChanged: (_) => _onChanged(),
            ),
            const SizedBox(height: 32),
            if (_hasChanges) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '変更を保存',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _hasChanges = false);
                    _loadSettings();
                  },
                  child: const Text('変更をキャンセル'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 