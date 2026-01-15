import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/usecases/update_wine_annotation.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockCellarRepository mockRepository;
  late UpdateWineAnnotation useCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockCellarRepository();
    useCase = UpdateWineAnnotation(mockRepository);
  });

  group('UpdateWineAnnotation UseCase', () {
    // =========================================================================
    // SUCCESS SCENARIOS
    // =========================================================================

    group('mise à jour réussie', () {
      test('devrait mettre à jour l\'annotation d\'un vin', () async {
        // ARRANGE
        const wineId = 1;
        const newAnnotation = 'Excellent millésime';
        final expectedCellarWine = TestData.cellarWineRouge.copyWith(
          annotation: newAnnotation,
        );

        when(
          () => mockRepository.updateAnnotation(wineId, newAnnotation),
        ).thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wineId, newAnnotation);

        // ASSERT
        expect(result.annotation, equals(newAnnotation));
        verify(
          () => mockRepository.updateAnnotation(wineId, newAnnotation),
        ).called(1);
      });

      test('devrait supprimer l\'annotation avec null', () async {
        // ARRANGE
        const wineId = 1;
        final cellarWineWithoutAnnotation = TestData.cellarWineRouge.copyWith(
          annotation: null,
        );

        when(
          () => mockRepository.updateAnnotation(wineId, null),
        ).thenAnswer((_) async => cellarWineWithoutAnnotation);

        // ACT
        final result = await useCase.call(wineId, null);

        // ASSERT
        expect(result.annotation, isNull);
        verify(() => mockRepository.updateAnnotation(wineId, null)).called(1);
      });
    });

    // =========================================================================
    // ANNOTATION CLEANING TESTS
    // =========================================================================

    group('nettoyage de l\'annotation', () {
      test('devrait trim une annotation avec espaces', () async {
        // ARRANGE
        const wineId = 1;
        const annotationWithSpaces = '  Annotation avec espaces  ';
        const cleanedAnnotation = 'Annotation avec espaces';
        final cellarWine = TestData.cellarWineRouge.copyWith(
          annotation: cleanedAnnotation,
        );

        when(
          () => mockRepository.updateAnnotation(wineId, cleanedAnnotation),
        ).thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, annotationWithSpaces);

        // ASSERT
        verify(
          () => mockRepository.updateAnnotation(wineId, cleanedAnnotation),
        ).called(1);
      });

      test('devrait convertir une annotation vide en null', () async {
        // ARRANGE
        const wineId = 1;
        const emptyAnnotation = '';
        final cellarWine = TestData.cellarWineRouge.withAnnotation(null);

        when(
          () => mockRepository.updateAnnotation(wineId, null),
        ).thenAnswer((_) async => cellarWine);

        // ACT
        await useCase.call(wineId, emptyAnnotation);

        // ASSERT
        verify(() => mockRepository.updateAnnotation(wineId, null)).called(1);
      });

      test(
        'devrait convertir une annotation avec uniquement des espaces en null',
        () async {
          // ARRANGE
          const wineId = 1;
          const spacesOnlyAnnotation = '     ';
          final cellarWine = TestData.cellarWineRouge.withAnnotation(null);

          when(
            () => mockRepository.updateAnnotation(wineId, null),
          ).thenAnswer((_) async => cellarWine);

          // ACT
          await useCase.call(wineId, spacesOnlyAnnotation);

          // ASSERT
          verify(() => mockRepository.updateAnnotation(wineId, null)).called(1);
        },
      );
    });

    // =========================================================================
    // ERROR HANDLING TESTS
    // =========================================================================

    group('gestion des erreurs', () {
      test('devrait propager l\'erreur si le repository échoue', () async {
        // ARRANGE
        const wineId = 1;
        const annotation = 'Test';

        when(
          () => mockRepository.updateAnnotation(wineId, annotation),
        ).thenThrow(Exception('Vin non trouvé dans la cave'));

        // ACT & ASSERT
        expect(
          () => useCase.call(wineId, annotation),
          throwsA(isA<Exception>()),
        );
      });

      test('devrait propager l\'erreur avec annotation null', () async {
        // ARRANGE
        const wineId = 999;

        when(
          () => mockRepository.updateAnnotation(wineId, null),
        ).thenThrow(Exception('Vin non trouvé'));

        // ACT & ASSERT
        expect(() => useCase.call(wineId, null), throwsA(isA<Exception>()));
      });
    });
  });
}
