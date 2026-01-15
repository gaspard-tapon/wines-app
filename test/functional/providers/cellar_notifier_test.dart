import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import 'package:wines_app/domain/usecases/add_wine_to_cellar.dart';
import 'package:wines_app/domain/usecases/decrement_stock.dart';
import 'package:wines_app/domain/usecases/get_cellar_wines.dart';
import 'package:wines_app/domain/usecases/increment_stock.dart';
import 'package:wines_app/domain/usecases/update_wine_annotation.dart';
import 'package:wines_app/domain/usecases/update_wine_rating.dart';
import 'package:wines_app/presentation/providers/cellar_providers.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

// Mocks pour les use cases
class MockGetCellarWines extends Mock implements GetCellarWines {}
class MockAddWineToCellar extends Mock implements AddWineToCellar {}
class MockIncrementStock extends Mock implements IncrementStock {}
class MockDecrementStock extends Mock implements DecrementStock {}
class MockUpdateWineRating extends Mock implements UpdateWineRating {}
class MockUpdateWineAnnotation extends Mock implements UpdateWineAnnotation {}

void main() {
  late MockGetCellarWines mockGetCellarWines;
  late MockAddWineToCellar mockAddWineToCellar;
  late MockIncrementStock mockIncrementStock;
  late MockDecrementStock mockDecrementStock;
  late MockUpdateWineRating mockUpdateRating;
  late MockUpdateWineAnnotation mockUpdateAnnotation;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockGetCellarWines = MockGetCellarWines();
    mockAddWineToCellar = MockAddWineToCellar();
    mockIncrementStock = MockIncrementStock();
    mockDecrementStock = MockDecrementStock();
    mockUpdateRating = MockUpdateWineRating();
    mockUpdateAnnotation = MockUpdateWineAnnotation();
  });

  CellarNotifier createNotifier() {
    return CellarNotifier(
      getCellarWines: mockGetCellarWines,
      addWineToCellar: mockAddWineToCellar,
      incrementStock: mockIncrementStock,
      decrementStock: mockDecrementStock,
      updateRating: mockUpdateRating,
      updateAnnotation: mockUpdateAnnotation,
    );
  }

  group('CellarNotifier', () {
    // =========================================================================
    // INITIAL STATE TESTS
    // =========================================================================

    group('état initial', () {
      test('devrait charger la cave au démarrage', () async {
        // ARRANGE
        final wines = TestData.cellarWineList;
        when(() => mockGetCellarWines()).thenAnswer((_) async => wines);

        // ACT
        final notifier = createNotifier();
        
        // Attendre que l'async soit terminé
        await Future.delayed(Duration.zero);

        // ASSERT
        expect(notifier.state, isA<AsyncData<List<CellarWine>>>());
        final data = notifier.state.value;
        expect(data!.length, equals(wines.length));
        verify(() => mockGetCellarWines()).called(1);
      });

      test('devrait être en état loading initialement', () async {
        // ARRANGE
        when(() => mockGetCellarWines()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [];
        });

        // ACT
        final notifier = createNotifier();

        // ASSERT - immédiatement
        expect(notifier.state, isA<AsyncLoading<List<CellarWine>>>());
      });

      test('devrait être en état error si le chargement échoue', () async {
        // ARRANGE
        when(() => mockGetCellarWines()).thenThrow(Exception('Erreur'));

        // ACT
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);

        // ASSERT
        expect(notifier.state, isA<AsyncError<List<CellarWine>>>());
      });
    });

    // =========================================================================
    // LOAD CELLAR TESTS
    // =========================================================================

    group('loadCellar', () {
      test('devrait recharger la cave', () async {
        // ARRANGE
        final wines = TestData.cellarWineList;
        when(() => mockGetCellarWines()).thenAnswer((_) async => wines);
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);

        final newWines = [TestData.cellarWineRouge];
        when(() => mockGetCellarWines()).thenAnswer((_) async => newWines);

        // ACT
        await notifier.loadCellar();

        // ASSERT
        expect(notifier.state.value!.length, equals(1));
        verify(() => mockGetCellarWines()).called(1);
      });
    });

    // =========================================================================
    // ADD WINE TESTS
    // =========================================================================

    group('addWine', () {
      test('devrait ajouter un vin et recharger la cave', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        final cellarWine = TestData.cellarWineRouge;
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => []);
        when(() => mockAddWineToCellar(wine)).thenAnswer((_) async => cellarWine);
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [cellarWine]);

        // ACT
        await notifier.addWine(wine);

        // ASSERT
        verify(() => mockAddWineToCellar(wine)).called(1);
        verify(() => mockGetCellarWines()).called(1);
      });

      test('devrait recharger la cave même si l\'ajout échoue', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => []);
        when(() => mockAddWineToCellar(wine)).thenThrow(Exception('Erreur'));
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => []);

        // ACT & ASSERT
        await expectLater(
          () => notifier.addWine(wine),
          throwsA(isA<Exception>()),
        );
        verify(() => mockGetCellarWines()).called(1);
      });
    });

    // =========================================================================
    // INCREMENT STOCK TESTS
    // =========================================================================

    group('incrementStock', () {
      test('devrait incrémenter le stock et recharger', () async {
        // ARRANGE
        const wineId = 1;
        final cellarWine = TestData.cellarWineRouge;
        final updatedWine = cellarWine.copyWith(stock: cellarWine.stock + 1);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [cellarWine]);
        when(() => mockIncrementStock(wineId)).thenAnswer((_) async => updatedWine);
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [updatedWine]);

        // ACT
        await notifier.incrementStock(wineId);

        // ASSERT
        verify(() => mockIncrementStock(wineId)).called(1);
        verify(() => mockGetCellarWines()).called(1);
      });
    });

    // =========================================================================
    // DECREMENT STOCK TESTS
    // =========================================================================

    group('decrementStock', () {
      test('devrait décrémenter le stock et recharger', () async {
        // ARRANGE
        const wineId = 1;
        final cellarWine = TestData.cellarWineRouge;
        final updatedWine = cellarWine.copyWith(stock: cellarWine.stock - 1);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [cellarWine]);
        when(() => mockDecrementStock(wineId)).thenAnswer((_) async => updatedWine);
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [updatedWine]);

        // ACT
        await notifier.decrementStock(wineId);

        // ASSERT
        verify(() => mockDecrementStock(wineId)).called(1);
        verify(() => mockGetCellarWines()).called(1);
      });
    });

    // =========================================================================
    // UPDATE RATING TESTS
    // =========================================================================

    group('updateRating', () {
      test('devrait mettre à jour la note et recharger', () async {
        // ARRANGE
        const wineId = 1;
        const newRating = 5;
        final cellarWine = TestData.cellarWineRouge;
        final updatedWine = cellarWine.copyWith(rating: newRating);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [cellarWine]);
        when(() => mockUpdateRating(wineId, newRating)).thenAnswer((_) async => updatedWine);
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [updatedWine]);

        // ACT
        await notifier.updateRating(wineId, newRating);

        // ASSERT
        verify(() => mockUpdateRating(wineId, newRating)).called(1);
        verify(() => mockGetCellarWines()).called(1);
      });
    });

    // =========================================================================
    // UPDATE ANNOTATION TESTS
    // =========================================================================

    group('updateAnnotation', () {
      test('devrait mettre à jour l\'annotation et recharger', () async {
        // ARRANGE
        const wineId = 1;
        const newAnnotation = 'Nouvelle annotation';
        final cellarWine = TestData.cellarWineRouge;
        final updatedWine = cellarWine.copyWith(annotation: newAnnotation);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [cellarWine]);
        when(() => mockUpdateAnnotation(wineId, newAnnotation))
            .thenAnswer((_) async => updatedWine);
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [updatedWine]);

        // ACT
        await notifier.updateAnnotation(wineId, newAnnotation);

        // ASSERT
        verify(() => mockUpdateAnnotation(wineId, newAnnotation)).called(1);
        verify(() => mockGetCellarWines()).called(1);
      });

      test('devrait permettre de supprimer l\'annotation avec null', () async {
        // ARRANGE
        const wineId = 1;
        final cellarWine = TestData.cellarWineRouge;
        final updatedWine = cellarWine.withAnnotation(null);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [cellarWine]);
        when(() => mockUpdateAnnotation(wineId, null))
            .thenAnswer((_) async => updatedWine);
        
        final notifier = createNotifier();
        await Future.delayed(Duration.zero);
        reset(mockGetCellarWines);
        
        when(() => mockGetCellarWines()).thenAnswer((_) async => [updatedWine]);

        // ACT
        await notifier.updateAnnotation(wineId, null);

        // ASSERT
        verify(() => mockUpdateAnnotation(wineId, null)).called(1);
      });
    });
  });
}
