import '../entities/wine.dart';
import '../repositories/wine_repository.dart';

class GetAvailableWines {
  final WineRepository repository;

  GetAvailableWines(this.repository);

  Future<List<Wine>> call() async {
    return repository.getAvailableWines();
  }
}
