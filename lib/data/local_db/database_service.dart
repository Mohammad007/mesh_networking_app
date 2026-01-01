import 'package:hive_flutter/hive_flutter.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class DatabaseService {
  static Box<MessageModel>? _messagesBox;
  static Box<UserModel>? _usersBox;
  static Box<dynamic>? _settingsBox;
  static Box<MessageModel>? _messageQueueBox;

  /// Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open boxes
    _messagesBox = await Hive.openBox<MessageModel>(AppConstants.messagesBox);
    _usersBox = await Hive.openBox<UserModel>(AppConstants.usersBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _messageQueueBox = await Hive.openBox<MessageModel>(
      AppConstants.messageQueueBox,
    );
  }

  // Messages Operations

  /// Save a message
  static Future<void> saveMessage(MessageModel message) async {
    await _messagesBox?.put(message.id, message);
  }

  /// Get a message by ID
  static MessageModel? getMessage(String id) {
    return _messagesBox?.get(id);
  }

  /// Get all messages
  static List<MessageModel> getAllMessages() {
    return _messagesBox?.values.toList() ?? [];
  }

  /// Get messages for a specific user
  static List<MessageModel> getMessagesForUser(String userId) {
    return _messagesBox?.values
            .where((msg) => msg.from == userId || msg.to == userId)
            .toList() ??
        [];
  }

  /// Get messages by status
  static List<MessageModel> getMessagesByStatus(String status) {
    return _messagesBox?.values.where((msg) => msg.status == status).toList() ??
        [];
  }

  /// Delete a message
  static Future<void> deleteMessage(String id) async {
    await _messagesBox?.delete(id);
  }

  /// Clear all messages
  static Future<void> clearAllMessages() async {
    await _messagesBox?.clear();
  }

  /// Delete old messages (older than specified minutes)
  static Future<void> deleteOldMessages(int minutes) async {
    final cutoffTime = DateTime.now()
        .subtract(Duration(minutes: minutes))
        .millisecondsSinceEpoch;

    final messagesToDelete =
        _messagesBox?.values
            .where((msg) => msg.timestamp < cutoffTime)
            .map((msg) => msg.id)
            .toList() ??
        [];

    for (var id in messagesToDelete) {
      await _messagesBox?.delete(id);
    }
  }

  // Users Operations

  /// Save a user
  static Future<void> saveUser(UserModel user) async {
    await _usersBox?.put(user.id, user);
  }

  /// Get a user by ID
  static UserModel? getUser(String id) {
    return _usersBox?.get(id);
  }

  /// Get all users
  static List<UserModel> getAllUsers() {
    return _usersBox?.values.toList() ?? [];
  }

  /// Get trusted users
  static List<UserModel> getTrustedUsers() {
    return _usersBox?.values.where((user) => user.isTrusted).toList() ?? [];
  }

  /// Get nearby users
  static List<UserModel> getNearbyUsers() {
    return _usersBox?.values
            .where((user) => user.status == 'nearby' || user.status == 'online')
            .toList() ??
        [];
  }

  /// Update user status
  static Future<void> updateUserStatus(String userId, String status) async {
    final user = _usersBox?.get(userId);
    if (user != null) {
      user.status = status;
      user.lastSeen = DateTime.now().millisecondsSinceEpoch;
      await _usersBox?.put(userId, user);
    }
  }

  /// Delete a user
  static Future<void> deleteUser(String id) async {
    await _usersBox?.delete(id);
  }

  /// Clear all users
  static Future<void> clearAllUsers() async {
    await _usersBox?.clear();
  }

  // Message Queue Operations

  /// Add message to queue
  static Future<void> addToQueue(MessageModel message) async {
    await _messageQueueBox?.put(message.id, message);
  }

  /// Get all queued messages
  static List<MessageModel> getQueuedMessages() {
    return _messageQueueBox?.values.toList() ?? [];
  }

  /// Remove message from queue
  static Future<void> removeFromQueue(String id) async {
    await _messageQueueBox?.delete(id);
  }

  /// Clear message queue
  static Future<void> clearQueue() async {
    await _messageQueueBox?.clear();
  }

  // Settings Operations

  /// Save setting
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  /// Get setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue);
  }

  /// Delete setting
  static Future<void> deleteSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  /// Clear all settings
  static Future<void> clearSettings() async {
    await _settingsBox?.clear();
  }

  // Utility Methods

  /// Get database statistics
  static Map<String, int> getStatistics() {
    return {
      'total_messages': _messagesBox?.length ?? 0,
      'total_users': _usersBox?.length ?? 0,
      'queued_messages': _messageQueueBox?.length ?? 0,
      'total_settings': _settingsBox?.length ?? 0,
    };
  }

  /// Export all data
  static Future<Map<String, dynamic>> exportData() async {
    return {
      'messages': _messagesBox?.values.map((m) => m.toJson()).toList() ?? [],
      'users': _usersBox?.values.map((u) => u.toJson()).toList() ?? [],
      'settings': _settingsBox?.toMap() ?? {},
    };
  }

  /// Clear all data
  static Future<void> clearAllData() async {
    await clearAllMessages();
    await clearAllUsers();
    await clearQueue();
    await clearSettings();
  }

  /// Close databases
  static Future<void> close() async {
    await _messagesBox?.close();
    await _usersBox?.close();
    await _settingsBox?.close();
    await _messageQueueBox?.close();
  }

  /// Compact databases (optimize storage)
  static Future<void> compact() async {
    await _messagesBox?.compact();
    await _usersBox?.compact();
    await _settingsBox?.compact();
    await _messageQueueBox?.compact();
  }
}
