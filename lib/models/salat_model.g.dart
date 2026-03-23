// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalatModelAdapter extends TypeAdapter<SalatModel> {
  @override
  final int typeId = 0;

  @override
  SalatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalatModel(
      id: fields[0] as int,
      arabic: fields[1] as String,
      bab: fields[2] as String,
      juz: fields[3] as int,
      page: fields[4] as int,
      type: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalatModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.arabic)
      ..writeByte(2)
      ..write(obj.bab)
      ..writeByte(3)
      ..write(obj.juz)
      ..writeByte(4)
      ..write(obj.page)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
