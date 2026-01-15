import 'package:hive/hive.dart';
import '../../domain/entities/wine.dart';

part 'wine_model.g.dart';

@HiveType(typeId: 0)
class WineModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final String appellation;

  @HiveField(3)
  final String region;

  @HiveField(4)
  final String cepage;

  @HiveField(5)
  final int? millesime;

  @HiveField(6)
  final String couleur;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final String producteur;

  @HiveField(9)
  final double degreAlcool;

  @HiveField(10)
  final String image;

  WineModel({
    required this.id,
    required this.nom,
    required this.appellation,
    required this.region,
    required this.cepage,
    this.millesime,
    required this.couleur,
    required this.description,
    required this.producteur,
    required this.degreAlcool,
    required this.image,
  });

  factory WineModel.fromJson(Map<String, dynamic> json) {
    return WineModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      appellation: json['appellation'] as String,
      region: json['region'] as String,
      cepage: json['cepage'] as String,
      millesime: json['millesime'] as int?,
      couleur: json['couleur'] as String,
      description: json['description'] as String,
      producteur: json['producteur'] as String,
      degreAlcool: (json['degre_alcool'] as num).toDouble(),
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'appellation': appellation,
      'region': region,
      'cepage': cepage,
      'millesime': millesime,
      'couleur': couleur,
      'description': description,
      'producteur': producteur,
      'degre_alcool': degreAlcool,
      'image': image,
    };
  }

  factory WineModel.fromEntity(Wine wine) {
    return WineModel(
      id: wine.id,
      nom: wine.nom,
      appellation: wine.appellation,
      region: wine.region,
      cepage: wine.cepage,
      millesime: wine.millesime,
      couleur: wine.couleur,
      description: wine.description,
      producteur: wine.producteur,
      degreAlcool: wine.degreAlcool,
      image: wine.image,
    );
  }

  Wine toEntity() {
    return Wine(
      id: id,
      nom: nom,
      appellation: appellation,
      region: region,
      cepage: cepage,
      millesime: millesime,
      couleur: couleur,
      description: description,
      producteur: producteur,
      degreAlcool: degreAlcool,
      image: image,
    );
  }
}
