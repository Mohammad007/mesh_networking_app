import 'dart:async';
import 'dart:convert';
import 'package:nearby_connections/nearby_connections.dart';
import '../data/models/message_model.dart';
import '../data/models/user_model.dart';
import '../core/mesh_engine/mesh_engine.dart';
import '../core/constants/app_constants.dart';

class NearbyService {
  final MeshEngine _meshEngine;
  final Nearby _nearby = Nearby();

  final StreamController<UserModel> _discoveredUsersController =
      StreamController<UserModel>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();

  Stream<UserModel> get discoveredUsers => _discoveredUsersController.stream;
  Stream<String> get connectionStatus => _connectionStatusController.stream;

  bool _isAdvertising = false;
  bool _isDiscovering = false;
  String? _currentUserId;
  String? _currentUsername;

  final Map<String, String> _endpointUserMap = {}; // endpoint -> userId mapping

  NearbyService(this._meshEngine);

  void setUserInfo(String userId, String username) {
    _currentUserId = userId;
    _currentUsername = username;
  }

  /// Start advertising (make device discoverable)
  Future<bool> startAdvertising() async {
    if (_isAdvertising) return true;

    try {
      final strategy = Strategy.P2P_CLUSTER;

      await _nearby.startAdvertising(
        _currentUsername ?? 'MeshNode',
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: AppConstants.serviceId,
      );

      _isAdvertising = true;
      _connectionStatusController.add('Advertising started');
      return true;
    } catch (e) {
      print('Start advertising error: $e');
      _connectionStatusController.add('Advertising failed: $e');
      return false;
    }
  }

  /// Start discovery (scan for nearby devices)
  Future<bool> startDiscovery() async {
    if (_isDiscovering) return true;

    try {
      final strategy = Strategy.P2P_CLUSTER;

      await _nearby.startDiscovery(
        _currentUsername ?? 'MeshNode',
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: AppConstants.serviceId,
      );

      _isDiscovering = true;
      _connectionStatusController.add('Discovery started');
      return true;
    } catch (e) {
      print('Start discovery error: $e');
      _connectionStatusController.add('Discovery failed: $e');
      return false;
    }
  }

  /// Stop advertising
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      await _nearby.stopAdvertising();
      _isAdvertising = false;
      _connectionStatusController.add('Advertising stopped');
    } catch (e) {
      print('Stop advertising error: $e');
    }
  }

  /// Stop discovery
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    try {
      await _nearby.stopDiscovery();
      _isDiscovering = false;
      _connectionStatusController.add('Discovery stopped');
    } catch (e) {
      print('Stop discovery error: $e');
    }
  }

  /// Request connection to an endpoint
  Future<void> requestConnection(String endpointId, String username) async {
    try {
      await _nearby.requestConnection(
        _currentUsername ?? 'MeshNode',
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      print('Request connection error: $e');
      _connectionStatusController.add('Connection request failed: $e');
    }
  }

  /// Accept connection
  Future<void> acceptConnection(String endpointId) async {
    try {
      await _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: _onPayloadReceived,
      );
    } catch (e) {
      print('Accept connection error: $e');
    }
  }

  /// Reject connection
  Future<void> rejectConnection(String endpointId) async {
    try {
      await _nearby.rejectConnection(endpointId);
    } catch (e) {
      print('Reject connection error: $e');
    }
  }

  /// Send message to specific endpoint
  Future<void> sendMessage(String endpointId, MessageModel message) async {
    try {
      final messageJson = _meshEngine.serializeMessage(message);
      await _nearby.sendBytesPayload(endpointId, utf8.encode(messageJson));
    } catch (e) {
      print('Send message error: $e');
    }
  }

  /// Broadcast message to all connected endpoints
  Future<void> broadcastMessage(MessageModel message) async {
    try {
      final messageJson = _meshEngine.serializeMessage(message);
      final endpoints = _endpointUserMap.keys.toList();

      for (final endpointId in endpoints) {
        await _nearby.sendBytesPayload(endpointId, utf8.encode(messageJson));
      }
    } catch (e) {
      print('Broadcast message error: $e');
    }
  }

  /// Disconnect from endpoint
  Future<void> disconnect(String endpointId) async {
    try {
      await _nearby.disconnectFromEndpoint(endpointId);
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  /// Disconnect from all endpoints
  Future<void> disconnectAll() async {
    try {
      await _nearby.stopAllEndpoints();
      _endpointUserMap.clear();
      _meshEngine.clearAllNodes();
    } catch (e) {
      print('Disconnect all error: $e');
    }
  }

  // Callbacks

  void _onEndpointFound(String endpointId, String name, String serviceId) {
    print('Endpoint found: $name ($endpointId)');

    final user = UserModel(
      id: endpointId,
      username: name,
      deviceId: endpointId,
      status: 'nearby',
      lastSeen: DateTime.now().millisecondsSinceEpoch,
    );

    _discoveredUsersController.add(user);
  }

  void _onEndpointLost(String? endpointId) {
    print('Endpoint lost: $endpointId');

    if (endpointId != null) {
      final userId = _endpointUserMap[endpointId];
      if (userId != null) {
        _meshEngine.removeConnectedNode(userId);
        _endpointUserMap.remove(endpointId);
      }
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    print('Connection initiated with: ${info.endpointName}');
    _connectionStatusController.add(
      'Connection initiated: ${info.endpointName}',
    );

    // Auto-accept connections (you can add approval UI here)
    acceptConnection(endpointId);
  }

  void _onConnectionResult(String endpointId, Status status) {
    print('Connection result: ${status.toString()}');

    if (status == Status.CONNECTED) {
      // Connection successful
      _connectionStatusController.add('Connected to endpoint: $endpointId');

      // For now, using endpointId as userId
      // In production, you should exchange user info after connection
      final user = UserModel(
        id: endpointId,
        username: 'User_$endpointId',
        deviceId: endpointId,
        status: 'online',
        connectedAt: DateTime.now().millisecondsSinceEpoch,
      );

      _endpointUserMap[endpointId] = user.id;
      _meshEngine.addConnectedNode(user);
    } else {
      _connectionStatusController.add('Connection failed: $endpointId');
    }
  }

  void _onDisconnected(String endpointId) {
    print('Disconnected from: $endpointId');
    _connectionStatusController.add('Disconnected: $endpointId');

    final userId = _endpointUserMap[endpointId];
    if (userId != null) {
      _meshEngine.removeConnectedNode(userId);
      _endpointUserMap.remove(endpointId);
    }
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    print('Payload received from: $endpointId');

    if (payload.type == PayloadType.BYTES) {
      try {
        final messageJson = utf8.decode(payload.bytes!);
        final message = _meshEngine.deserializeMessage(messageJson);
        _meshEngine.processMessage(message);
      } catch (e) {
        print('Error processing received payload: $e');
      }
    }
  }

  /// Get all connected endpoints
  List<String> getConnectedEndpoints() {
    return _endpointUserMap.keys.toList();
  }

  /// Check if advertising
  bool get isAdvertising => _isAdvertising;

  /// Check if discovering
  bool get isDiscovering => _isDiscovering;

  /// Dispose
  void dispose() {
    stopAdvertising();
    stopDiscovery();
    disconnectAll();
    _discoveredUsersController.close();
    _connectionStatusController.close();
  }
}
