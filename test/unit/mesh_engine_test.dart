import 'package:flutter_test/flutter_test.dart';
import 'package:offline_chat/core/mesh_engine/mesh_engine.dart';
import 'package:offline_chat/data/models/message_model.dart';
import 'package:offline_chat/data/models/user_model.dart';

void main() {
  group('MeshEngine Tests', () {
    late MeshEngine meshEngine;

    setUp(() {
      meshEngine = MeshEngine();
      meshEngine.setCurrentUserId('test_user_123');
    });

    tearDown(() {
      meshEngine.dispose();
    });

    test('Should create message with correct TTL', () {
      // Act
      final message = meshEngine.createMessage(
        to: 'user_456',
        payload: 'Test message',
        isBroadcast: false,
        encrypt: false,
      );

      // Assert
      expect(message.ttl, equals(5)); // Default TTL
      expect(message.hop, equals(0));
      expect(message.from, equals('test_user_123'));
      expect(message.to, equals('user_456'));
      expect(message.payload, equals('Test message'));
    });

    test('Should create broadcast message', () {
      // Act
      final message = meshEngine.createMessage(
        to: 'broadcast',
        payload: 'Emergency alert',
        isBroadcast: true,
        encrypt: false,
      );

      // Assert
      expect(message.isBroadcast, isTrue);
      expect(message.to, equals('broadcast'));
    });

    test('Should process message and relay if TTL > 0', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg_001',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test',
        ttl: 3,
        hop: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'pending',
      );

      // Act
      final shouldRelay = await meshEngine.processMessage(message);

      // Assert
      expect(shouldRelay, isTrue);
    });

    test('Should not relay message if TTL = 0', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg_002',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test',
        ttl: 0,
        hop: 5,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'pending',
      );

      // Act
      final shouldRelay = await meshEngine.processMessage(message);

      // Assert
      expect(shouldRelay, isFalse);
    });

    test('Should detect duplicate messages', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg_003',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test',
        ttl: 3,
        hop: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'pending',
      );

      // Act
      await meshEngine.processMessage(message);
      final isDuplicate = await meshEngine.processMessage(message);

      // Assert
      expect(isDuplicate, isFalse); // Should not relay duplicate
    });

    test('Should add connected node', () {
      // Arrange
      final user = UserModel(
        id: 'user_789',
        username: 'TestUser',
        deviceId: 'device_789',
        status: 'online',
        connectedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act
      meshEngine.addConnectedNode(user);

      // Assert - Check via stream
      expectLater(
        meshEngine.connectedNodesStream,
        emits(
          predicate<Map<String, UserModel>>((nodes) {
            return nodes.containsKey('user_789');
          }),
        ),
      );
    });

    test('Should remove connected node', () {
      // Arrange
      final user = UserModel(
        id: 'user_999',
        username: 'TestUser',
        deviceId: 'device_999',
        status: 'online',
        connectedAt: DateTime.now().millisecondsSinceEpoch,
      );
      meshEngine.addConnectedNode(user);

      // Act
      meshEngine.removeConnectedNode('user_999');

      // Assert - Check via stream
      expectLater(
        meshEngine.connectedNodesStream,
        emits(
          predicate<Map<String, UserModel>>((nodes) {
            return !nodes.containsKey('user_999');
          }),
        ),
      );
    });

    test('Should increment hop count when relaying', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg_004',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test',
        ttl: 5,
        hop: 2,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'pending',
      );

      // Act
      await meshEngine.processMessage(message);

      // Assert
      expect(message.hop, greaterThan(2));
    });

    test('Should decrement TTL when relaying', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg_005',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test',
        ttl: 5,
        hop: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'pending',
      );
      final originalTTL = message.ttl;

      // Act
      await meshEngine.processMessage(message);

      // Assert
      expect(message.ttl, lessThan(originalTTL));
    });

    test('Should serialize and deserialize message', () {
      // Arrange
      final originalMessage = MessageModel(
        id: 'msg_006',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test payload',
        ttl: 5,
        hop: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'pending',
        signature: 'test_signature',
      );

      // Act
      final json = meshEngine.serializeMessage(originalMessage);
      final deserializedMessage = meshEngine.deserializeMessage(json);

      // Assert
      expect(deserializedMessage.id, equals(originalMessage.id));
      expect(deserializedMessage.from, equals(originalMessage.from));
      expect(deserializedMessage.to, equals(originalMessage.to));
      expect(deserializedMessage.payload, equals(originalMessage.payload));
      expect(deserializedMessage.ttl, equals(originalMessage.ttl));
    });

    test('Should handle expired messages', () async {
      // Arrange
      final expiredMessage = MessageModel(
        id: 'msg_007',
        from: 'user_A',
        to: 'user_B',
        payload: 'Test',
        ttl: 0,
        hop: 10,
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
        status: 'expired',
      );

      // Act
      final shouldRelay = await meshEngine.processMessage(expiredMessage);

      // Assert
      expect(shouldRelay, isFalse);
    });
  });
}
