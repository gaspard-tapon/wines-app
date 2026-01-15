import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/usecases/add_wine_to_cellar.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockCellarRepository mockRepository;
  late AddWineToCellar useCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockCellarRepository();
    useCase = AddWineToCellar(mockRepository);
  });

  group('AddWineToCellar UseCase', () {
    // =========================================================================
    // SUCCESS SCENARIOS
    // =========================================================================

    group('ajout réussi', () {
      test('devrait ajouter un nouveau vin à la cave s\'il n\'existe pas', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        final expectedCellarWine = TestData.cellarWineRouge;
        
        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => false);
        when(() => mockRepository.addWineToCellar(wine))
            .thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wine);

        // ASSERT
        expect(result, equals(expectedCellarWine));
        verify(() => mockRepository.isInCellar(wine.id)).called(1);
        verify(() => mockRepository.addWineToCellar(wine)).called(1);
        verifyNever(() => mockRepository.incrementStock(any()));
      });

      test('devrait incrémenter le stock si le vin existe déjà', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        final existingCellarWine = TestData.cellarWineRouge;
        final updatedCellarWine = existingCellarWine.copyWith(
          stock: existingCellarWine.stock + 1,
        );
        
        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => true);
        when(() => mockRepository.incrementStock(wine.id))
            .thenAnswer((_) async => updatedCellarWine);

        // ACT
        final result = await useCase.call(wine);

        // ASSERT
        expect(result.stock, equals(updatedCellarWine.stock));
        verify(() => mockRepository.isInCellar(wine.id)).called(1);
        verify(() => mockRepository.incrementStock(wine.id)).called(1);
        verifyNever(() => mockRepository.addWineToCellar(any()));
      });
    });

    // =========================================================================
    // VERIFICATION ORDER TESTS
    // =========================================================================

    group('ordre des opérations', () {
      test('devrait d\'abord vérifier si le vin est dans la cave', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        final cellarWine = TestData.cellarWineRouge;
        final callOrder = <String>[];
        
        when(() => mockRepository.isInCellar(wine.id)).thenAnswer((_) async {
          callOrder.add('isInCellar');
          return false;
        });
        when(() => mockRepository.addWineToCellar(wine)).thenAnswer((_) async {
          callOrder.add('addWineToCellar');
          return cellarWine;
        });

        // ACT
        await useCase.call(wine);

        // ASSERT
        expect(callOrder, equals(['isInCellar', 'addWineToCellar']));
      });
    });

    // =========================================================================
    // ERROR HANDLING TESTS
    // =========================================================================

    group('gestion des erreurs', () {
      test('devrait propager l\'erreur si isInCellar échoue', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        
        when(() => mockRepository.isInCellar(wine.id))
            .thenThrow(Exception('Erreur de base de données'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wine),
          throwsA(isA<Exception>()),
        );
      });

      test('devrait propager l\'erreur si addWineToCellar échoue', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        
        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => false);
        when(() => mockRepository.addWineToCellar(wine))
            .thenThrow(Exception('Erreur d\'ajout'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wine),
          throwsA(isA<Exception>()),
        );
      });

      test('devrait propager l\'erreur si incrementStock échoue', () async {
        // ARRANGE
        final wine = TestData.wineRouge;
        
        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => true);
        when(() => mockRepository.incrementStock(wine.id))
            .thenThrow(Exception('Erreur d\'incrémentation'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wine),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
