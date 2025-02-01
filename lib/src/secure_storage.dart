

import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:math';

class SecureStorage {
  static const String _metadataKey = "chisel_metadata";
  static encrypt.Key? _secretKey;

  /// Generate a random AES key at runtime
  static void _generateSecretKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final uint8List = Uint8List.fromList(keyBytes);
    
    _secretKey = encrypt.Key(uint8List);
  
  }

  /// Encrypt data before storing in shared_preferences
  static String encryptData(Map<String, dynamic> data) {
    if (_secretKey == null) _generateSecretKey();
    final encrypter = encrypt.Encrypter(encrypt.AES(_secretKey!, mode: encrypt.AESMode.gcm));
    final iv = encrypt.IV.fromLength(16); // Random IV
    final encrypted = encrypter.encrypt(jsonEncode(data), iv: iv);
    return jsonEncode({"iv": iv.base64, "data": encrypted.base64});
  }

  /// Decrypt data from shared_preferences
  static Map<String, dynamic> decryptData(String encryptedData) {
    if (_secretKey == null) return {}; // If no key, assume empty data
    try {
      final decoded = jsonDecode(encryptedData);
      final iv = encrypt.IV.fromBase64(decoded["iv"]);
      final encrypter = encrypt.Encrypter(encrypt.AES(_secretKey!, mode: encrypt.AESMode.gcm));
      final decrypted = encrypter.decrypt64(decoded["data"], iv: iv);
      return jsonDecode(decrypted);
    } catch (e) {
      return {}; // If decryption fails, return empty
    }
  }

  /// Save encrypted metadata
  static Future<void> saveMetadata(Map<String, dynamic> metadata) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = encryptData(metadata);
    await prefs.setString(_metadataKey, encryptedData);
  }

  /// Load encrypted metadata
  static Future<Map<String, dynamic>> loadMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(_metadataKey);
    if (encryptedData == null) return {};
    return decryptData(encryptedData);
  }
}
