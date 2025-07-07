import 'dart:convert';
import 'dart:math';

/// APIキーの暗号化・復号化を行うサービスクラス
/// 簡単な暗号化方式を使用（本番環境ではより強固な暗号化を推奨）
class EncryptionService {
  // 暗号化キー（実際のアプリでは環境変数や安全な場所から取得）
  static const String _encryptionKey = 'your-secret-key-123';
  
  /// 文字列を暗号化する
  /// 
  /// [text] 暗号化したい文字列
  /// 返り値: 暗号化された文字列（Base64エンコード）
  static String encrypt(String text) {
    if (text.isEmpty) return '';
    
    // 簡単な暗号化（XOR + Base64）
    final bytes = utf8.encode(text);
    final keyBytes = utf8.encode(_encryptionKey);
    final encryptedBytes = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
    );
    
    return base64.encode(encryptedBytes);
  }
  
  /// 暗号化された文字列を復号化する
  /// 
  /// [encryptedText] 暗号化された文字列（Base64エンコード）
  /// 返り値: 復号化された文字列
  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    
    try {
      // 復号化（Base64デコード + XOR）
      final encryptedBytes = base64.decode(encryptedText);
      final keyBytes = utf8.encode(_encryptionKey);
      final decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      print('復号化エラー: $e');
      return '';
    }
  }
  
  /// APIキーが暗号化されているかチェック
  /// 
  /// [text] チェックする文字列
  /// 返り値: 暗号化されている場合はtrue
  static bool isEncrypted(String text) {
    if (text.isEmpty) return false;
    
    try {
      // Base64デコードを試行
      base64.decode(text);
      return true;
    } catch (e) {
      return false;
    }
  }
} 