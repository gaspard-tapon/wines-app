import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/domain/entities/wine.dart';
import '../../helpers/test_data.dart';

void main() {
  group('Wine Entity', () {
    // =========================================================================
    // CREATION TESTS
    // =========================================================================
    
    group('création', () {
      test('devrait créer un Wine avec toutes les propriétés requises', () {
        // ARRANGE
        const id = 1;
        const nom = 'Château Margaux';
        const appellation = 'Margaux';
        const region = 'Bordeaux';
        const cepage = 'Cabernet Sauvignon';
        const millesime = 2018;
        const couleur = 'Rouge';
        const description = 'Un vin exceptionnel';
        const producteur = 'Château Margaux';
        const degreAlcool = 13.5;
        const image = 'https://example.com/wine.jpg';

        // ACT
        final wine = Wine(
          id: id,
          nom: nom,
          appellation: appellation,
          region: region,
          cepage: cepage,
          millesime: millesime,
          couleur: couleur,
          description: description,
          producteur: producteur,
          degreAlcool: degreAlcool,
          image: image,
        );

        // ASSERT
        expect(wine.id, equals(id));
        expect(wine.nom, equals(nom));
        expect(wine.appellation, equals(appellation));
        expect(wine.region, equals(region));
        expect(wine.cepage, equals(cepage));
        expect(wine.millesime, equals(millesime));
        expect(wine.couleur, equals(couleur));
        expect(wine.description, equals(description));
        expect(wine.producteur, equals(producteur));
        expect(wine.degreAlcool, equals(degreAlcool));
        expect(wine.image, equals(image));
      });

      test('devrait permettre un millesime null', () {
        // ARRANGE & ACT
        final wine = TestData.wineSansMillesime;

        // ASSERT
        expect(wine.millesime, isNull);
      });
    });

    // =========================================================================
    // COPYWITH TESTS
    // =========================================================================

    group('copyWith', () {
      test('devrait créer une copie avec les mêmes valeurs si aucun paramètre fourni', () {
        // ARRANGE
        final original = TestData.wineRouge;

        // ACT
        final copy = original.copyWith();

        // ASSERT
        expect(copy.id, equals(original.id));
        expect(copy.nom, equals(original.nom));
        expect(copy.appellation, equals(original.appellation));
        expect(copy.region, equals(original.region));
        expect(copy.cepage, equals(original.cepage));
        expect(copy.millesime, equals(original.millesime));
        expect(copy.couleur, equals(original.couleur));
        expect(copy.description, equals(original.description));
        expect(copy.producteur, equals(original.producteur));
        expect(copy.degreAlcool, equals(original.degreAlcool));
        expect(copy.image, equals(original.image));
      });

      test('devrait modifier uniquement le nom lors du copyWith', () {
        // ARRANGE
        final original = TestData.wineRouge;
        const nouveauNom = 'Nouveau Château';

        // ACT
        final copy = original.copyWith(nom: nouveauNom);

        // ASSERT
        expect(copy.nom, equals(nouveauNom));
        expect(copy.id, equals(original.id));
        expect(copy.region, equals(original.region));
      });

      test('devrait modifier plusieurs propriétés simultanément', () {
        // ARRANGE
        final original = TestData.wineRouge;
        const nouveauNom = 'Nouveau Vin';
        const nouveauMillesime = 2020;
        const nouveauDegre = 14.0;

        // ACT
        final copy = original.copyWith(
          nom: nouveauNom,
          millesime: nouveauMillesime,
          degreAlcool: nouveauDegre,
        );

        // ASSERT
        expect(copy.nom, equals(nouveauNom));
        expect(copy.millesime, equals(nouveauMillesime));
        expect(copy.degreAlcool, equals(nouveauDegre));
        expect(copy.id, equals(original.id)); // inchangé
      });
    });

    // =========================================================================
    // EQUALITY TESTS
    // =========================================================================

    group('égalité', () {
      test('deux wines avec le même id devraient être égaux', () {
        // ARRANGE
        final wine1 = TestData.createWine(id: 1, nom: 'Vin A');
        final wine2 = TestData.createWine(id: 1, nom: 'Vin B');

        // ACT & ASSERT
        expect(wine1 == wine2, isTrue);
      });

      test('deux wines avec des ids différents ne devraient pas être égaux', () {
        // ARRANGE
        final wine1 = TestData.createWine(id: 1);
        final wine2 = TestData.createWine(id: 2);

        // ACT & ASSERT
        expect(wine1 == wine2, isFalse);
      });

      test('hashCode devrait être basé sur l\'id', () {
        // ARRANGE
        final wine1 = TestData.createWine(id: 1);
        final wine2 = TestData.createWine(id: 1);
        final wine3 = TestData.createWine(id: 2);

        // ACT & ASSERT
        expect(wine1.hashCode, equals(wine2.hashCode));
        expect(wine1.hashCode, isNot(equals(wine3.hashCode)));
      });

      test('un wine devrait être égal à lui-même (reflexivité)', () {
        // ARRANGE
        final wine = TestData.wineRouge;

        // ACT & ASSERT
        expect(wine == wine, isTrue);
      });
    });
  });
}
