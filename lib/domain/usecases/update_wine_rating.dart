import '../entities/cellar_wine.dart';
import '../repositories/cellar_repository.dart';

class UpdateWineRating {
  final CellarRepository repository;

  UpdateWineRating(this.repository);

  /// Met à jour la note d'un vin (0-5 étoiles)
  Future<CellarWine> call(int wineId, int rating) async {
    // Valider la note (0-5)
    final validRating = rating.clamp(0, 5);
    return repository.updateRating(wineId, validRating);
  }
}
