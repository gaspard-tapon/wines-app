import '../entities/cellar_wine.dart';
import '../entities/wine.dart';

abstract class CellarRepository {
  /// Récupère tous les vins de la cave
  Future<List<CellarWine>> getCellarWines();

  /// Récupère un vin de la cave par l'ID du vin
  Future<CellarWine?> getCellarWineById(int wineId);

  /// Ajoute un vin à la cave (stock initial = 1)
  Future<CellarWine> addWineToCellar(Wine wine);

  /// Supprime un vin de la cave
  Future<void> removeFromCellar(int wineId);

  /// Met à jour le stock d'un vin
  Future<CellarWine> updateStock(int wineId, int newStock);

  /// Incrémente le stock d'un vin
  Future<CellarWine> incrementStock(int wineId);

  /// Décrémente le stock d'un vin (minimum 0)
  Future<CellarWine> decrementStock(int wineId);

  /// Met à jour la note d'un vin (0-5)
  Future<CellarWine> updateRating(int wineId, int rating);

  /// Met à jour l'annotation d'un vin
  Future<CellarWine> updateAnnotation(int wineId, String? annotation);

  /// Vérifie si un vin est déjà dans la cave
  Future<bool> isInCellar(int wineId);
}
