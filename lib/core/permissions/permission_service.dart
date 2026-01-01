import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Check if all required permissions are granted
  Future<bool> checkAllPermissions() async {
    final permissions = await _getRequiredPermissions();
    for (final permission in permissions) {
      if (!(await permission.isGranted)) {
        return false;
      }
    }
    return true;
  }

  /// Get list of required permissions
  List<Permission> _getRequiredPermissions() {
    return [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ];
  }

  /// Request all required permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = _getRequiredPermissions();
    return await permissions.request();
  }

  /// Check individual permission status
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  /// Request individual permission
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  /// Check if Bluetooth is granted
  Future<bool> isBluetoothGranted() async {
    return await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted;
  }

  /// Check if Location is granted
  Future<bool> isLocationGranted() async {
    return await Permission.location.isGranted ||
        await Permission.locationWhenInUse.isGranted;
  }

  /// Check if Nearby Devices is granted
  Future<bool> isNearbyDevicesGranted() async {
    return await Permission.nearbyWifiDevices.isGranted;
  }

  /// Get permission details for UI
  Future<Map<String, PermissionDetail>> getPermissionDetails() async {
    return {
      'bluetooth': PermissionDetail(
        title: 'Bluetooth',
        description: 'Required for mesh network connectivity',
        icon: 'bluetooth',
        isGranted: await isBluetoothGranted(),
        permissions: [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ],
      ),
      'location': PermissionDetail(
        title: 'Location',
        description: 'Required for nearby device discovery',
        icon: 'location_on',
        isGranted: await isLocationGranted(),
        permissions: [Permission.location, Permission.locationWhenInUse],
      ),
      'nearby_devices': PermissionDetail(
        title: 'Nearby Devices',
        description: 'Required for Wi-Fi Direct connections',
        icon: 'devices',
        isGranted: await isNearbyDevicesGranted(),
        permissions: [Permission.nearbyWifiDevices],
      ),
    };
  }

  /// Open app settings
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Check if permission is permanently denied
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  /// Get permission status text
  String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      default:
        return 'Unknown';
    }
  }
}

class PermissionDetail {
  final String title;
  final String description;
  final String icon;
  final bool isGranted;
  final List<Permission> permissions;

  PermissionDetail({
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
    required this.permissions,
  });

  Future<bool> request() async {
    final results = await permissions.request();
    return results.values.every((status) => status.isGranted);
  }
}
