import '../entities/wine.dart';

abstract class WineRepository {
  /// Récupère la liste de tous les vins disponibles depuis l'API
  Future<List<Wine>> getAvailableWines();

  /// Récupère un vin par son ID
  Future<Wine?> getWineById(int id);
}
