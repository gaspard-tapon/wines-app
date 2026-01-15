import '../../domain/entities/cellar_wine.dart';
import '../../domain/entities/wine.dart';
import '../../domain/repositories/cellar_repository.dart';
import '../datasources/local_cellar_datasource.dart';
import '../models/wine_model.dart';

class CellarRepositoryImpl implements CellarRepository {
  final LocalCellarDataSource localDataSource;

  CellarRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CellarWine>> getCellarWines() async {
    final models = await localDataSource.getCellarWines();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CellarWine?> getCellarWineById(int wineId) async {
    final model = await localDataSource.getCellarWineById(wineId);
    return model?.toEntity();
  }

  @override
  Future<CellarWine> addWineToCellar(Wine wine) async {
    final wineModel = WineModel.fromEntity(wine);
    final cellarWineModel = await localDataSource.addWineToCellar(wineModel);
    return cellarWineModel.toEntity();
  }

  @override
  Future<void> removeFromCellar(int wineId) async {
    await localDataSource.removeFromCellar(wineId);
  }

  @override
  Future<CellarWine> updateStock(int wineId, int newStock) async {
    final existing = await localDataSource.getCellarWineById(wineId);
    if (existing == null) {
      throw Exception('Vin non trouvé dans la cave');
    }
    final updated = existing.copyWith(stock: newStock.clamp(0, 9999));
    final result = await localDataSource.updateCellarWine(updated);
    return result.toEntity();
  }

  @override
  Future<CellarWine> incrementStock(int wineId) async {
    final existing = await localDataSource.getCellarWineById(wineId);
    if (existing == null) {
      throw Exception('Vin non trouvé dans la cave');
    }
    final updated = existing.copyWith(stock: existing.stock + 1);
    final result = await localDataSource.updateCellarWine(updated);
    return result.toEntity();
  }

  @override
  Future<CellarWine> decrementStock(int wineId) async {
    final existing = await localDataSource.getCellarWineById(wineId);
    if (existing == null) {
      throw Exception('Vin non trouvé dans la cave');
    }
    final newStock = (existing.stock - 1).clamp(0, 9999);
    final updated = existing.copyWith(stock: newStock);
    final result = await localDataSource.updateCellarWine(updated);
    return result.toEntity();
  }

  @override
  Future<CellarWine> updateRating(int wineId, int rating) async {
    final existing = await localDataSource.getCellarWineById(wineId);
    if (existing == null) {
      throw Exception('Vin non trouvé dans la cave');
    }
    final updated = existing.copyWith(rating: rating.clamp(0, 5));
    final result = await localDataSource.updateCellarWine(updated);
    return result.toEntity();
  }

  @override
  Future<CellarWine> updateAnnotation(int wineId, String? annotation) async {
    final existing = await localDataSource.getCellarWineById(wineId);
    if (existing == null) {
      throw Exception('Vin non trouvé dans la cave');
    }
    final updated = existing.withAnnotation(annotation);
    final result = await localDataSource.updateCellarWine(updated);
    return result.toEntity();
  }

  @override
  Future<bool> isInCellar(int wineId) async {
    return localDataSource.isInCellar(wineId);
  }
}
