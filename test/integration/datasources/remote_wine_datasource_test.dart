import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/core/constants/api_constants.dart';
import 'package:wines_app/data/datasources/remote_wine_datasource.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockHttpClient mockClient;
  late RemoteWineDataSource dataSource;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = RemoteWineDataSource(client: mockClient);
  });

  group('RemoteWineDataSource', () {
    // =========================================================================
    // GET WINES TESTS
    // =========================================================================

    group('getWines', () {
      test('devrait retourner une liste de WineModel en cas de succès', () async {
        // ARRANGE
        final jsonList = [TestData.wineJson, TestData.wineJsonSansMillesime];
        final response = http.Response(json.encode(jsonList), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWines();

        // ASSERT
        expect(result.length, equals(2));
        expect(result[0].id, equals(TestData.wineJson['id']));
        expect(result[1].id, equals(TestData.wineJsonSansMillesime['id']));
        verify(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).called(1);
      });

      test('devrait retourner une liste vide si la réponse est vide', () async {
        // ARRANGE
        final response = http.Response(json.encode([]), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWines();

        // ASSERT
        expect(result, isEmpty);
      });

      test('devrait lever une exception si statusCode != 200', () async {
        // ARRANGE
        final response = http.Response('Not Found', 404);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT & ASSERT
        expect(
          () => dataSource.getWines(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('404'),
          )),
        );
      });

      test('devrait lever une exception si statusCode est 500', () async {
        // ARRANGE
        final response = http.Response('Internal Server Error', 500);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT & ASSERT
        expect(
          () => dataSource.getWines(),
          throwsA(isA<Exception>()),
        );
      });

      test('devrait parser correctement tous les champs du JSON', () async {
        // ARRANGE
        final jsonList = [TestData.wineJson];
        final response = http.Response(json.encode(jsonList), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWines();

        // ASSERT
        final wine = result.first;
        expect(wine.id, equals(TestData.wineJson['id']));
        expect(wine.nom, equals(TestData.wineJson['nom']));
        expect(wine.appellation, equals(TestData.wineJson['appellation']));
        expect(wine.region, equals(TestData.wineJson['region']));
        expect(wine.cepage, equals(TestData.wineJson['cepage']));
        expect(wine.millesime, equals(TestData.wineJson['millesime']));
        expect(wine.couleur, equals(TestData.wineJson['couleur']));
        expect(wine.description, equals(TestData.wineJson['description']));
        expect(wine.producteur, equals(TestData.wineJson['producteur']));
        expect(wine.degreAlcool, equals(TestData.wineJson['degre_alcool']));
        expect(wine.image, equals(TestData.wineJson['image']));
      });

      test('devrait gérer un vin sans millésime', () async {
        // ARRANGE
        final jsonList = [TestData.wineJsonSansMillesime];
        final response = http.Response(json.encode(jsonList), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWines();

        // ASSERT
        expect(result.first.millesime, isNull);
      });
    });

    // =========================================================================
    // GET WINE BY ID TESTS
    // =========================================================================

    group('getWineById', () {
      test('devrait retourner le WineModel correspondant à l\'id', () async {
        // ARRANGE
        const targetId = 1;
        final jsonList = [
          TestData.wineJson,
          {...TestData.wineJson, 'id': 2, 'nom': 'Autre Vin'},
        ];
        final response = http.Response(json.encode(jsonList), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWineById(targetId);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.id, equals(targetId));
        expect(result.nom, equals(TestData.wineJson['nom']));
      });

      test('devrait retourner null si l\'id n\'existe pas', () async {
        // ARRANGE
        const nonExistentId = 999;
        final jsonList = [TestData.wineJson];
        final response = http.Response(json.encode(jsonList), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWineById(nonExistentId);

        // ASSERT
        expect(result, isNull);
      });

      test('devrait trouver le bon vin parmi plusieurs', () async {
        // ARRANGE
        const targetId = 3;
        final jsonList = [
          {...TestData.wineJson, 'id': 1, 'nom': 'Vin 1'},
          {...TestData.wineJson, 'id': 2, 'nom': 'Vin 2'},
          {...TestData.wineJson, 'id': 3, 'nom': 'Vin Recherché'},
          {...TestData.wineJson, 'id': 4, 'nom': 'Vin 4'},
        ];
        final response = http.Response(json.encode(jsonList), 200);
        
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenAnswer((_) async => response);

        // ACT
        final result = await dataSource.getWineById(targetId);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.id, equals(3));
        expect(result.nom, equals('Vin Recherché'));
      });
    });

    // =========================================================================
    // ERROR SCENARIOS
    // =========================================================================

    group('gestion des erreurs réseau', () {
      test('devrait propager l\'exception si la connexion échoue', () async {
        // ARRANGE
        when(() => mockClient.get(
          Uri.parse(ApiConstants.winesUrl),
          headers: {'Content-Type': 'application/json'},
        )).thenThrow(Exception('Network error'));

        // ACT & ASSERT
        expect(
          () => dataSource.getWines(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
