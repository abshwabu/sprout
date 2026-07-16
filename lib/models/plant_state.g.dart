// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantStateAdapter extends TypeAdapter<PlantState> {
  @override
  final int typeId = 0;

  @override
  PlantState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantState(
      id: fields[0] as String,
      stage: fields[1] as int,
      totalWaters: fields[2] as int,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      lastWateredDate: fields[5] as DateTime?,
      plantedDate: fields[6] as DateTime,
      seasonNumber: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlantState obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stage)
      ..writeByte(2)
      ..write(obj.totalWaters)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.lastWateredDate)
      ..writeByte(6)
      ..write(obj.plantedDate)
      ..writeByte(7)
      ..write(obj.seasonNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
