import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/usecases/increment_stock.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockCellarRepository mockRepository;
  late IncrementStock useCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockCellarRepository();
    useCase = IncrementStock(mockRepository);
  });

  group('IncrementStock UseCase', () {
    // =========================================================================
    // SUCCESS SCENARIOS
    // =========================================================================

    group('incrémentation réussie', () {
      test('devrait incrémenter le stock d\'un vin', () async {
        // ARRANGE
        const wineId = 1;
        final initialCellarWine = TestData.cellarWineRouge;
        final expectedCellarWine = initialCellarWine.copyWith(
          stock: initialCellarWine.stock + 1,
        );

        when(() => mockRepository.incrementStock(wineId))
            .thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wineId);

        // ASSERT
        expect(result.stock, equals(expectedCellarWine.stock));
        verify(() => mockRepository.incrementStock(wineId)).called(1);
      });

      test('devrait incrémenter le stock même si initial est 0', () async {
        // ARRANGE
        const wineId = 3;
        final cellarWineWithZeroStock = TestData.cellarWineRose; // stock = 0
        final expectedCellarWine = cellarWineWithZeroStock.copyWith(stock: 1);

        when(() => mockRepository.incrementStock(wineId))
            .thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wineId);

        // ASSERT
        expect(result.stock, equals(1));
      });
    });

    // =========================================================================
    // DELEGATION TESTS
    // =========================================================================

    group('délégation au repository', () {
      test('devrait appeler le repository avec le bon wineId', () async {
        // ARRANGE
        const wineId = 42;
        final cellarWine = TestData.cellarWineRouge;

        when(() => mockRepository.incrementStock(wineId))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId);

        // ASSERT
        verify(() => mockRepository.incrementStock(wineId)).called(1);
      });

      test('ne devrait pas appeler d\'autres méthodes du repository', () async {
        // ARRANGE
        const wineId = 1;
        final cellarWine = TestData.cellarWineRouge;

        when(() => mockRepository.incrementStock(wineId))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId);

        // ASSERT
        verifyNever(() => mockRepository.decrementStock(any()));
        verifyNever(() => mockRepository.updateStock(any(), any()));
        verifyNever(() => mockRepository.getCellarWines());
      });
    });

    // =========================================================================
    // ERROR HANDLING TESTS
    // =========================================================================

    group('gestion des erreurs', () {
      test('devrait propager l\'erreur si le vin n\'existe pas', () async {
        // ARRANGE
        const wineId = 999;

        when(() => mockRepository.incrementStock(wineId))
            .thenThrow(Exception('Vin non trouvé dans la cave'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wineId),
          throwsA(isA<Exception>()),
        );
      });

      test('devrait propager l\'erreur si le repository échoue', () async {
        // ARRANGE
        const wineId = 1;

        when(() => mockRepository.incrementStock(wineId))
            .thenThrow(Exception('Erreur de base de données'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wineId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
