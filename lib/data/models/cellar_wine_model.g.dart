// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cellar_wine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CellarWineModelAdapter extends TypeAdapter<CellarWineModel> {
  @override
  final int typeId = 1;

  @override
  CellarWineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CellarWineModel(
      wine: fields[0] as WineModel,
      stock: fields[1] as int,
      rating: fields[2] as int,
      annotation: fields[3] as String?,
      addedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CellarWineModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.wine)
      ..writeByte(1)
      ..write(obj.stock)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.annotation)
      ..writeByte(4)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellarWineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
