import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String deviceId;

  @HiveField(3)
  int? lastSeen;

  @HiveField(4)
  String status; // online, offline, nearby

  @HiveField(5)
  int? signalStrength;

  @HiveField(6)
  double? distance; // Estimated distance in meters

  @HiveField(7)
  bool isTrusted;

  @HiveField(8)
  String? publicKey;

  @HiveField(9)
  int? connectedAt;

  @HiveField(10)
  List<String>? connectedNodes; // IDs of nodes this user is connected to

  UserModel({
    required this.id,
    required this.username,
    required this.deviceId,
    this.lastSeen,
    this.status = 'offline',
    this.signalStrength,
    this.distance,
    this.isTrusted = false,
    this.publicKey,
    this.connectedAt,
    this.connectedNodes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'device_id': deviceId,
      'last_seen': lastSeen,
      'status': status,
      'signal_strength': signalStrength,
      'distance': distance,
      'is_trusted': isTrusted,
      'public_key': publicKey,
      'connected_at': connectedAt,
      'connected_nodes': connectedNodes,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      deviceId: json['device_id'] as String,
      lastSeen: json['last_seen'] as int?,
      status: json['status'] as String? ?? 'offline',
      signalStrength: json['signal_strength'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      isTrusted: json['is_trusted'] as bool? ?? false,
      publicKey: json['public_key'] as String?,
      connectedAt: json['connected_at'] as int?,
      connectedNodes: (json['connected_nodes'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? deviceId,
    int? lastSeen,
    String? status,
    int? signalStrength,
    double? distance,
    bool? isTrusted,
    String? publicKey,
    int? connectedAt,
    List<String>? connectedNodes,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      deviceId: deviceId ?? this.deviceId,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      distance: distance ?? this.distance,
      isTrusted: isTrusted ?? this.isTrusted,
      publicKey: publicKey ?? this.publicKey,
      connectedAt: connectedAt ?? this.connectedAt,
      connectedNodes: connectedNodes ?? this.connectedNodes,
    );
  }

  String get distanceText {
    if (distance == null) return 'Unknown';
    if (distance! < 10) return 'Very Close';
    if (distance! < 50) return '${distance!.toStringAsFixed(0)}m';
    if (distance! < 1000) return '${distance!.toStringAsFixed(0)}m';
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }

  String get statusColor {
    switch (status) {
      case 'online':
        return '0xFF00E676'; // Green
      case 'nearby':
        return '0xFF00E5FF'; // Cyan
      case 'offline':
      default:
        return '0xFF78909C'; // Gray
    }
  }
}
