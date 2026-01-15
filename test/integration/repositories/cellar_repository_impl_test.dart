import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/data/models/cellar_wine_model.dart';
import 'package:wines_app/data/models/wine_model.dart';
import 'package:wines_app/data/repositories/cellar_repository_impl.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockLocalCellarDataSource mockDataSource;
  late CellarRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockDataSource = MockLocalCellarDataSource();
    repository = CellarRepositoryImpl(localDataSource: mockDataSource);
  });

  group('CellarRepositoryImpl', () {
    // =========================================================================
    // GET CELLAR WINES TESTS
    // =========================================================================

    group('getCellarWines', () {
      test('devrait retourner une liste de CellarWine depuis le datasource', () async {
        // ARRANGE
        final models = [
          TestData.createCellarWineModel(stock: 5),
          TestData.createCellarWineModel(
            wine: TestData.createWineModel(id: 2, nom: 'Autre Vin'),
            stock: 3,
          ),
        ];
        when(() => mockDataSource.getCellarWines())
            .thenAnswer((_) async => models);

        // ACT
        final result = await repository.getCellarWines();

        // ASSERT
        expect(result, isA<List<CellarWine>>());
        expect(result.length, equals(2));
        verify(() => mockDataSource.getCellarWines()).called(1);
      });

      test('devrait retourner une liste vide si pas de vins', () async {
        // ARRANGE
        when(() => mockDataSource.getCellarWines())
            .thenAnswer((_) async => []);

        // ACT
        final result = await repository.getCellarWines();

        // ASSERT
        expect(result, isEmpty);
      });

      test('devrait convertir correctement les models en entities', () async {
        // ARRANGE
        final model = TestData.createCellarWineModel(
          stock: 7,
          rating: 4,
          annotation: 'Test annotation',
        );
        when(() => mockDataSource.getCellarWines())
            .thenAnswer((_) async => [model]);

        // ACT
        final result = await repository.getCellarWines();

        // ASSERT
        expect(result.first.stock, equals(7));
        expect(result.first.rating, equals(4));
        expect(result.first.annotation, equals('Test annotation'));
      });
    });

    // =========================================================================
    // GET CELLAR WINE BY ID TESTS
    // =========================================================================

    group('getCellarWineById', () {
      test('devrait retourner un CellarWine si trouvé', () async {
        // ARRANGE
        const wineId = 1;
        final model = TestData.createCellarWineModel();
        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => model);

        // ACT
        final result = await repository.getCellarWineById(wineId);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.wine.id, equals(wineId));
        verify(() => mockDataSource.getCellarWineById(wineId)).called(1);
      });

      test('devrait retourner null si non trouvé', () async {
        // ARRANGE
        const wineId = 999;
        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => null);

        // ACT
        final result = await repository.getCellarWineById(wineId);

        // ASSERT
        expect(result, isNull);
      });
    });

    // =========================================================================
    // ADD WINE TO CELLAR TESTS
    // =========================================================================

    group('addWineToCellar', () {
      test('devrait ajouter un vin et retourner le CellarWine créé', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        final wineModel = WineModel.fromEntity(wine);
        final cellarWineModel = CellarWineModel(
          wine: wineModel,
          stock: 1,
          rating: 0,
          addedAt: DateTime.now(),
        );
        when(() => mockDataSource.addWineToCellar(any()))
            .thenAnswer((_) async => cellarWineModel);

        // ACT
        final result = await repository.addWineToCellar(wine);

        // ASSERT
        expect(result, isA<CellarWine>());
        expect(result.wine.id, equals(wine.id));
        expect(result.stock, equals(1));
        verify(() => mockDataSource.addWineToCellar(any())).called(1);
      });
    });

    // =========================================================================
    // REMOVE FROM CELLAR TESTS
    // =========================================================================

    group('removeFromCellar', () {
      test('devrait appeler le datasource pour supprimer', () async {
        // ARRANGE
        const wineId = 1;
        when(() => mockDataSource.removeFromCellar(wineId))
            .thenAnswer((_) async {});

        // ACT
        await repository.removeFromCellar(wineId);

        // ASSERT
        verify(() => mockDataSource.removeFromCellar(wineId)).called(1);
      });
    });

    // =========================================================================
    // UPDATE STOCK TESTS
    // =========================================================================

    group('updateStock', () {
      test('devrait mettre à jour le stock et retourner le CellarWine', () async {
        // ARRANGE
        const wineId = 1;
        const newStock = 10;
        final existingModel = TestData.createCellarWineModel(stock: 5);
        final updatedModel = existingModel.copyWith(stock: newStock);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((_) async => updatedModel);

        // ACT
        final result = await repository.updateStock(wineId, newStock);

        // ASSERT
        expect(result.stock, equals(newStock));
        verify(() => mockDataSource.getCellarWineById(wineId)).called(1);
        verify(() => mockDataSource.updateCellarWine(any())).called(1);
      });

      test('devrait clamper le stock entre 0 et 9999', () async {
        // ARRANGE
        const wineId = 1;
        const excessiveStock = 10000;
        final existingModel = TestData.createCellarWineModel(stock: 5);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((invocation) async {
          final model = invocation.positionalArguments[0] as CellarWineModel;
          return model;
        });

        // ACT
        final result = await repository.updateStock(wineId, excessiveStock);

        // ASSERT
        expect(result.stock, equals(9999));
      });

      test('devrait clamper un stock négatif à 0', () async {
        // ARRANGE
        const wineId = 1;
        const negativeStock = -5;
        final existingModel = TestData.createCellarWineModel(stock: 5);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((invocation) async {
          final model = invocation.positionalArguments[0] as CellarWineModel;
          return model;
        });

        // ACT
        final result = await repository.updateStock(wineId, negativeStock);

        // ASSERT
        expect(result.stock, equals(0));
      });

      test('devrait lever une exception si le vin n\'existe pas', () async {
        // ARRANGE
        const wineId = 999;
        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => null);

        // ACT & ASSERT
        expect(
          () => repository.updateStock(wineId, 10),
          throwsA(isA<Exception>()),
        );
      });
    });

    // =========================================================================
    // INCREMENT STOCK TESTS
    // =========================================================================

    group('incrementStock', () {
      test('devrait incrémenter le stock de 1', () async {
        // ARRANGE
        const wineId = 1;
        const initialStock = 5;
        final existingModel = TestData.createCellarWineModel(stock: initialStock);
        final updatedModel = existingModel.copyWith(stock: initialStock + 1);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((_) async => updatedModel);

        // ACT
        final result = await repository.incrementStock(wineId);

        // ASSERT
        expect(result.stock, equals(initialStock + 1));
      });

      test('devrait lever une exception si le vin n\'existe pas', () async {
        // ARRANGE
        const wineId = 999;
        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => null);

        // ACT & ASSERT
        expect(
          () => repository.incrementStock(wineId),
          throwsA(isA<Exception>()),
        );
      });
    });

    // =========================================================================
    // DECREMENT STOCK TESTS
    // =========================================================================

    group('decrementStock', () {
      test('devrait décrémenter le stock de 1', () async {
        // ARRANGE
        const wineId = 1;
        const initialStock = 5;
        final existingModel = TestData.createCellarWineModel(stock: initialStock);
        final updatedModel = existingModel.copyWith(stock: initialStock - 1);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((_) async => updatedModel);

        // ACT
        final result = await repository.decrementStock(wineId);

        // ASSERT
        expect(result.stock, equals(initialStock - 1));
      });

      test('devrait clamper à 0 si stock déjà à 0', () async {
        // ARRANGE
        const wineId = 1;
        final existingModel = TestData.createCellarWineModel(stock: 0);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((invocation) async {
          final model = invocation.positionalArguments[0] as CellarWineModel;
          return model;
        });

        // ACT
        final result = await repository.decrementStock(wineId);

        // ASSERT
        expect(result.stock, equals(0));
      });
    });

    // =========================================================================
    // UPDATE RATING TESTS
    // =========================================================================

    group('updateRating', () {
      test('devrait mettre à jour la note', () async {
        // ARRANGE
        const wineId = 1;
        const newRating = 5;
        final existingModel = TestData.createCellarWineModel(rating: 3);
        final updatedModel = existingModel.copyWith(rating: newRating);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((_) async => updatedModel);

        // ACT
        final result = await repository.updateRating(wineId, newRating);

        // ASSERT
        expect(result.rating, equals(newRating));
      });

      test('devrait clamper la note entre 0 et 5', () async {
        // ARRANGE
        const wineId = 1;
        const excessiveRating = 10;
        final existingModel = TestData.createCellarWineModel(rating: 3);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((invocation) async {
          final model = invocation.positionalArguments[0] as CellarWineModel;
          return model;
        });

        // ACT
        final result = await repository.updateRating(wineId, excessiveRating);

        // ASSERT
        expect(result.rating, equals(5));
      });
    });

    // =========================================================================
    // UPDATE ANNOTATION TESTS
    // =========================================================================

    group('updateAnnotation', () {
      test('devrait mettre à jour l\'annotation', () async {
        // ARRANGE
        const wineId = 1;
        const newAnnotation = 'Nouvelle annotation';
        final existingModel = TestData.createCellarWineModel(annotation: 'Ancienne');
        final updatedModel = existingModel.withAnnotation(newAnnotation);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((_) async => updatedModel);

        // ACT
        final result = await repository.updateAnnotation(wineId, newAnnotation);

        // ASSERT
        expect(result.annotation, equals(newAnnotation));
      });

      test('devrait permettre de mettre l\'annotation à null', () async {
        // ARRANGE
        const wineId = 1;
        final existingModel = TestData.createCellarWineModel(annotation: 'Test');
        final updatedModel = existingModel.withAnnotation(null);

        when(() => mockDataSource.getCellarWineById(wineId))
            .thenAnswer((_) async => existingModel);
        when(() => mockDataSource.updateCellarWine(any()))
            .thenAnswer((_) async => updatedModel);

        // ACT
        final result = await repository.updateAnnotation(wineId, null);

        // ASSERT
        expect(result.annotation, isNull);
      });
    });

    // =========================================================================
    // IS IN CELLAR TESTS
    // =========================================================================

    group('isInCellar', () {
      test('devrait retourner true si le vin est dans la cave', () async {
        // ARRANGE
        const wineId = 1;
        when(() => mockDataSource.isInCellar(wineId))
            .thenAnswer((_) async => true);

        // ACT
        final result = await repository.isInCellar(wineId);

        // ASSERT
        expect(result, isTrue);
        verify(() => mockDataSource.isInCellar(wineId)).called(1);
      });

      test('devrait retourner false si le vin n\'est pas dans la cave', () async {
        // ARRANGE
        const wineId = 999;
        when(() => mockDataSource.isInCellar(wineId))
            .thenAnswer((_) async => false);

        // ACT
        final result = await repository.isInCellar(wineId);

        // ASSERT
        expect(result, isFalse);
      });
    });
  });
}
