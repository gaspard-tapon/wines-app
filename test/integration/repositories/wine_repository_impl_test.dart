import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/data/repositories/wine_repository_impl.dart';
import 'package:wines_app/domain/entities/wine.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockRemoteWineDataSource mockDataSource;
  late WineRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockDataSource = MockRemoteWineDataSource();
    repository = WineRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('WineRepositoryImpl', () {
    // =========================================================================
    // GET AVAILABLE WINES TESTS
    // =========================================================================

    group('getAvailableWines', () {
      test('devrait retourner une liste de Wine depuis le datasource', () async {
        // ARRANGE
        final models = [
          TestData.createWineModel(id: 1, nom: 'Vin 1'),
          TestData.createWineModel(id: 2, nom: 'Vin 2'),
          TestData.createWineModel(id: 3, nom: 'Vin 3'),
        ];
        when(() => mockDataSource.getWines())
            .thenAnswer((_) async => models);

        // ACT
        final result = await repository.getAvailableWines();

        // ASSERT
        expect(result, isA<List<Wine>>());
        expect(result.length, equals(3));
        verify(() => mockDataSource.getWines()).called(1);
      });

      test('devrait retourner une liste vide si pas de vins', () async {
        // ARRANGE
        when(() => mockDataSource.getWines())
            .thenAnswer((_) async => []);

        // ACT
        final result = await repository.getAvailableWines();

        // ASSERT
        expect(result, isEmpty);
      });

      test('devrait convertir correctement les models en entities', () async {
        // ARRANGE
        final model = TestData.createWineModel(
          id: 1,
          nom: 'Test Wine',
          appellation: 'Test AOC',
          region: 'Test Region',
          couleur: 'Rouge',
          millesime: 2020,
        );
        when(() => mockDataSource.getWines())
            .thenAnswer((_) async => [model]);

        // ACT
        final result = await repository.getAvailableWines();

        // ASSERT
        expect(result.first.id, equals(1));
        expect(result.first.nom, equals('Test Wine'));
        expect(result.first.appellation, equals('Test AOC'));
        expect(result.first.region, equals('Test Region'));
        expect(result.first.couleur, equals('Rouge'));
        expect(result.first.millesime, equals(2020));
      });

      test('devrait propager l\'erreur si le datasource échoue', () async {
        // ARRANGE
        when(() => mockDataSource.getWines())
            .thenThrow(Exception('Erreur réseau'));

        // ACT & ASSERT
        expect(
          () => repository.getAvailableWines(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // =========================================================================
    // GET WINE BY ID TESTS
    // =========================================================================

    group('getWineById', () {
      test('devrait retourner un Wine si trouvé', () async {
        // ARRANGE
        const wineId = 1;
        final model = TestData.createWineModel(id: wineId, nom: 'Vin Recherché');
        when(() => mockDataSource.getWineById(wineId))
            .thenAnswer((_) async => model);

        // ACT
        final result = await repository.getWineById(wineId);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.id, equals(wineId));
        expect(result.nom, equals('Vin Recherché'));
        verify(() => mockDataSource.getWineById(wineId)).called(1);
      });

      test('devrait retourner null si non trouvé', () async {
        // ARRANGE
        const wineId = 999;
        when(() => mockDataSource.getWineById(wineId))
            .thenAnswer((_) async => null);

        // ACT
        final result = await repository.getWineById(wineId);

        // ASSERT
        expect(result, isNull);
      });

      test('devrait convertir correctement le model en entity', () async {
        // ARRANGE
        const wineId = 1;
        final model = TestData.createWineModel(
          id: wineId,
          nom: 'Château Test',
          appellation: 'Margaux',
          region: 'Bordeaux',
          cepage: 'Cabernet Sauvignon',
          millesime: 2018,
          couleur: 'Rouge',
          description: 'Un grand vin',
          producteur: 'Château Test',
          degreAlcool: 13.5,
          image: 'https://example.com/image.jpg',
        );
        when(() => mockDataSource.getWineById(wineId))
            .thenAnswer((_) async => model);

        // ACT
        final result = await repository.getWineById(wineId);

        // ASSERT
        expect(result, isA<Wine>());
        expect(result!.nom, equals('Château Test'));
        expect(result.appellation, equals('Margaux'));
        expect(result.region, equals('Bordeaux'));
        expect(result.cepage, equals('Cabernet Sauvignon'));
        expect(result.millesime, equals(2018));
        expect(result.couleur, equals('Rouge'));
        expect(result.description, equals('Un grand vin'));
        expect(result.producteur, equals('Château Test'));
        expect(result.degreAlcool, equals(13.5));
        expect(result.image, equals('https://example.com/image.jpg'));
      });

      test('devrait propager l\'erreur si le datasource échoue', () async {
        // ARRANGE
        const wineId = 1;
        when(() => mockDataSource.getWineById(wineId))
            .thenThrow(Exception('Erreur réseau'));

        // ACT & ASSERT
        expect(
          () => repository.getWineById(wineId),
          throwsA(isA<Exception>()),
        );
      });
    });

    // =========================================================================
    // INTEGRATION SCENARIOS
    // =========================================================================

    group('scénarios d\'intégration', () {
      test('devrait permettre de récupérer les vins puis un vin spécifique', () async {
        // ARRANGE
        final models = [
          TestData.createWineModel(id: 1, nom: 'Vin 1'),
          TestData.createWineModel(id: 2, nom: 'Vin 2'),
        ];
        when(() => mockDataSource.getWines())
            .thenAnswer((_) async => models);
        when(() => mockDataSource.getWineById(2))
            .thenAnswer((_) async => models[1]);

        // ACT
        final allWines = await repository.getAvailableWines();
        final specificWine = await repository.getWineById(2);

        // ASSERT
        expect(allWines.length, equals(2));
        expect(specificWine, isNotNull);
        expect(specificWine!.id, equals(2));
        expect(specificWine.nom, equals('Vin 2'));
      });
    });
  });
}
