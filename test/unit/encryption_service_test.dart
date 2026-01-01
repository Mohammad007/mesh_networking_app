import 'package:flutter_test/flutter_test.dart';
import 'package:offline_chat/core/encryption/encryption_service.dart';

void main() {
  group('EncryptionService Tests', () {
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
    });

    test('Should encrypt and decrypt text correctly', () {
      // Arrange
      const plainText = 'Hello, Mesh Network!';

      // Act
      final encrypted = encryptionService.encryptMessage(plainText);
      final decrypted = encryptionService.decryptMessage(encrypted);

      // Assert
      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText)));
    });

    test('Should generate unique random keys', () {
      // Act
      final key1 = encryptionService.generateRandomKey();
      final key2 = encryptionService.generateRandomKey();

      // Assert
      expect(key1, isNot(equals(key2)));
      expect(key1.length, greaterThan(0));
    });

    test('Should create message signature with senderId', () {
      // Arrange
      const message = 'Test message';
      const senderId = 'user_123';

      // Act
      final signature = encryptionService.generateSignature(message, senderId);

      // Assert
      expect(signature, isNotEmpty);
      expect(signature.length, greaterThan(0));
    });

    test('Should verify valid signature', () {
      // Arrange
      const message = 'Test message';
      const senderId = 'user_123';
      final signature = encryptionService.generateSignature(message, senderId);

      // Act
      final isValid = encryptionService.verifySignature(
        message,
        senderId,
        signature,
      );

      // Assert
      expect(isValid, isTrue);
    });

    test('Should reject invalid signature', () {
      // Arrange
      const message = 'Test message';
      const senderId = 'user_123';
      const wrongSignature = 'invalid_signature';

      // Act
      final isValid = encryptionService.verifySignature(
        message,
        senderId,
        wrongSignature,
      );

      // Assert
      expect(isValid, isFalse);
    });

    test('Should hash data consistently', () {
      // Arrange
      const data = 'Test data';

      // Act
      final hash1 = encryptionService.hashData(data);
      final hash2 = encryptionService.hashData(data);

      // Assert
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 hex
    });

    test('Should produce different hashes for different data', () {
      // Arrange
      const data1 = 'Test data 1';
      const data2 = 'Test data 2';

      // Act
      final hash1 = encryptionService.hashData(data1);
      final hash2 = encryptionService.hashData(data2);

      // Assert
      expect(hash1, isNot(equals(hash2)));
    });

    test('Should handle empty string encryption', () {
      // Arrange
      const plainText = '';

      // Act
      final encrypted = encryptionService.encryptMessage(plainText);
      final decrypted = encryptionService.decryptMessage(encrypted);

      // Assert
      expect(decrypted, equals(plainText));
    });

    test('Should handle special characters encryption', () {
      // Arrange
      const plainText = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

      // Act
      final encrypted = encryptionService.encryptMessage(plainText);
      final decrypted = encryptionService.decryptMessage(encrypted);

      // Assert
      expect(decrypted, equals(plainText));
    });

    test('Should handle unicode encryption', () {
      // Arrange
      const plainText = 'Hello 世界 🌍';

      // Act
      final encrypted = encryptionService.encryptMessage(plainText);
      final decrypted = encryptionService.decryptMessage(encrypted);

      // Assert
      expect(decrypted, equals(plainText));
    });

    test('Should encrypt and decrypt JSON data', () {
      // Arrange
      final jsonData = {
        'message': 'Hello',
        'sender': 'user_123',
        'timestamp': 1234567890,
      };

      // Act
      final encrypted = encryptionService.encryptJson(jsonData);
      final decrypted = encryptionService.decryptJson(encrypted);

      // Assert
      expect(decrypted, equals(jsonData));
    });

    test('Should create consistent device hash', () {
      // Arrange
      const deviceInfo = 'device_12345';

      // Act
      final hash1 = encryptionService.createDeviceHash(deviceInfo);
      final hash2 = encryptionService.createDeviceHash(deviceInfo);

      // Assert
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(16));
    });

    test('Should validate message integrity', () {
      // Arrange
      const message = 'Test message';
      final hash = encryptionService.hashData(message);

      // Act
      final isValid = encryptionService.validateMessageIntegrity(message, hash);

      // Assert
      expect(isValid, isTrue);
    });

    test('Should reject tampered message', () {
      // Arrange
      const originalMessage = 'Test message';
      const tamperedMessage = 'Tampered message';
      final hash = encryptionService.hashData(originalMessage);

      // Act
      final isValid = encryptionService.validateMessageIntegrity(
        tamperedMessage,
        hash,
      );

      // Assert
      expect(isValid, isFalse);
    });
  });
}
