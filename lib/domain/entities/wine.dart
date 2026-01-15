class Wine {
  final int id;
  final String nom;
  final String appellation;
  final String region;
  final String cepage;
  final int? millesime;
  final String couleur;
  final String description;
  final String producteur;
  final double degreAlcool;
  final String image;

  const Wine({
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

  Wine copyWith({
    int? id,
    String? nom,
    String? appellation,
    String? region,
    String? cepage,
    int? millesime,
    String? couleur,
    String? description,
    String? producteur,
    double? degreAlcool,
    String? image,
  }) {
    return Wine(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      appellation: appellation ?? this.appellation,
      region: region ?? this.region,
      cepage: cepage ?? this.cepage,
      millesime: millesime ?? this.millesime,
      couleur: couleur ?? this.couleur,
      description: description ?? this.description,
      producteur: producteur ?? this.producteur,
      degreAlcool: degreAlcool ?? this.degreAlcool,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
