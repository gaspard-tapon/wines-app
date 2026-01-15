import 'wine.dart';

class CellarWine {
  final Wine wine;
  final int stock;
  final int rating; // 0-5 étoiles
  final String? annotation;
  final DateTime addedAt;

  const CellarWine({
    required this.wine,
    required this.stock,
    this.rating = 0,
    this.annotation,
    required this.addedAt,
  });

  CellarWine copyWith({
    Wine? wine,
    int? stock,
    int? rating,
    String? annotation,
    DateTime? addedAt,
  }) {
    return CellarWine(
      wine: wine ?? this.wine,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      annotation: annotation ?? this.annotation,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Permet de supprimer l'annotation (la mettre à null)
  CellarWine withAnnotation(String? newAnnotation) {
    return CellarWine(
      wine: wine,
      stock: stock,
      rating: rating,
      annotation: newAnnotation,
      addedAt: addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CellarWine && other.wine.id == wine.id;
  }

  @override
  int get hashCode => wine.id.hashCode;
}
