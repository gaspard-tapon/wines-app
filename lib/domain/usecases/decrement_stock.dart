import '../entities/cellar_wine.dart';
import '../repositories/cellar_repository.dart';

class DecrementStock {
  final CellarRepository repository;

  DecrementStock(this.repository);

  Future<CellarWine> call(int wineId) async {
    return repository.decrementStock(wineId);
  }
}
