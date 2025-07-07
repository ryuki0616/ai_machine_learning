import 'encryption_service.dart';

/// APIキーを暗号化するためのヘルパークラス
/// 新しいAPIキーを取得した時に使用
class ApiKeyHelper {
  /// 新しいAPIキーを暗号化する
  /// 
  /// 使用方法:
  /// 1. このファイルを一時的に作成
  /// 2. 下のmain()関数で新しいAPIキーを暗号化
  /// 3. 出力された暗号化文字列をnews_service.dartの_encryptedApiKeyに設定
  /// 4. このファイルを削除
  static void main() {
    // ここに新しいAPIキーを入力
    const newApiKey = '';
    
    // 暗号化
    final encrypted = EncryptionService.encrypt(newApiKey);
    
    print('=== APIキー暗号化結果 ===');
    print('元のAPIキー: $newApiKey');
    print('暗号化されたAPIキー: $encrypted');
    print('========================');
    print('');
    print('news_service.dartの_encryptedApiKeyを以下の値に変更してください:');
    print('static const String _encryptedApiKey = \'$encrypted\';');
  }
}

/// メイン関数（Dart実行用）
void main() {
  ApiKeyHelper.main();
} 