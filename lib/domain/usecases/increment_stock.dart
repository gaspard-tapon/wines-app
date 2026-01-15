import '../entities/cellar_wine.dart';
import '../repositories/cellar_repository.dart';

class IncrementStock {
  final CellarRepository repository;

  IncrementStock(this.repository);

  Future<CellarWine> call(int wineId) async {
    return repository.incrementStock(wineId);
  }
}
