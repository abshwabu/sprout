// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiddenMessageAdapter extends TypeAdapter<HiddenMessage> {
  @override
  final int typeId = 2;

  @override
  HiddenMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiddenMessage(
      stageRequired: fields[0] as int,
      seasonNumber: fields[1] as int,
      text: fields[2] as String,
      imagePath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiddenMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.stageRequired)
      ..writeByte(1)
      ..write(obj.seasonNumber)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiddenMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
