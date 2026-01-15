// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WineModelAdapter extends TypeAdapter<WineModel> {
  @override
  final int typeId = 0;

  @override
  WineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WineModel(
      id: fields[0] as int,
      nom: fields[1] as String,
      appellation: fields[2] as String,
      region: fields[3] as String,
      cepage: fields[4] as String,
      millesime: fields[5] as int?,
      couleur: fields[6] as String,
      description: fields[7] as String,
      producteur: fields[8] as String,
      degreAlcool: fields[9] as double,
      image: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WineModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.appellation)
      ..writeByte(3)
      ..write(obj.region)
      ..writeByte(4)
      ..write(obj.cepage)
      ..writeByte(5)
      ..write(obj.millesime)
      ..writeByte(6)
      ..write(obj.couleur)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.producteur)
      ..writeByte(9)
      ..write(obj.degreAlcool)
      ..writeByte(10)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
