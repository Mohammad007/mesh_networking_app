class AppConstants {
  // App Info
  static const String appName = 'MeshNet';
  static const String appVersion = '1.0.0';

  // Mesh Networking
  static const int defaultTTL = 5; // Time to live for messages
  static const int maxHopCount = 10; // Maximum relay hops
  static const int messageExpiryMinutes = 30; // Message cache expiry
  static const int discoveryInterval = 5000; // 5 seconds
  static const int connectionTimeout = 30000; // 30 seconds

  // Mesh Configuration
  static const String serviceId =
      'com.meshnet.offline'; // For nearby connections
  static const String strategy = 'P2P_CLUSTER'; // Connection strategy

  // Database
  static const String dbName = 'meshnet_db';
  static const String messagesBox = 'messages';
  static const String usersBox = 'users';
  static const String settingsBox = 'settings';
  static const String messageQueueBox = 'message_queue';

  // Encryption
  static const int encryptionKeyLength = 32; // AES-256
  static const String encryptionAlgorithm = 'AES';

  // Preferences Keys
  static const String keyUsername = 'username';
  static const String keyDeviceId = 'device_id';
  static const String keyEncryptionEnabled = 'encryption_enabled';
  static const String keyMeshRange = 'mesh_range';
  static const String keyTTLLimit = 'ttl_limit';
  static const String keyAutoConnect = 'auto_connect';

  // Message Status
  static const String statusPending = 'pending';
  static const String statusDelivered = 'delivered';
  static const String statusRelayed = 'relayed';
  static const String statusFailed = 'failed';

  // Connection Status
  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String connecting = 'connecting';

  // Emergency Messages
  static const List<String> emergencyTemplates = [
    'Need Help',
    'Medical Emergency',
    'Food Required',
    'Water Needed',
    'Rescue Required',
    'Safe Location',
  ];

  // Notification Channels
  static const String channelId = 'meshnet_notifications';
  static const String channelName = 'MeshNet Notifications';
  static const String channelDescription = 'Mesh network messages and alerts';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Distance Estimation (in meters)
  static const int signalStrengthVeryClose = -50;
  static const int signalStrengthClose = -70;
  static const int signalStrengthMedium = -85;
  static const int signalStrengthFar = -100;
}
