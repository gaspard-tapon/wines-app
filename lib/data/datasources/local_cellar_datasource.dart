import 'package:hive/hive.dart';
import '../models/cellar_wine_model.dart';
import '../models/wine_model.dart';

class LocalCellarDataSource {
  static const String _boxName = 'cellar_wines';
  
  Box<CellarWineModel>? _box;

  Future<Box<CellarWineModel>> get box async {
    _box ??= await Hive.openBox<CellarWineModel>(_boxName);
    return _box!;
  }

  /// Récupère tous les vins de la cave
  Future<List<CellarWineModel>> getCellarWines() async {
    final cellarBox = await box;
    return cellarBox.values.toList();
  }

  /// Récupère un vin de la cave par l'ID du vin
  Future<CellarWineModel?> getCellarWineById(int wineId) async {
    final cellarBox = await box;
    try {
      return cellarBox.values.firstWhere((cw) => cw.wine.id == wineId);
    } catch (_) {
      return null;
    }
  }

  /// Ajoute un vin à la cave
  Future<CellarWineModel> addWineToCellar(WineModel wine) async {
    final cellarBox = await box;
    final cellarWine = CellarWineModel(
      wine: wine,
      stock: 1,
      rating: 0,
      annotation: null,
      addedAt: DateTime.now(),
    );
    await cellarBox.put(wine.id.toString(), cellarWine);
    return cellarWine;
  }

  /// Supprime un vin de la cave
  Future<void> removeFromCellar(int wineId) async {
    final cellarBox = await box;
    await cellarBox.delete(wineId.toString());
  }

  /// Met à jour un vin dans la cave
  Future<CellarWineModel> updateCellarWine(CellarWineModel cellarWine) async {
    final cellarBox = await box;
    await cellarBox.put(cellarWine.wine.id.toString(), cellarWine);
    return cellarWine;
  }

  /// Vérifie si un vin est dans la cave
  Future<bool> isInCellar(int wineId) async {
    final cellarBox = await box;
    return cellarBox.containsKey(wineId.toString());
  }

  /// Ferme la box (à appeler lors de la fermeture de l'app)
  Future<void> close() async {
    final cellarBox = await box;
    await cellarBox.close();
  }
}
