import 'package:flutter/material.dart';
import 'config_manager.dart';
import 'city_data_service.dart';

class JsonViewerPage extends StatefulWidget {
  const JsonViewerPage({Key? key}) : super(key: key);

  @override
  State<JsonViewerPage> createState() => _JsonViewerPageState();
}

class _JsonViewerPageState extends State<JsonViewerPage> {
  String _jsonContent = '';
  bool _isLoading = true;
  String _selectedFile = 'settings';

  @override
  void initState() {
    super.initState();
    _loadJsonContent();
  }

  Future<void> _loadJsonContent() async {
    try {
      String content;
      switch (_selectedFile) {
        case 'settings':
          content = await ConfigManager.getSettingsAsString();
          break;
        case 'cities':
          content = await CityDataService.getCitiesAsJson();
          break;
        default:
          content = await ConfigManager.getSettingsAsString();
      }
      
      setState(() {
        _jsonContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _jsonContent = 'エラー: $e';
        _isLoading = false;
      });
    }
  }

  void _changeFile(String fileType) {
    setState(() {
      _selectedFile = fileType;
      _isLoading = true;
    });
    _loadJsonContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON設定ファイル'),
        actions: [
          IconButton(
            onPressed: _loadJsonContent,
            icon: const Icon(Icons.refresh),
            tooltip: '再読み込み',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'JSONファイル: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedFile,
                        items: const [
                          DropdownMenuItem(
                            value: 'settings',
                            child: Text('設定ファイル'),
                          ),
                          DropdownMenuItem(
                            value: 'cities',
                            child: Text('都市データ'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _changeFile(value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _jsonContent,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ConfigManager.resetSettings();
                            await _loadJsonContent();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('設定をリセットしました')),
                              );
                            }
                          },
                          child: const Text('設定をリセット'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('閉じる'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 