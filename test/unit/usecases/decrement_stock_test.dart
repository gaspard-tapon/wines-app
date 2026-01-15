import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/usecases/decrement_stock.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockCellarRepository mockRepository;
  late DecrementStock useCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockCellarRepository();
    useCase = DecrementStock(mockRepository);
  });

  group('DecrementStock UseCase', () {
    // =========================================================================
    // SUCCESS SCENARIOS
    // =========================================================================

    group('décrémentation réussie', () {
      test('devrait décrémenter le stock d\'un vin', () async {
        // ARRANGE
        const wineId = 1;
        final initialCellarWine = TestData.cellarWineRouge;
        final expectedCellarWine = initialCellarWine.copyWith(
          stock: initialCellarWine.stock - 1,
        );

        when(() => mockRepository.decrementStock(wineId))
            .thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wineId);

        // ASSERT
        expect(result.stock, equals(expectedCellarWine.stock));
        verify(() => mockRepository.decrementStock(wineId)).called(1);
      });

      test('devrait retourner stock = 0 si déjà à 0', () async {
        // ARRANGE
        const wineId = 3;
        final cellarWineWithZeroStock = TestData.cellarWineRose.copyWith(stock: 0);

        when(() => mockRepository.decrementStock(wineId))
            .thenAnswer((_) async => cellarWineWithZeroStock);

        // ACT
        final result = await useCase.call(wineId);

        // ASSERT
        expect(result.stock, equals(0));
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

        when(() => mockRepository.decrementStock(wineId))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId);

        // ASSERT
        verify(() => mockRepository.decrementStock(wineId)).called(1);
      });

      test('ne devrait pas appeler d\'autres méthodes du repository', () async {
        // ARRANGE
        const wineId = 1;
        final cellarWine = TestData.cellarWineRouge;

        when(() => mockRepository.decrementStock(wineId))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId);

        // ASSERT
        verifyNever(() => mockRepository.incrementStock(any()));
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

        when(() => mockRepository.decrementStock(wineId))
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

        when(() => mockRepository.decrementStock(wineId))
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
