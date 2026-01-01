import 'dart:convert';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../data/models/message_model.dart';
import '../../data/models/user_model.dart';
import '../encryption/encryption_service.dart';
import '../constants/app_constants.dart';

class MeshEngine {
  final EncryptionService _encryptionService = EncryptionService();
  final Set<String> _processedMessages = {}; // Cache for duplicate detection
  final Map<String, MessageModel> _messageQueue = {}; // Pending messages
  final Map<String, UserModel> _connectedNodes = {}; // Active connections

  final StreamController<MessageModel> _incomingMessagesController =
      StreamController<MessageModel>.broadcast();
  final StreamController<Map<String, UserModel>> _nodesController =
      StreamController<Map<String, UserModel>>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  // Streams
  Stream<MessageModel> get incomingMessages =>
      _incomingMessagesController.stream;
  Stream<Map<String, UserModel>> get connectedNodesStream =>
      _nodesController.stream;
  Stream<String> get statusStream => _statusController.stream;

  // Getters
  Map<String, UserModel> get connectedNodes => Map.from(_connectedNodes);
  int get connectedNodesCount => _connectedNodes.length;
  int get pendingMessagesCount => _messageQueue.length;

  String? _currentUserId;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Create a new message
  MessageModel createMessage({
    required String to,
    required String payload,
    bool isBroadcast = false,
    bool encrypt = true,
  }) {
    final uuid = const Uuid();
    final messageId = uuid.v4();

    String finalPayload = payload;
    if (encrypt) {
      finalPayload = _encryptionService.encryptMessage(payload);
    }

    final message = MessageModel(
      id: messageId,
      from: _currentUserId ?? 'unknown',
      to: to,
      payload: finalPayload,
      ttl: AppConstants.defaultTTL,
      hop: 0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: AppConstants.statusPending,
      isEncrypted: encrypt,
      isBroadcast: isBroadcast,
      relayPath: [_currentUserId ?? 'unknown'],
    );

    // Generate signature
    message.signature = _encryptionService.generateSignature(
      payload,
      message.from,
    );

    return message;
  }

  /// Process incoming message
  Future<bool> processMessage(MessageModel message) async {
    // Check if message already processed (duplicate detection)
    if (_processedMessages.contains(message.id)) {
      print('Duplicate message detected: ${message.id}');
      return false;
    }

    // Validate TTL
    if (message.ttl <= 0) {
      print('Message TTL expired: ${message.id}');
      return false;
    }

    // Validate hop count
    if (message.hop >= AppConstants.maxHopCount) {
      print('Message exceeded max hops: ${message.id}');
      return false;
    }

    // Validate signature if present
    if (message.signature != null) {
      String decryptedPayload = message.payload;
      if (message.isEncrypted) {
        decryptedPayload = _encryptionService.decryptMessage(message.payload);
      }

      final isValid = _encryptionService.verifySignature(
        decryptedPayload,
        message.from,
        message.signature!,
      );

      if (!isValid) {
        print('Invalid message signature: ${message.id}');
        return false;
      }
    }

    // Add to processed cache
    _processedMessages.add(message.id);
    _cleanupProcessedCache();

    // Check if message is for this node
    if (message.to == _currentUserId || message.isBroadcast) {
      // Decrypt if encrypted
      if (message.isEncrypted) {
        message.payload = _encryptionService.decryptMessage(message.payload);
      }

      // Deliver to user
      _incomingMessagesController.add(message);
      message.status = AppConstants.statusDelivered;
    }

    // Relay message if TTL > 0
    if (message.ttl > 0) {
      await relayMessage(message);
    }

    return true;
  }

  /// Relay message to connected nodes
  Future<void> relayMessage(MessageModel message) async {
    // Create a copy for relay
    final relayMessage = message.copyWith(
      ttl: message.ttl - 1,
      hop: message.hop + 1,
      status: AppConstants.statusRelayed,
      relayPath: [...(message.relayPath ?? []), _currentUserId ?? 'unknown'],
    );

    // Add to queue for forwarding
    _messageQueue[relayMessage.id] = relayMessage;

    // Emit status update
    _statusController.add('Relaying message: ${relayMessage.id}');

    // This would be implemented by the network service
    // For now, we just store it in the queue
    print(
      'Message queued for relay: ${relayMessage.id} (TTL: ${relayMessage.ttl}, Hop: ${relayMessage.hop})',
    );
  }

  /// Get messages from queue for sending
  List<MessageModel> getMessagesToSend() {
    return _messageQueue.values.toList();
  }

  /// Clear a message from queue
  void clearMessageFromQueue(String messageId) {
    _messageQueue.remove(messageId);
  }

  /// Add a connected node
  void addConnectedNode(UserModel user) {
    _connectedNodes[user.id] = user;
    _nodesController.add(_connectedNodes);
    _statusController.add('Node connected: ${user.username}');
  }

  /// Remove a connected node
  void removeConnectedNode(String userId) {
    final user = _connectedNodes.remove(userId);
    if (user != null) {
      _nodesController.add(_connectedNodes);
      _statusController.add('Node disconnected: ${user.username}');
    }
  }

  /// Update node status
  void updateNodeStatus(
    String userId, {
    String? status,
    int? signalStrength,
    double? distance,
  }) {
    final user = _connectedNodes[userId];
    if (user != null) {
      _connectedNodes[userId] = user.copyWith(
        status: status,
        signalStrength: signalStrength,
        distance: distance,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      );
      _nodesController.add(_connectedNodes);
    }
  }

  /// Cleanup old processed messages from cache
  void _cleanupProcessedCache() {
    // Keep only last 1000 processed message IDs
    if (_processedMessages.length > 1000) {
      final toRemove = _processedMessages.length - 1000;
      final iterator = _processedMessages.iterator;
      for (var i = 0; i < toRemove && iterator.moveNext(); i++) {
        _processedMessages.remove(iterator.current);
      }
    }
  }

  /// Clear all nodes
  void clearAllNodes() {
    _connectedNodes.clear();
    _nodesController.add(_connectedNodes);
  }

  /// Get message statistics
  Map<String, int> getStatistics() {
    return {
      'connected_nodes': _connectedNodes.length,
      'pending_messages': _messageQueue.length,
      'processed_messages': _processedMessages.length,
    };
  }

  /// Serialize message for network transmission
  String serializeMessage(MessageModel message) {
    return json.encode(message.toJson());
  }

  /// Deserialize message from network
  MessageModel deserializeMessage(String data) {
    final jsonData = json.decode(data) as Map<String, dynamic>;
    return MessageModel.fromJson(jsonData);
  }

  /// Dispose resources
  void dispose() {
    _incomingMessagesController.close();
    _nodesController.close();
    _statusController.close();
    _processedMessages.clear();
    _messageQueue.clear();
    _connectedNodes.clear();
  }
}
