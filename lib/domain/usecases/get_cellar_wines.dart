import '../entities/cellar_wine.dart';
import '../repositories/cellar_repository.dart';

class GetCellarWines {
  final CellarRepository repository;

  GetCellarWines(this.repository);

  Future<List<CellarWine>> call() async {
    return repository.getCellarWines();
  }
}
