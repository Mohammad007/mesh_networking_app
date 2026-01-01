import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/mesh_engine/mesh_engine.dart';
import '../services/nearby_service.dart';
import '../services/bluetooth_service.dart';
import '../data/models/message_model.dart';
import '../data/models/user_model.dart';
import '../data/local_db/database_service.dart';
import '../core/constants/app_constants.dart';

class MeshProvider extends ChangeNotifier {
  // Core Services
  late final MeshEngine _meshEngine;
  late final NearbyService _nearbyService;
  late final BluetoothMeshService _bluetoothService;

  // State
  bool _isMeshActive = false;
  String? _currentUserId;
  String? _currentUsername;

  // Connected nodes
  final Map<String, UserModel> _connectedNodes = {};

  // Discovered devices
  final Map<String, UserModel> _discoveredDevices = {};

  // Messages
  final List<MessageModel> _messages = [];
  final List<MessageModel> _pendingMessages = [];

  // Status
  String _status = 'Offline';
  bool _isDiscovering = false;

  // Stream subscriptions
  StreamSubscription? _nodesSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _nearbyDiscoverySubscription;
  StreamSubscription? _bluetoothDiscoverySubscription;
  StreamSubscription? _statusSubscription;

  // Getters
  bool get isMeshActive => _isMeshActive;
  String get status => _status;
  bool get isDiscovering => _isDiscovering;
  Map<String, UserModel> get connectedNodes => Map.from(_connectedNodes);
  Map<String, UserModel> get discoveredDevices => Map.from(_discoveredDevices);
  List<MessageModel> get messages => List.from(_messages);
  List<MessageModel> get pendingMessages => List.from(_pendingMessages);
  int get connectedNodesCount => _connectedNodes.length;
  int get pendingMessagesCount => _pendingMessages.length;
  String? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername;

  MeshProvider() {
    _meshEngine = MeshEngine();
    _nearbyService = NearbyService(_meshEngine);
    _bluetoothService = BluetoothMeshService(_meshEngine);
    _initialize();
  }

  Future<void> _initialize() async {
    // Load user data
    _currentUsername = DatabaseService.getSetting('username');
    _currentUserId = DatabaseService.getSetting('device_id');

    if (_currentUserId != null) {
      _meshEngine.setCurrentUserId(_currentUserId!);
      _nearbyService.setUserInfo(_currentUserId!, _currentUsername ?? 'User');
    }

    // Load cached messages
    _messages.addAll(DatabaseService.getAllMessages());
    _pendingMessages.addAll(DatabaseService.getQueuedMessages());

    // Setup listeners
    _setupListeners();

    notifyListeners();
  }

  void _setupListeners() {
    // Listen to connected nodes
    _nodesSubscription = _meshEngine.connectedNodesStream.listen((nodes) {
      _connectedNodes.clear();
      _connectedNodes.addAll(nodes);
      notifyListeners();
    });

    // Listen to incoming messages
    _messagesSubscription = _meshEngine.incomingMessages.listen((
      message,
    ) async {
      _messages.add(message);
      await DatabaseService.saveMessage(message);
      notifyListeners();
    });

    // Listen to nearby devices
    _nearbyDiscoverySubscription = _nearbyService.discoveredUsers.listen((
      user,
    ) {
      _discoveredDevices[user.id] = user;
      notifyListeners();
    });

    // Listen to bluetooth devices
    _bluetoothDiscoverySubscription = _bluetoothService.discoveredDevices
        .listen((user) {
          _discoveredDevices[user.id] = user;
          notifyListeners();
        });

    // Listen to status changes
    _statusSubscription = _meshEngine.statusStream.listen((status) {
      _status = status;
      notifyListeners();
    });
  }

  /// Start mesh network
  Future<void> startMesh() async {
    if (_isMeshActive) return;

    try {
      _status = 'Starting mesh network...';
      notifyListeners();

      // Start nearby connections (Wi-Fi Direct)
      await _nearbyService.startAdvertising();
      await _nearbyService.startDiscovery();

      // Start bluetooth
      await _bluetoothService.startScan();

      _isMeshActive = true;
      _status = 'Mesh Active';
      notifyListeners();

      // Start auto-forwarding pending messages
      _startMessageForwarding();
    } catch (e) {
      _status = 'Failed to start: $e';
      _isMeshActive = false;
      notifyListeners();
    }
  }

  /// Stop mesh network
  Future<void> stopMesh() async {
    if (!_isMeshActive) return;

    _status = 'Stopping mesh...';
    notifyListeners();

    await _nearbyService.stopAdvertising();
    await _nearbyService.stopDiscovery();
    await _bluetoothService.stopScan();

    _isMeshActive = false;
    _status = 'Offline';
    _connectedNodes.clear();
    notifyListeners();
  }

  /// Start auto discovery
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    _discoveredDevices.clear();
    notifyListeners();

    // Restart discovery
    await _nearbyService.startDiscovery();
    await _bluetoothService.startScan();

    // Auto-stop after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (_isDiscovering) {
        stopDiscovery();
      }
    });
  }

  /// Stop discovery
  Future<void> stopDiscovery() async {
    _isDiscovering = false;
    notifyListeners();
  }

  /// Connect to a discovered device
  Future<void> connectToDevice(String deviceId) async {
    final device = _discoveredDevices[deviceId];
    if (device == null) return;

    await _nearbyService.requestConnection(deviceId, device.username);
  }

  /// Send a message
  Future<void> sendMessage({
    required String to,
    required String content,
    bool isBroadcast = false,
  }) async {
    final message = _meshEngine.createMessage(
      to: to,
      payload: content,
      isBroadcast: isBroadcast,
      encrypt: true,
    );

    // Save to messages database
    await DatabaseService.saveMessage(message);

    // Create a copy for the queue to avoid Hive error
    final queueMessage = message.copyWith();
    await DatabaseService.addToQueue(queueMessage);

    _messages.add(message);
    _pendingMessages.add(message);
    notifyListeners();

    // Send to connected nodes
    await _broadcastMessage(message);
  }

  /// Broadcast message to all connected nodes
  Future<void> _broadcastMessage(MessageModel message) async {
    // Send via nearby connections
    await _nearbyService.broadcastMessage(message);

    // Send via bluetooth
    await _bluetoothService.broadcastMessage(message);

    // Update status
    message.status = AppConstants.statusRelayed;
    await DatabaseService.saveMessage(message);
    notifyListeners();
  }

  /// Auto-forward pending messages
  void _startMessageForwarding() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isMeshActive) {
        timer.cancel();
        return;
      }

      // Get messages to forward
      final messagesToForward = _meshEngine.getMessagesToSend();

      for (var message in messagesToForward) {
        _broadcastMessage(message);
        _meshEngine.clearMessageFromQueue(message.id);
      }
    });
  }

  /// Get messages for a specific user
  List<MessageModel> getMessagesForUser(String userId) {
    return _messages
        .where(
          (msg) =>
              (msg.from == userId && msg.to == _currentUserId) ||
              (msg.from == _currentUserId && msg.to == userId),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get chat list (unique users with last message)
  List<Map<String, dynamic>> getChatList() {
    final chatsMap = <String, Map<String, dynamic>>{};

    for (var message in _messages) {
      final otherUserId = message.from == _currentUserId
          ? message.to
          : message.from;

      if (!chatsMap.containsKey(otherUserId) ||
          message.timestamp > chatsMap[otherUserId]!['timestamp']) {
        chatsMap[otherUserId] = {
          'userId': otherUserId,
          'username': _connectedNodes[otherUserId]?.username ?? otherUserId,
          'lastMessage': message.payload,
          'timestamp': message.timestamp,
          'unreadCount': 0, // TODO: Implement read status
        };
      }
    }

    return chatsMap.values.toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
    _messages.clear();
    _pendingMessages.clear();
    _connectedNodes.clear();
    _discoveredDevices.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _nodesSubscription?.cancel();
    _messagesSubscription?.cancel();
    _nearbyDiscoverySubscription?.cancel();
    _bluetoothDiscoverySubscription?.cancel();
    _statusSubscription?.cancel();
    _meshEngine.dispose();
    _nearbyService.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }
}
