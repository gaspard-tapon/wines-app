import '../entities/cellar_wine.dart';
import '../entities/wine.dart';
import '../repositories/cellar_repository.dart';

class AddWineToCellar {
  final CellarRepository repository;

  AddWineToCellar(this.repository);

  Future<CellarWine> call(Wine wine) async {
    // Vérifier si le vin est déjà dans la cave
    final isInCellar = await repository.isInCellar(wine.id);
    if (isInCellar) {
      // Si déjà présent, incrémenter le stock
      return repository.incrementStock(wine.id);
    }
    // Sinon, ajouter le vin à la cave
    return repository.addWineToCellar(wine);
  }
}
