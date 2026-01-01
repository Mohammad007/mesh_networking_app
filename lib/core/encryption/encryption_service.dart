import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  EncryptionService() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // In production, you should securely generate and store these
    // For now, using a default key (CHANGE THIS IN PRODUCTION!)
    final keyString = 'MeshNetSecureKey2024MeshNetworkApp';
    _key = encrypt.Key.fromUtf8(keyString.substring(0, 32));
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  /// Encrypt a message
  String encryptMessage(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return plainText; // Fallback to plaintext on error
    }
  }

  /// Decrypt a message
  String decryptMessage(String encryptedText) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('Decryption error: $e');
      return encryptedText; // Return as-is if decryption fails
    }
  }

  /// Generate a signature for message validation
  String generateSignature(String message, String senderId) {
    final bytes = utf8.encode('$message:$senderId');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify message signature
  bool verifySignature(String message, String senderId, String signature) {
    final expectedSignature = generateSignature(message, senderId);
    return expectedSignature == signature;
  }

  /// Generate a hash of data
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a random key
  String generateRandomKey() {
    final key = encrypt.Key.fromSecureRandom(32);
    return base64.encode(key.bytes);
  }

  /// Encrypt JSON data
  String encryptJson(Map<String, dynamic> jsonData) {
    final jsonString = json.encode(jsonData);
    return encryptMessage(jsonString);
  }

  /// Decrypt JSON data
  Map<String, dynamic> decryptJson(String encryptedData) {
    try {
      final decryptedString = decryptMessage(encryptedData);
      return json.decode(decryptedString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON decryption error: $e');
      return {};
    }
  }

  /// Create a secure hash for device IDs
  String createDeviceHash(String deviceInfo) {
    final bytes = utf8.encode(deviceInfo);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // First 16 characters
  }

  /// Validate encrypted message integrity
  bool validateMessageIntegrity(String message, String hash) {
    final calculatedHash = hashData(message);
    return calculatedHash == hash;
  }
}
