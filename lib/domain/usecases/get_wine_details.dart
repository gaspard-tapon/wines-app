import '../entities/cellar_wine.dart';
import '../repositories/cellar_repository.dart';

class GetWineDetails {
  final CellarRepository repository;

  GetWineDetails(this.repository);

  Future<CellarWine?> call(int wineId) async {
    return repository.getCellarWineById(wineId);
  }
}
