// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 0;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      from: fields[1] as String,
      to: fields[2] as String,
      payload: fields[3] as String,
      ttl: fields[4] as int,
      hop: fields[5] as int,
      timestamp: fields[6] as int,
      status: fields[7] as String,
      signature: fields[8] as String?,
      isEncrypted: fields[9] as bool,
      isBroadcast: fields[10] as bool,
      relayPath: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.to)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.ttl)
      ..writeByte(5)
      ..write(obj.hop)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.signature)
      ..writeByte(9)
      ..write(obj.isEncrypted)
      ..writeByte(10)
      ..write(obj.isBroadcast)
      ..writeByte(11)
      ..write(obj.relayPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
