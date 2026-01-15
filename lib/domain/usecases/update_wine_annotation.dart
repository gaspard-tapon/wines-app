import '../entities/cellar_wine.dart';
import '../repositories/cellar_repository.dart';

class UpdateWineAnnotation {
  final CellarRepository repository;

  UpdateWineAnnotation(this.repository);

  /// Met à jour l'annotation d'un vin
  /// Passer null pour supprimer l'annotation
  Future<CellarWine> call(int wineId, String? annotation) async {
    // Nettoyer l'annotation (trim et null si vide)
    final cleanedAnnotation =
        annotation?.trim().isEmpty == true ? null : annotation?.trim();
    return repository.updateAnnotation(wineId, cleanedAnnotation);
  }
}
