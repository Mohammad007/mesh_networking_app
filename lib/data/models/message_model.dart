import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String from;

  @HiveField(2)
  late String to;

  @HiveField(3)
  late String payload;

  @HiveField(4)
  late int ttl;

  @HiveField(5)
  late int hop;

  @HiveField(6)
  late int timestamp;

  @HiveField(7)
  late String status; // pending, delivered, relayed, failed

  @HiveField(8)
  String? signature;

  @HiveField(9)
  bool isEncrypted;

  @HiveField(10)
  bool isBroadcast;

  @HiveField(11)
  List<String>? relayPath; // Track which nodes relayed this message

  MessageModel({
    required this.id,
    required this.from,
    required this.to,
    required this.payload,
    required this.ttl,
    required this.hop,
    required this.timestamp,
    required this.status,
    this.signature,
    this.isEncrypted = false,
    this.isBroadcast = false,
    this.relayPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'msg_id': id,
      'from': from,
      'to': to,
      'payload': payload,
      'ttl': ttl,
      'hop': hop,
      'timestamp': timestamp,
      'status': status,
      'signature': signature,
      'is_encrypted': isEncrypted,
      'is_broadcast': isBroadcast,
      'relay_path': relayPath,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['msg_id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      payload: json['payload'] as String,
      ttl: json['ttl'] as int,
      hop: json['hop'] as int,
      timestamp: json['timestamp'] as int,
      status: json['status'] as String,
      signature: json['signature'] as String?,
      isEncrypted: json['is_encrypted'] as bool? ?? false,
      isBroadcast: json['is_broadcast'] as bool? ?? false,
      relayPath: (json['relay_path'] as List<dynamic>?)?.cast<String>(),
    );
  }

  MessageModel copyWith({
    String? id,
    String? from,
    String? to,
    String? payload,
    int? ttl,
    int? hop,
    int? timestamp,
    String? status,
    String? signature,
    bool? isEncrypted,
    bool? isBroadcast,
    List<String>? relayPath,
  }) {
    return MessageModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      payload: payload ?? this.payload,
      ttl: ttl ?? this.ttl,
      hop: hop ?? this.hop,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      signature: signature ?? this.signature,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isBroadcast: isBroadcast ?? this.isBroadcast,
      relayPath: relayPath ?? this.relayPath,
    );
  }
}
