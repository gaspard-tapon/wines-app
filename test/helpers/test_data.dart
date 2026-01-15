/// Fichier contenant les données de test réutilisables
/// Ces fixtures permettent d'avoir des données cohérentes dans tous les tests
library;

import 'package:wines_app/domain/entities/wine.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import 'package:wines_app/data/models/wine_model.dart';
import 'package:wines_app/data/models/cellar_wine_model.dart';

/// Classe contenant toutes les données de test
class TestData {
  // ==========================================================================
  // WINE ENTITIES
  // ==========================================================================
  
  static Wine createWine({
    int id = 1,
    String nom = 'Château Margaux',
    String appellation = 'Margaux',
    String region = 'Bordeaux',
    String cepage = 'Cabernet Sauvignon, Merlot',
    int? millesime = 2018,
    String couleur = 'Rouge',
    String description = 'Un vin exceptionnel',
    String producteur = 'Château Margaux',
    double degreAlcool = 13.5,
    String image = 'https://example.com/wine.jpg',
  }) {
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

  static Wine get wineRouge => createWine(
    id: 1,
    nom: 'Château Margaux',
    couleur: 'Rouge',
    region: 'Bordeaux',
    millesime: 2018,
  );

  static Wine get wineBlanc => createWine(
    id: 2,
    nom: 'Puligny-Montrachet',
    couleur: 'Blanc',
    cepage: 'Chardonnay',
    region: 'Bourgogne',
    millesime: 2020,
  );

  static Wine get wineRose => createWine(
    id: 3,
    nom: 'Côtes de Provence',
    couleur: 'Rosé',
    cepage: 'Grenache, Cinsault',
    region: 'Provence',
    millesime: 2022,
  );

  static Wine get wineSansMillesime => createWine(
    id: 4,
    nom: 'Champagne Brut',
    couleur: 'Blanc',
    millesime: null,
    region: 'Champagne',
  );

  static List<Wine> get wineList => [
    wineRouge,
    wineBlanc,
    wineRose,
    wineSansMillesime,
  ];

  // ==========================================================================
  // CELLAR WINE ENTITIES
  // ==========================================================================

  static CellarWine createCellarWine({
    Wine? wine,
    int stock = 3,
    int rating = 4,
    String? annotation = 'Excellent pour les grandes occasions',
    DateTime? addedAt,
  }) {
    return CellarWine(
      wine: wine ?? wineRouge,
      stock: stock,
      rating: rating,
      annotation: annotation,
      addedAt: addedAt ?? DateTime(2024, 1, 15),
    );
  }

  static CellarWine get cellarWineRouge => createCellarWine(
    wine: wineRouge,
    stock: 5,
    rating: 5,
    annotation: 'Mon préféré',
    addedAt: DateTime(2024, 1, 10),
  );

  static CellarWine get cellarWineBlanc => createCellarWine(
    wine: wineBlanc,
    stock: 2,
    rating: 4,
    annotation: null,
    addedAt: DateTime(2024, 2, 15),
  );

  static CellarWine get cellarWineRose => createCellarWine(
    wine: wineRose,
    stock: 0,
    rating: 3,
    annotation: 'Stock épuisé',
    addedAt: DateTime(2024, 3, 20),
  );

  static CellarWine get cellarWineNonNote => createCellarWine(
    wine: wineSansMillesime,
    stock: 10,
    rating: 0,
    annotation: null,
    addedAt: DateTime(2024, 4, 1),
  );

  static List<CellarWine> get cellarWineList => [
    cellarWineRouge,
    cellarWineBlanc,
    cellarWineRose,
    cellarWineNonNote,
  ];

  // ==========================================================================
  // WINE MODELS
  // ==========================================================================

  static WineModel createWineModel({
    int id = 1,
    String nom = 'Château Margaux',
    String appellation = 'Margaux',
    String region = 'Bordeaux',
    String cepage = 'Cabernet Sauvignon, Merlot',
    int? millesime = 2018,
    String couleur = 'Rouge',
    String description = 'Un vin exceptionnel',
    String producteur = 'Château Margaux',
    double degreAlcool = 13.5,
    String image = 'https://example.com/wine.jpg',
  }) {
    return WineModel(
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

  static Map<String, dynamic> get wineJson => {
    'id': 1,
    'nom': 'Château Margaux',
    'appellation': 'Margaux',
    'region': 'Bordeaux',
    'cepage': 'Cabernet Sauvignon, Merlot',
    'millesime': 2018,
    'couleur': 'Rouge',
    'description': 'Un vin exceptionnel',
    'producteur': 'Château Margaux',
    'degre_alcool': 13.5,
    'image': 'https://example.com/wine.jpg',
  };

  static Map<String, dynamic> get wineJsonSansMillesime => {
    'id': 2,
    'nom': 'Champagne Brut',
    'appellation': 'Champagne',
    'region': 'Champagne',
    'cepage': 'Chardonnay, Pinot Noir',
    'millesime': null,
    'couleur': 'Blanc',
    'description': 'Un champagne raffiné',
    'producteur': 'Maison de Champagne',
    'degre_alcool': 12.0,
    'image': 'https://example.com/champagne.jpg',
  };

  // ==========================================================================
  // CELLAR WINE MODELS
  // ==========================================================================

  static CellarWineModel createCellarWineModel({
    WineModel? wine,
    int stock = 3,
    int rating = 4,
    String? annotation = 'Excellent',
    DateTime? addedAt,
  }) {
    return CellarWineModel(
      wine: wine ?? createWineModel(),
      stock: stock,
      rating: rating,
      annotation: annotation,
      addedAt: addedAt ?? DateTime(2024, 1, 15),
    );
  }
}
