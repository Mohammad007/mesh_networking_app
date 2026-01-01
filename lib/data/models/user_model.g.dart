// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      deviceId: fields[2] as String,
      lastSeen: fields[3] as int?,
      status: fields[4] as String,
      signalStrength: fields[5] as int?,
      distance: fields[6] as double?,
      isTrusted: fields[7] as bool,
      publicKey: fields[8] as String?,
      connectedAt: fields[9] as int?,
      connectedNodes: (fields[10] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.deviceId)
      ..writeByte(3)
      ..write(obj.lastSeen)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.signalStrength)
      ..writeByte(6)
      ..write(obj.distance)
      ..writeByte(7)
      ..write(obj.isTrusted)
      ..writeByte(8)
      ..write(obj.publicKey)
      ..writeByte(9)
      ..write(obj.connectedAt)
      ..writeByte(10)
      ..write(obj.connectedNodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
