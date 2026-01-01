import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../data/models/message_model.dart';
import '../data/models/user_model.dart';
import '../core/mesh_engine/mesh_engine.dart';

class BluetoothMeshService {
  final MeshEngine _meshEngine;

  final StreamController<UserModel> _discoveredDevicesController =
      StreamController<UserModel>.broadcast();
  final StreamController<String> _bluetoothStatusController =
      StreamController<String>.broadcast();

  Stream<UserModel> get discoveredDevices =>
      _discoveredDevicesController.stream;
  Stream<String> get bluetoothStatus => _bluetoothStatusController.stream;

  final List<BluetoothDevice> _connectedDevices = [];
  final Map<String, BluetoothCharacteristic> _characteristics = {};

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isScanning = false;

  // Custom service and characteristic UUIDs for mesh networking
  static const String MESH_SERVICE_UUID =
      '0000180a-0000-1000-8000-00805f9b34fb';
  static const String MESH_CHAR_UUID = '00002a57-0000-1000-8000-00805f9b34fb';

  BluetoothMeshService(this._meshEngine);

  /// Check if Bluetooth is available
  Future<bool> isBluetoothAvailable() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _bluetoothStatusController.add('Bluetooth not supported');
        return false;
      }
      return true;
    } catch (e) {
      print('Bluetooth availability check error: $e');
      return false;
    }
  }

  /// Check Bluetooth state
  Future<BluetoothAdapterState> getBluetoothState() async {
    return await FlutterBluePlus.adapterState.first;
  }

  /// Turn on Bluetooth
  Future<void> turnOnBluetooth() async {
    try {
      if (await FlutterBluePlus.isSupported) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      print('Turn on Bluetooth error: $e');
      _bluetoothStatusController.add('Failed to turn on Bluetooth');
    }
  }

  /// Start scanning for devices
  Future<void> startScan() async {
    if (_isScanning) return;

    try {
      _isScanning = true;
      _bluetoothStatusController.add('Scanning started');

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          _onDeviceDiscovered(result);
        }
      });
    } catch (e) {
      print('Start scan error: $e');
      _bluetoothStatusController.add('Scan failed: $e');
      _isScanning = false;
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _isScanning = false;
      _bluetoothStatusController.add('Scanning stopped');
    } catch (e) {
      print('Stop scan error: $e');
    }
  }

  /// Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _bluetoothStatusController.add('Connecting to ${device.platformName}');

      await device.connect(
        timeout: const Duration(seconds: 30),
        autoConnect: false,
      );

      _connectedDevices.add(device);

      // Discover services
      List<fbp.BluetoothService> services = await device.discoverServices();

      // Find mesh characteristic
      for (fbp.BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // Store characteristics for later use
          _characteristics[device.remoteId.toString()] = characteristic;

          // Subscribe to notifications
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              _onDataReceived(device.remoteId.toString(), value);
            });
          }
        }
      }

      // Add to mesh engine
      final user = UserModel(
        id: device.remoteId.toString(),
        username: device.platformName.isNotEmpty
            ? device.platformName
            : 'BT_Device',
        deviceId: device.remoteId.toString(),
        status: 'online',
        connectedAt: DateTime.now().millisecondsSinceEpoch,
      );

      _meshEngine.addConnectedNode(user);
      _bluetoothStatusController.add('Connected to ${device.platformName}');

      return true;
    } catch (e) {
      print('Connect error: $e');
      _bluetoothStatusController.add('Connection failed: $e');
      return false;
    }
  }

  /// Disconnect from a device
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      _connectedDevices.remove(device);
      _characteristics.remove(device.remoteId.toString());
      _meshEngine.removeConnectedNode(device.remoteId.toString());
      _bluetoothStatusController.add(
        'Disconnected from ${device.platformName}',
      );
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  /// Disconnect from all devices
  Future<void> disconnectAll() async {
    for (var device in List.from(_connectedDevices)) {
      await disconnectFromDevice(device);
    }
  }

  /// Send message to a specific device
  Future<void> sendMessage(String deviceId, MessageModel message) async {
    try {
      final characteristic = _characteristics[deviceId];
      if (characteristic == null) {
        print('No characteristic found for device: $deviceId');
        return;
      }

      final messageJson = _meshEngine.serializeMessage(message);
      final bytes = utf8.encode(messageJson);

      // BLE has a limit of ~512 bytes per write
      // For larger messages, we need to chunk them
      const int chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length)
            ? i + chunkSize
            : bytes.length;
        final chunk = bytes.sublist(i, end);
        await characteristic.write(chunk, withoutResponse: false);
      }
    } catch (e) {
      print('Send message error: $e');
    }
  }

  /// Broadcast message to all connected devices
  Future<void> broadcastMessage(MessageModel message) async {
    for (var deviceId in _characteristics.keys) {
      await sendMessage(deviceId, message);
    }
  }

  /// Handle discovered device
  void _onDeviceDiscovered(ScanResult result) {
    final device = result.device;
    final rssi = result.rssi;

    // Estimate distance based on RSSI
    double distance = _estimateDistance(rssi);

    final user = UserModel(
      id: device.remoteId.toString(),
      username: device.platformName.isNotEmpty
          ? device.platformName
          : 'Unknown',
      deviceId: device.remoteId.toString(),
      status: 'nearby',
      signalStrength: rssi,
      distance: distance,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
    );

    _discoveredDevicesController.add(user);
  }

  /// Handle received data
  void _onDataReceived(String deviceId, List<int> value) {
    try {
      final messageJson = utf8.decode(value);
      final message = _meshEngine.deserializeMessage(messageJson);
      _meshEngine.processMessage(message);
    } catch (e) {
      print('Data processing error: $e');
    }
  }

  /// Estimate distance from RSSI
  double _estimateDistance(int rssi) {
    // Simple distance estimation formula
    // Distance = 10 ^ ((Measured Power - RSSI) / (10 * N))
    // N = 2-4 (environment factor), Measured Power = -59 (at 1m)
    const measuredPower = -59;
    const environmentFactor = 2.0;

    if (rssi == 0) return -1.0;

    final ratio = rssi * 1.0 / measuredPower;
    if (ratio < 1.0) {
      return ratio * ratio;
    } else {
      final distance =
          (0.89976) * (ratio * ratio * ratio) +
          (7.7095) * (ratio * ratio) +
          (0.111);
      return distance;
    }
  }

  /// Get connected devices
  List<BluetoothDevice> get connectedDevices => List.from(_connectedDevices);

  /// Check if scanning
  bool get isScanning => _isScanning;

  /// Dispose
  void dispose() {
    stopScan();
    disconnectAll();
    _discoveredDevicesController.close();
    _bluetoothStatusController.close();
  }
}
