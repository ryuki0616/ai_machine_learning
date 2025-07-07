import 'package:flutter/material.dart';
import 'config_manager.dart';

class JsonViewerPage extends StatefulWidget {
  const JsonViewerPage({Key? key}) : super(key: key);

  @override
  State<JsonViewerPage> createState() => _JsonViewerPageState();
}

class _JsonViewerPageState extends State<JsonViewerPage> {
  String _jsonContent = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      final content = await ConfigManager.asJson();
      setState(() {
        _jsonContent = content;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _jsonContent = 'エラー: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定JSON'),
        actions: [
          IconButton(
            onPressed: _loadJson,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                            await ConfigManager.reset();
                            await _loadJson();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('リセットしました')),
                              );
                            }
                          },
                          child: const Text('リセット'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
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