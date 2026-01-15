import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/data/models/wine_model.dart';
import 'package:wines_app/domain/entities/wine.dart';
import '../../helpers/test_data.dart';

void main() {
  group('WineModel', () {
    // =========================================================================
    // FROMJSON TESTS
    // =========================================================================

    group('fromJson', () {
      test('devrait créer un WineModel à partir d\'un JSON valide', () {
        // ARRANGE
        final json = TestData.wineJson;

        // ACT
        final model = WineModel.fromJson(json);

        // ASSERT
        expect(model.id, equals(json['id']));
        expect(model.nom, equals(json['nom']));
        expect(model.appellation, equals(json['appellation']));
        expect(model.region, equals(json['region']));
        expect(model.cepage, equals(json['cepage']));
        expect(model.millesime, equals(json['millesime']));
        expect(model.couleur, equals(json['couleur']));
        expect(model.description, equals(json['description']));
        expect(model.producteur, equals(json['producteur']));
        expect(model.degreAlcool, equals(json['degre_alcool']));
        expect(model.image, equals(json['image']));
      });

      test('devrait gérer un millesime null', () {
        // ARRANGE
        final json = TestData.wineJsonSansMillesime;

        // ACT
        final model = WineModel.fromJson(json);

        // ASSERT
        expect(model.millesime, isNull);
      });

      test('devrait convertir degre_alcool en double', () {
        // ARRANGE
        final json = {
          ...TestData.wineJson,
          'degre_alcool': 14, // int au lieu de double
        };

        // ACT
        final model = WineModel.fromJson(json);

        // ASSERT
        expect(model.degreAlcool, isA<double>());
        expect(model.degreAlcool, equals(14.0));
      });
    });

    // =========================================================================
    // TOJSON TESTS
    // =========================================================================

    group('toJson', () {
      test('devrait convertir un WineModel en JSON', () {
        // ARRANGE
        final model = TestData.createWineModel(
          id: 1,
          nom: 'Test Wine',
          appellation: 'Test AOC',
          region: 'Test Region',
          cepage: 'Test Cépage',
          millesime: 2020,
          couleur: 'Rouge',
          description: 'Test description',
          producteur: 'Test Producteur',
          degreAlcool: 13.0,
          image: 'https://test.com/image.jpg',
        );

        // ACT
        final json = model.toJson();

        // ASSERT
        expect(json['id'], equals(1));
        expect(json['nom'], equals('Test Wine'));
        expect(json['appellation'], equals('Test AOC'));
        expect(json['region'], equals('Test Region'));
        expect(json['cepage'], equals('Test Cépage'));
        expect(json['millesime'], equals(2020));
        expect(json['couleur'], equals('Rouge'));
        expect(json['description'], equals('Test description'));
        expect(json['producteur'], equals('Test Producteur'));
        expect(json['degre_alcool'], equals(13.0));
        expect(json['image'], equals('https://test.com/image.jpg'));
      });

      test('devrait inclure millesime null dans le JSON', () {
        // ARRANGE
        final model = TestData.createWineModel(millesime: null);

        // ACT
        final json = model.toJson();

        // ASSERT
        expect(json.containsKey('millesime'), isTrue);
        expect(json['millesime'], isNull);
      });
    });

    // =========================================================================
    // FROMENTITY TESTS
    // =========================================================================

    group('fromEntity', () {
      test('devrait créer un WineModel à partir d\'une entité Wine', () {
        // ARRANGE
        final entity = TestData.wineRouge;

        // ACT
        final model = WineModel.fromEntity(entity);

        // ASSERT
        expect(model.id, equals(entity.id));
        expect(model.nom, equals(entity.nom));
        expect(model.appellation, equals(entity.appellation));
        expect(model.region, equals(entity.region));
        expect(model.cepage, equals(entity.cepage));
        expect(model.millesime, equals(entity.millesime));
        expect(model.couleur, equals(entity.couleur));
        expect(model.description, equals(entity.description));
        expect(model.producteur, equals(entity.producteur));
        expect(model.degreAlcool, equals(entity.degreAlcool));
        expect(model.image, equals(entity.image));
      });

      test('devrait préserver un millesime null', () {
        // ARRANGE
        final entity = TestData.wineSansMillesime;

        // ACT
        final model = WineModel.fromEntity(entity);

        // ASSERT
        expect(model.millesime, isNull);
      });
    });

    // =========================================================================
    // TOENTITY TESTS
    // =========================================================================

    group('toEntity', () {
      test('devrait convertir un WineModel en entité Wine', () {
        // ARRANGE
        final model = TestData.createWineModel();

        // ACT
        final entity = model.toEntity();

        // ASSERT
        expect(entity, isA<Wine>());
        expect(entity.id, equals(model.id));
        expect(entity.nom, equals(model.nom));
        expect(entity.appellation, equals(model.appellation));
        expect(entity.region, equals(model.region));
        expect(entity.cepage, equals(model.cepage));
        expect(entity.millesime, equals(model.millesime));
        expect(entity.couleur, equals(model.couleur));
        expect(entity.description, equals(model.description));
        expect(entity.producteur, equals(model.producteur));
        expect(entity.degreAlcool, equals(model.degreAlcool));
        expect(entity.image, equals(model.image));
      });

      test('devrait préserver un millesime null lors de la conversion', () {
        // ARRANGE
        final model = TestData.createWineModel(millesime: null);

        // ACT
        final entity = model.toEntity();

        // ASSERT
        expect(entity.millesime, isNull);
      });
    });

    // =========================================================================
    // ROUNDTRIP TESTS
    // =========================================================================

    group('conversion aller-retour', () {
      test('Entity -> Model -> Entity devrait préserver toutes les données', () {
        // ARRANGE
        final originalEntity = TestData.wineRouge;

        // ACT
        final model = WineModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        // ASSERT
        expect(convertedEntity.id, equals(originalEntity.id));
        expect(convertedEntity.nom, equals(originalEntity.nom));
        expect(convertedEntity.appellation, equals(originalEntity.appellation));
        expect(convertedEntity.region, equals(originalEntity.region));
        expect(convertedEntity.cepage, equals(originalEntity.cepage));
        expect(convertedEntity.millesime, equals(originalEntity.millesime));
        expect(convertedEntity.couleur, equals(originalEntity.couleur));
        expect(convertedEntity.description, equals(originalEntity.description));
        expect(convertedEntity.producteur, equals(originalEntity.producteur));
        expect(convertedEntity.degreAlcool, equals(originalEntity.degreAlcool));
        expect(convertedEntity.image, equals(originalEntity.image));
      });

      test('JSON -> Model -> JSON devrait préserver toutes les données', () {
        // ARRANGE
        final originalJson = TestData.wineJson;

        // ACT
        final model = WineModel.fromJson(originalJson);
        final convertedJson = model.toJson();

        // ASSERT
        expect(convertedJson['id'], equals(originalJson['id']));
        expect(convertedJson['nom'], equals(originalJson['nom']));
        expect(convertedJson['appellation'], equals(originalJson['appellation']));
        expect(convertedJson['region'], equals(originalJson['region']));
        expect(convertedJson['cepage'], equals(originalJson['cepage']));
        expect(convertedJson['millesime'], equals(originalJson['millesime']));
        expect(convertedJson['couleur'], equals(originalJson['couleur']));
        expect(convertedJson['description'], equals(originalJson['description']));
        expect(convertedJson['producteur'], equals(originalJson['producteur']));
        expect(convertedJson['degre_alcool'], equals(originalJson['degre_alcool']));
        expect(convertedJson['image'], equals(originalJson['image']));
      });
    });
  });
}
