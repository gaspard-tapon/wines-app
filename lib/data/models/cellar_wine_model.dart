import 'package:hive/hive.dart';
import '../../domain/entities/cellar_wine.dart';
import 'wine_model.dart';

part 'cellar_wine_model.g.dart';

@HiveType(typeId: 1)
class CellarWineModel extends HiveObject {
  @HiveField(0)
  final WineModel wine;

  @HiveField(1)
  final int stock;

  @HiveField(2)
  final int rating;

  @HiveField(3)
  final String? annotation;

  @HiveField(4)
  final DateTime addedAt;

  CellarWineModel({
    required this.wine,
    required this.stock,
    this.rating = 0,
    this.annotation,
    required this.addedAt,
  });

  factory CellarWineModel.fromEntity(CellarWine cellarWine) {
    return CellarWineModel(
      wine: WineModel.fromEntity(cellarWine.wine),
      stock: cellarWine.stock,
      rating: cellarWine.rating,
      annotation: cellarWine.annotation,
      addedAt: cellarWine.addedAt,
    );
  }

  CellarWine toEntity() {
    return CellarWine(
      wine: wine.toEntity(),
      stock: stock,
      rating: rating,
      annotation: annotation,
      addedAt: addedAt,
    );
  }

  CellarWineModel copyWith({
    WineModel? wine,
    int? stock,
    int? rating,
    String? annotation,
    DateTime? addedAt,
  }) {
    return CellarWineModel(
      wine: wine ?? this.wine,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      annotation: annotation ?? this.annotation,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Pour mettre à null l'annotation
  CellarWineModel withAnnotation(String? newAnnotation) {
    return CellarWineModel(
      wine: wine,
      stock: stock,
      rating: rating,
      annotation: newAnnotation,
      addedAt: addedAt,
    );
  }
}
