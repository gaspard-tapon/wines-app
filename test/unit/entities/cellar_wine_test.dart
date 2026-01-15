import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import '../../helpers/test_data.dart';

void main() {
  group('CellarWine Entity', () {
    // =========================================================================
    // CREATION TESTS
    // =========================================================================

    group('création', () {
      test('devrait créer un CellarWine avec toutes les propriétés', () {
        // ARRANGE
        final wine = TestData.wineRouge;
        const stock = 5;
        const rating = 4;
        const annotation = 'Mon vin préféré';
        final addedAt = DateTime(2024, 1, 15);

        // ACT
        final cellarWine = CellarWine(
          wine: wine,
          stock: stock,
          rating: rating,
          annotation: annotation,
          addedAt: addedAt,
        );

        // ASSERT
        expect(cellarWine.wine, equals(wine));
        expect(cellarWine.stock, equals(stock));
        expect(cellarWine.rating, equals(rating));
        expect(cellarWine.annotation, equals(annotation));
        expect(cellarWine.addedAt, equals(addedAt));
      });

      test('devrait utiliser rating = 0 par défaut', () {
        // ARRANGE
        final wine = TestData.wineRouge;

        // ACT
        final cellarWine = CellarWine(
          wine: wine,
          stock: 1,
          addedAt: DateTime.now(),
        );

        // ASSERT
        expect(cellarWine.rating, equals(0));
      });

      test('devrait permettre annotation null', () {
        // ARRANGE
        final wine = TestData.wineRouge;

        // ACT
        final cellarWine = CellarWine(
          wine: wine,
          stock: 1,
          addedAt: DateTime.now(),
          annotation: null,
        );

        // ASSERT
        expect(cellarWine.annotation, isNull);
      });
    });

    // =========================================================================
    // COPYWITH TESTS
    // =========================================================================

    group('copyWith', () {
      test('devrait créer une copie identique sans paramètres', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;

        // ACT
        final copy = original.copyWith();

        // ASSERT
        expect(copy.wine, equals(original.wine));
        expect(copy.stock, equals(original.stock));
        expect(copy.rating, equals(original.rating));
        expect(copy.annotation, equals(original.annotation));
        expect(copy.addedAt, equals(original.addedAt));
      });

      test('devrait modifier le stock uniquement', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;
        const nouveauStock = 10;

        // ACT
        final copy = original.copyWith(stock: nouveauStock);

        // ASSERT
        expect(copy.stock, equals(nouveauStock));
        expect(copy.wine, equals(original.wine));
        expect(copy.rating, equals(original.rating));
      });

      test('devrait modifier le rating uniquement', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;
        const nouveauRating = 5;

        // ACT
        final copy = original.copyWith(rating: nouveauRating);

        // ASSERT
        expect(copy.rating, equals(nouveauRating));
        expect(copy.stock, equals(original.stock));
      });

      test('devrait modifier plusieurs propriétés', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;
        const nouveauStock = 8;
        const nouveauRating = 3;
        const nouvelleAnnotation = 'Nouvelle note';

        // ACT
        final copy = original.copyWith(
          stock: nouveauStock,
          rating: nouveauRating,
          annotation: nouvelleAnnotation,
        );

        // ASSERT
        expect(copy.stock, equals(nouveauStock));
        expect(copy.rating, equals(nouveauRating));
        expect(copy.annotation, equals(nouvelleAnnotation));
      });
    });

    // =========================================================================
    // WITHANNOTATION TESTS
    // =========================================================================

    group('withAnnotation', () {
      test('devrait mettre à jour l\'annotation avec une nouvelle valeur', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;
        const nouvelleAnnotation = 'Nouvelle annotation';

        // ACT
        final updated = original.withAnnotation(nouvelleAnnotation);

        // ASSERT
        expect(updated.annotation, equals(nouvelleAnnotation));
        expect(updated.wine, equals(original.wine));
        expect(updated.stock, equals(original.stock));
        expect(updated.rating, equals(original.rating));
      });

      test('devrait permettre de supprimer l\'annotation en passant null', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;

        // ACT
        final updated = original.withAnnotation(null);

        // ASSERT
        expect(updated.annotation, isNull);
      });

      test('devrait créer une nouvelle instance sans modifier l\'originale', () {
        // ARRANGE
        final original = TestData.cellarWineRouge;
        final originalAnnotation = original.annotation;

        // ACT
        final updated = original.withAnnotation('Autre annotation');

        // ASSERT
        expect(original.annotation, equals(originalAnnotation));
        expect(updated.annotation, equals('Autre annotation'));
      });
    });

    // =========================================================================
    // EQUALITY TESTS
    // =========================================================================

    group('égalité', () {
      test('deux CellarWine avec le même wine.id devraient être égaux', () {
        // ARRANGE
        final cellarWine1 = TestData.createCellarWine(
          wine: TestData.createWine(id: 1),
          stock: 5,
        );
        final cellarWine2 = TestData.createCellarWine(
          wine: TestData.createWine(id: 1),
          stock: 10,
        );

        // ACT & ASSERT
        expect(cellarWine1 == cellarWine2, isTrue);
      });

      test('deux CellarWine avec des wine.id différents ne devraient pas être égaux', () {
        // ARRANGE
        final cellarWine1 = TestData.createCellarWine(
          wine: TestData.createWine(id: 1),
        );
        final cellarWine2 = TestData.createCellarWine(
          wine: TestData.createWine(id: 2),
        );

        // ACT & ASSERT
        expect(cellarWine1 == cellarWine2, isFalse);
      });

      test('hashCode devrait être basé sur wine.id', () {
        // ARRANGE
        final cellarWine1 = TestData.createCellarWine(
          wine: TestData.createWine(id: 1),
        );
        final cellarWine2 = TestData.createCellarWine(
          wine: TestData.createWine(id: 1),
        );

        // ACT & ASSERT
        expect(cellarWine1.hashCode, equals(cellarWine2.hashCode));
      });
    });
  });
}
