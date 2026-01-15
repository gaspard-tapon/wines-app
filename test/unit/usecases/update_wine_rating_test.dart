import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/usecases/update_wine_rating.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockCellarRepository mockRepository;
  late UpdateWineRating useCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockCellarRepository();
    useCase = UpdateWineRating(mockRepository);
  });

  group('UpdateWineRating UseCase', () {
    // =========================================================================
    // SUCCESS SCENARIOS
    // =========================================================================

    group('mise à jour réussie', () {
      test('devrait mettre à jour la note d\'un vin', () async {
        // ARRANGE
        const wineId = 1;
        const newRating = 5;
        final expectedCellarWine = TestData.cellarWineRouge.copyWith(rating: newRating);

        when(() => mockRepository.updateRating(wineId, newRating))
            .thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wineId, newRating);

        // ASSERT
        expect(result.rating, equals(newRating));
        verify(() => mockRepository.updateRating(wineId, newRating)).called(1);
      });

      test('devrait appeler le repository avec la note validée', () async {
        // ARRANGE
        const wineId = 1;
        const rating = 4;
        final cellarWine = TestData.cellarWineRouge.copyWith(rating: rating);

        when(() => mockRepository.updateRating(wineId, rating))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, rating);

        // ASSERT
        verify(() => mockRepository.updateRating(wineId, rating)).called(1);
      });
    });

    // =========================================================================
    // RATING VALIDATION TESTS
    // =========================================================================

    group('validation de la note', () {
      test('devrait clamper une note négative à 0', () async {
        // ARRANGE
        const wineId = 1;
        const negativeRating = -1;
        const expectedClampedRating = 0;
        final cellarWine = TestData.cellarWineRouge.copyWith(rating: expectedClampedRating);

        when(() => mockRepository.updateRating(wineId, expectedClampedRating))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, negativeRating);

        // ASSERT
        verify(() => mockRepository.updateRating(wineId, expectedClampedRating)).called(1);
      });

      test('devrait clamper une note > 5 à 5', () async {
        // ARRANGE
        const wineId = 1;
        const excessiveRating = 10;
        const expectedClampedRating = 5;
        final cellarWine = TestData.cellarWineRouge.copyWith(rating: expectedClampedRating);

        when(() => mockRepository.updateRating(wineId, expectedClampedRating))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, excessiveRating);

        // ASSERT
        verify(() => mockRepository.updateRating(wineId, expectedClampedRating)).called(1);
      });

      test('devrait accepter une note de 0', () async {
        // ARRANGE
        const wineId = 1;
        const rating = 0;
        final cellarWine = TestData.cellarWineRouge.copyWith(rating: rating);

        when(() => mockRepository.updateRating(wineId, rating))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, rating);

        // ASSERT
        verify(() => mockRepository.updateRating(wineId, rating)).called(1);
      });

      test('devrait accepter une note de 5', () async {
        // ARRANGE
        const wineId = 1;
        const rating = 5;
        final cellarWine = TestData.cellarWineRouge.copyWith(rating: rating);

        when(() => mockRepository.updateRating(wineId, rating))
            .thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, rating);

        // ASSERT
        verify(() => mockRepository.updateRating(wineId, rating)).called(1);
      });
    });

    // =========================================================================
    // ERROR HANDLING TESTS
    // =========================================================================

    group('gestion des erreurs', () {
      test('devrait propager l\'erreur si le repository échoue', () async {
        // ARRANGE
        const wineId = 1;
        const rating = 4;

        when(() => mockRepository.updateRating(wineId, rating))
            .thenThrow(Exception('Vin non trouvé'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wineId, rating),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
