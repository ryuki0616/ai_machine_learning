import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'encryption_service.dart';

/// ニュースサービスクラス
/// Gemini AIを使用してニュースの取得・要約を行う
class NewsService {
  /// Google Gemini APIのAPIキー（暗号化済み）
  /// 注意: 本番環境では環境変数や安全な設定管理を使用すること
  /// 暗号化キー: 'your-secret-key-123'
  static const String _encryptedApiKey = 'OCYPE34KJxs3LEJ6GyMIRX8LUh0/AScaOSYCCA1ZXyxWLRt+dHw8';
  
  /// Geminiモデルのインスタンス（初期化時に作成）
  /// late修飾子により、initialize()が呼ばれるまで使用不可
  static late final GenerativeModel _model;
  
  /// Geminiモデルの初期化
  /// アプリ起動時などに一度だけ呼び出す必要がある
  /// このメソッドを呼ばずにgetNews()やgetDetailedSummary()を使用するとエラーになる
  static void initialize() {
    // 暗号化されたAPIキーを復号化
    final apiKey = EncryptionService.decrypt(_encryptedApiKey);
    if (apiKey.isEmpty) {
      throw Exception('APIキーの復号化に失敗しました');
    }
    
    _model = GenerativeModel(
      model: 'gemini-2.5-pro', // 使用するGeminiモデル名（最新推奨モデル）
      apiKey: apiKey,          // 復号化されたAPIキー
    );
  }

  /// 指定したカテゴリの最新ニュースをAIから取得し、要約付きで返す
  /// 
  /// [category] ニュースカテゴリ（例: "テクノロジー", "ビジネス", "スポーツ"）
  /// 返り値: NewsItem（タイトル・要約・URL）のリスト（最大3件）
  /// 
  /// 処理の流れ:
  /// 1. AIにプロンプトを送信してニュースを取得
  /// 2. 返答からJSON部分を抽出
  /// 3. JSONをパースしてNewsItemリストに変換
  /// 4. エラー時はダミーデータを返す
  static Future<List<NewsItem>> getNews(String category) async {
    try {
      // AIに送るプロンプト（指示文）
      // 指定カテゴリのニュースを3件、タイトル・要約・URL付きでJSON形式で返すよう指示
      final prompt = '''
以下のカテゴリの最新ニュースを3つ取得し、各ニュースについて以下の形式でJSONで返してください：
[
  {
    "title": "ニュースのタイトル",
    "summary": "200文字程度の要約",
    "url": "ニュースのURL（もしあれば）"
  }
]

カテゴリ: $category
言語: 日本語
''';

      // Gemini APIにプロンプトを送信し、AIの返答を受け取る
      // Content.text()でテキスト形式のプロンプトを作成
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? ''; // 返答がnullの場合は空文字列
      
      // 返答からJSON部分だけを抽出（```json ... ``` の間を抜き出す）
      // dotAll: true により改行文字も含めてマッチング
      final jsonMatch = RegExp(r'```json\s*(.*?)\s*```', dotAll: true).firstMatch(text);
      final jsonString = jsonMatch?.group(1) ?? text; // マッチしない場合は全体を使用
      
      // JSON文字列をパースしてリスト化
      // json.decode()で文字列をMapやListに変換
      final List<dynamic> newsList = json.decode(jsonString);
      
      // 各要素をNewsItemオブジェクトに変換して返す
      // map()で各要素にfromJson()を適用し、toList()でリスト化
      return newsList.map((item) => NewsItem.fromJson(item)).toList();
    } catch (e) {
      // エラーをログ出力（デバッグ用）
      print('ニュース取得エラー: $e');
      
      // エラー時はダミーデータ（エラー内容を示すNewsItem）を返す
      // これによりアプリがクラッシュすることを防ぐ
      return [
        NewsItem(
          title: 'ニュース取得エラー（ダミー）',
          summary: 'ニュースの取得に失敗しました。APIキーの設定を確認してください。（ダミー）',
          url: '',
        ),
      ];
    }
  }

  /// ニュースタイトルとカテゴリを指定して、AIに150文字程度で詳しく要約させる
  /// 
  /// [title] 要約したいニュースのタイトル
  /// [category] ニュースのカテゴリ
  /// 返り値: 要約文（String）
  /// 
  /// 使用例: ユーザーがニュースタイトルをタップした時に詳細要約を表示
  static Future<String> getDetailedSummary(String title, String category) async {
    try {
      // AIに送るプロンプト（タイトルとカテゴリを与えて要約を依頼）
      final prompt = '''
以下のニュースについて、150文字程度で詳しく要約してください：

タイトル: $title
カテゴリ: $category

要約:
''';

      // Gemini APIにプロンプトを送信し、要約文を受け取る
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '要約の取得に失敗しました（ダミー）';
    } catch (e) {
      // エラー時はエラーメッセージを返す
      return '要約の取得に失敗しました: $e（ダミー）';
    }
  }
}

/// ニュース1件分のデータ構造
/// タイトル・要約・URLの情報を持つ
class NewsItem {
  /// ニュースのタイトル
  final String title;
  
  /// ニュースの要約（150文字以内推奨）
  final String summary;
  
  /// ニュースのURL（あれば、なければ空文字列）
  final String url;

  /// コンストラクタ
  /// 全てのフィールドが必須（required）
  NewsItem({
    required this.title,
    required this.summary,
    required this.url,
  });

  /// JSONからNewsItemを生成するファクトリメソッド
  /// 
  /// [json] パース済みのJSONオブジェクト（Map<String, dynamic>）
  /// 返り値: NewsItemインスタンス
  /// 
  /// 各フィールドが存在しない場合は空文字列をデフォルト値として使用
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',     // titleがnullの場合は空文字列
      summary: json['summary'] ?? '', // summaryがnullの場合は空文字列
      url: json['url'] ?? '',         // urlがnullの場合は空文字列
    );
  }

  /// NewsItemをJSON形式に変換
  /// 
  /// 返り値: JSONオブジェクト（Map<String, dynamic>）
  /// 主にデバッグやデータ保存時に使用
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'url': url,
    };
  }
} 