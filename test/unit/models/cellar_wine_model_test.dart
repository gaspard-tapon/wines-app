import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/data/models/cellar_wine_model.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import '../../helpers/test_data.dart';

void main() {
  group('CellarWineModel', () {
    // =========================================================================
    // CREATION TESTS
    // =========================================================================

    group('création', () {
      test('devrait créer un CellarWineModel avec toutes les propriétés', () {
        // ARRANGE
        final wineModel = TestData.createWineModel();
        const stock = 5;
        const rating = 4;
        const annotation = 'Excellent vin';
        final addedAt = DateTime(2024, 1, 15);

        // ACT
        final model = CellarWineModel(
          wine: wineModel,
          stock: stock,
          rating: rating,
          annotation: annotation,
          addedAt: addedAt,
        );

        // ASSERT
        expect(model.wine, equals(wineModel));
        expect(model.stock, equals(stock));
        expect(model.rating, equals(rating));
        expect(model.annotation, equals(annotation));
        expect(model.addedAt, equals(addedAt));
      });

      test('devrait utiliser rating = 0 par défaut', () {
        // ARRANGE
        final wineModel = TestData.createWineModel();

        // ACT
        final model = CellarWineModel(
          wine: wineModel,
          stock: 1,
          addedAt: DateTime.now(),
        );

        // ASSERT
        expect(model.rating, equals(0));
      });

      test('devrait permettre annotation null', () {
        // ARRANGE
        final wineModel = TestData.createWineModel();

        // ACT
        final model = CellarWineModel(
          wine: wineModel,
          stock: 1,
          addedAt: DateTime.now(),
          annotation: null,
        );

        // ASSERT
        expect(model.annotation, isNull);
      });
    });

    // =========================================================================
    // FROMENTITY TESTS
    // =========================================================================

    group('fromEntity', () {
      test('devrait créer un CellarWineModel à partir d\'une entité', () {
        // ARRANGE
        final entity = TestData.cellarWineRouge;

        // ACT
        final model = CellarWineModel.fromEntity(entity);

        // ASSERT
        expect(model.wine.id, equals(entity.wine.id));
        expect(model.stock, equals(entity.stock));
        expect(model.rating, equals(entity.rating));
        expect(model.annotation, equals(entity.annotation));
        expect(model.addedAt, equals(entity.addedAt));
      });

      test('devrait préserver une annotation null', () {
        // ARRANGE
        final entity = TestData.cellarWineBlanc; // annotation null

        // ACT
        final model = CellarWineModel.fromEntity(entity);

        // ASSERT
        expect(model.annotation, isNull);
      });
    });

    // =========================================================================
    // TOENTITY TESTS
    // =========================================================================

    group('toEntity', () {
      test('devrait convertir un CellarWineModel en entité', () {
        // ARRANGE
        final model = TestData.createCellarWineModel(
          stock: 5,
          rating: 4,
          annotation: 'Super',
        );

        // ACT
        final entity = model.toEntity();

        // ASSERT
        expect(entity, isA<CellarWine>());
        expect(entity.wine.id, equals(model.wine.id));
        expect(entity.stock, equals(model.stock));
        expect(entity.rating, equals(model.rating));
        expect(entity.annotation, equals(model.annotation));
        expect(entity.addedAt, equals(model.addedAt));
      });
    });

    // =========================================================================
    // COPYWITH TESTS
    // =========================================================================

    group('copyWith', () {
      test('devrait créer une copie identique sans paramètres', () {
        // ARRANGE
        final original = TestData.createCellarWineModel();

        // ACT
        final copy = original.copyWith();

        // ASSERT
        expect(copy.wine.id, equals(original.wine.id));
        expect(copy.stock, equals(original.stock));
        expect(copy.rating, equals(original.rating));
        expect(copy.annotation, equals(original.annotation));
        expect(copy.addedAt, equals(original.addedAt));
      });

      test('devrait modifier le stock uniquement', () {
        // ARRANGE
        final original = TestData.createCellarWineModel(stock: 5);

        // ACT
        final copy = original.copyWith(stock: 10);

        // ASSERT
        expect(copy.stock, equals(10));
        expect(copy.rating, equals(original.rating));
        expect(copy.annotation, equals(original.annotation));
      });

      test('devrait modifier le rating uniquement', () {
        // ARRANGE
        final original = TestData.createCellarWineModel(rating: 3);

        // ACT
        final copy = original.copyWith(rating: 5);

        // ASSERT
        expect(copy.rating, equals(5));
        expect(copy.stock, equals(original.stock));
      });

      test('devrait modifier plusieurs propriétés', () {
        // ARRANGE
        final original = TestData.createCellarWineModel();

        // ACT
        final copy = original.copyWith(
          stock: 20,
          rating: 5,
          annotation: 'Nouvelle annotation',
        );

        // ASSERT
        expect(copy.stock, equals(20));
        expect(copy.rating, equals(5));
        expect(copy.annotation, equals('Nouvelle annotation'));
      });
    });

    // =========================================================================
    // WITHANNOTATION TESTS
    // =========================================================================

    group('withAnnotation', () {
      test('devrait mettre à jour l\'annotation avec une nouvelle valeur', () {
        // ARRANGE
        final original = TestData.createCellarWineModel(annotation: 'Ancienne');

        // ACT
        final updated = original.withAnnotation('Nouvelle');

        // ASSERT
        expect(updated.annotation, equals('Nouvelle'));
        expect(updated.stock, equals(original.stock));
        expect(updated.rating, equals(original.rating));
      });

      test('devrait permettre de supprimer l\'annotation avec null', () {
        // ARRANGE
        final original = TestData.createCellarWineModel(annotation: 'Annotation');

        // ACT
        final updated = original.withAnnotation(null);

        // ASSERT
        expect(updated.annotation, isNull);
      });

      test('devrait créer une nouvelle instance', () {
        // ARRANGE
        final original = TestData.createCellarWineModel(annotation: 'Original');

        // ACT
        final updated = original.withAnnotation('Modifiée');

        // ASSERT
        expect(original.annotation, equals('Original'));
        expect(updated.annotation, equals('Modifiée'));
      });
    });

    // =========================================================================
    // ROUNDTRIP TESTS
    // =========================================================================

    group('conversion aller-retour', () {
      test('Entity -> Model -> Entity devrait préserver toutes les données', () {
        // ARRANGE
        final originalEntity = TestData.cellarWineRouge;

        // ACT
        final model = CellarWineModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        // ASSERT
        expect(convertedEntity.wine.id, equals(originalEntity.wine.id));
        expect(convertedEntity.stock, equals(originalEntity.stock));
        expect(convertedEntity.rating, equals(originalEntity.rating));
        expect(convertedEntity.annotation, equals(originalEntity.annotation));
        expect(convertedEntity.addedAt, equals(originalEntity.addedAt));
      });
    });
  });
}
