import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wines_app/domain/entities/cellar_wine.dart';
import 'package:wines_app/domain/usecases/add_wine_to_cellar.dart';
import 'package:wines_app/domain/usecases/filter_and_sort_cellar_wines.dart';
import 'package:wines_app/domain/entities/filter_sort_options.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  group('Workflows de la cave à vin', () {
    // =========================================================================
    // AJOUT DE VIN WORKFLOW
    // =========================================================================

    group('Workflow: Ajouter un vin à la cave', () {
      test('devrait ajouter un nouveau vin avec stock initial de 1', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        final useCase = AddWineToCellar(mockRepository);
        
        final wine = TestData.wineRouge;
        final expectedCellarWine = TestData.createCellarWine(
          wine: wine,
          stock: 1,
          rating: 0,
        );

        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => false);
        when(() => mockRepository.addWineToCellar(wine))
            .thenAnswer((_) async => expectedCellarWine);

        // ACT
        final result = await useCase.call(wine);

        // ASSERT
        expect(result.wine.id, equals(wine.id));
        expect(result.stock, equals(1));
        expect(result.rating, equals(0));
      });

      test('devrait incrémenter le stock si le vin existe déjà', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        final useCase = AddWineToCellar(mockRepository);
        
        final wine = TestData.wineRouge;
        final existingCellarWine = TestData.createCellarWine(
          wine: wine,
          stock: 3,
        );
        final updatedCellarWine = existingCellarWine.copyWith(stock: 4);

        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => true);
        when(() => mockRepository.incrementStock(wine.id))
            .thenAnswer((_) async => updatedCellarWine);

        // ACT
        final result = await useCase.call(wine);

        // ASSERT
        expect(result.stock, equals(4));
      });
    });

    // =========================================================================
    // FILTRAGE ET TRI WORKFLOW
    // =========================================================================

    group('Workflow: Filtrer et trier la cave', () {
      late FilterAndSortCellarWines filterAndSort;
      late List<CellarWine> cellarWines;

      setUp(() {
        filterAndSort = FilterAndSortCellarWines();
        cellarWines = TestData.cellarWineList;
      });

      test('devrait trouver les vins rouges 5 étoiles triés par millésime', () {
        // ARRANGE
        const options = FilterSortOptions(
          colorFilter: WineColor.rouge,
          minRating: 5,
          sortField: SortField.millesime,
          ascending: false,
        );

        // ACT
        final result = filterAndSort.call(cellarWines, options);

        // ASSERT
        expect(result.every((cw) => cw.wine.couleur.toLowerCase() == 'rouge'), isTrue);
        expect(result.every((cw) => cw.rating >= 5), isTrue);
        // Vérifier le tri décroissant
        for (var i = 0; i < result.length - 1; i++) {
          final currentMillesime = result[i].wine.millesime ?? 0;
          final nextMillesime = result[i + 1].wine.millesime ?? 0;
          expect(currentMillesime >= nextMillesime, isTrue);
        }
      });

      test('devrait rechercher un vin spécifique et l\'afficher en premier', () {
        // ARRANGE
        const options = FilterSortOptions(
          searchQuery: 'Margaux',
          sortField: SortField.name,
          ascending: true,
        );

        // ACT
        final result = filterAndSort.call(cellarWines, options);

        // ASSERT
        expect(result.isNotEmpty, isTrue);
        expect(
          result.every((cw) =>
              cw.wine.nom.toLowerCase().contains('margaux') ||
              cw.wine.appellation.toLowerCase().contains('margaux') ||
              cw.wine.producteur.toLowerCase().contains('margaux')),
          isTrue,
        );
      });

      test('devrait trouver les vins en stock uniquement', () {
        // ARRANGE
        const options = FilterSortOptions(hasStock: true);

        // ACT
        final result = filterAndSort.call(cellarWines, options);

        // ASSERT
        expect(result.isNotEmpty, isTrue);
        expect(result.every((cw) => cw.stock > 0), isTrue);
      });

      test('devrait combiner plusieurs critères de recherche', () {
        // ARRANGE
        final options = FilterSortOptions(
          minRating: 3,
          hasStock: true,
          minMillesime: 2018,
          sortField: SortField.rating,
          ascending: false,
        );

        // ACT
        final result = filterAndSort.call(cellarWines, options);

        // ASSERT
        for (final wine in result) {
          expect(wine.rating >= 3, isTrue);
          expect(wine.stock > 0, isTrue);
          expect(wine.wine.millesime, isNotNull);
          expect(wine.wine.millesime! >= 2018, isTrue);
        }
        // Vérifier tri décroissant par rating
        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].rating >= result[i + 1].rating, isTrue);
        }
      });
    });

    // =========================================================================
    // GESTION DU STOCK WORKFLOW
    // =========================================================================

    group('Workflow: Gérer le stock', () {
      test('devrait permettre d\'augmenter puis diminuer le stock', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        const wineId = 1;
        var currentStock = 5;

        when(() => mockRepository.incrementStock(wineId))
            .thenAnswer((_) async {
          currentStock++;
          return TestData.createCellarWine(stock: currentStock);
        });
        
        when(() => mockRepository.decrementStock(wineId))
            .thenAnswer((_) async {
          currentStock = (currentStock - 1).clamp(0, 9999);
          return TestData.createCellarWine(stock: currentStock);
        });

        // ACT - Incrémenter 2 fois
        await mockRepository.incrementStock(wineId);
        await mockRepository.incrementStock(wineId);
        expect(currentStock, equals(7));

        // ACT - Décrémenter 3 fois
        await mockRepository.decrementStock(wineId);
        await mockRepository.decrementStock(wineId);
        await mockRepository.decrementStock(wineId);

        // ASSERT
        expect(currentStock, equals(4));
      });

      test('devrait ne pas passer en dessous de 0', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        const wineId = 1;
        var currentStock = 1;

        when(() => mockRepository.decrementStock(wineId))
            .thenAnswer((_) async {
          currentStock = (currentStock - 1).clamp(0, 9999);
          return TestData.createCellarWine(stock: currentStock);
        });

        // ACT - Décrémenter 5 fois
        for (var i = 0; i < 5; i++) {
          await mockRepository.decrementStock(wineId);
        }

        // ASSERT
        expect(currentStock, equals(0));
      });
    });

    // =========================================================================
    // NOTATION ET ANNOTATION WORKFLOW
    // =========================================================================

    group('Workflow: Noter et annoter un vin', () {
      test('devrait permettre de noter puis annoter un vin', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        const wineId = 1;
        var cellarWine = TestData.createCellarWine(
          rating: 0,
          annotation: null,
        );

        when(() => mockRepository.updateRating(wineId, any()))
            .thenAnswer((invocation) async {
          final rating = invocation.positionalArguments[1] as int;
          cellarWine = cellarWine.copyWith(rating: rating);
          return cellarWine;
        });

        when(() => mockRepository.updateAnnotation(wineId, any()))
            .thenAnswer((invocation) async {
          final annotation = invocation.positionalArguments[1] as String?;
          cellarWine = cellarWine.withAnnotation(annotation);
          return cellarWine;
        });

        // ACT - Noter 4 étoiles
        await mockRepository.updateRating(wineId, 4);
        expect(cellarWine.rating, equals(4));

        // ACT - Ajouter une annotation
        await mockRepository.updateAnnotation(wineId, 'Excellent avec un steak');
        expect(cellarWine.annotation, equals('Excellent avec un steak'));

        // ACT - Modifier la note
        await mockRepository.updateRating(wineId, 5);
        expect(cellarWine.rating, equals(5));
        expect(cellarWine.annotation, equals('Excellent avec un steak'));
      });

      test('devrait permettre de supprimer une annotation', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        const wineId = 1;
        var cellarWine = TestData.createCellarWine(
          annotation: 'Annotation existante',
        );

        when(() => mockRepository.updateAnnotation(wineId, null))
            .thenAnswer((_) async {
          cellarWine = cellarWine.withAnnotation(null);
          return cellarWine;
        });

        // ACT
        await mockRepository.updateAnnotation(wineId, null);

        // ASSERT
        expect(cellarWine.annotation, isNull);
      });
    });

    // =========================================================================
    // WORKFLOW COMPLET
    // =========================================================================

    group('Workflow complet: Gestion d\'une cave', () {
      test('devrait gérer le cycle de vie complet d\'un vin', () async {
        // ARRANGE
        final mockRepository = MockCellarRepository();
        final wine = TestData.wineRouge;
        var cellarWine = TestData.createCellarWine(
          wine: wine,
          stock: 1,
          rating: 0,
          annotation: null,
        );

        // Setup mocks
        when(() => mockRepository.isInCellar(wine.id))
            .thenAnswer((_) async => false);
        when(() => mockRepository.addWineToCellar(wine))
            .thenAnswer((_) async => cellarWine);
        when(() => mockRepository.incrementStock(wine.id))
            .thenAnswer((_) async {
          cellarWine = cellarWine.copyWith(stock: cellarWine.stock + 1);
          return cellarWine;
        });
        when(() => mockRepository.updateRating(wine.id, any()))
            .thenAnswer((inv) async {
          cellarWine = cellarWine.copyWith(rating: inv.positionalArguments[1] as int);
          return cellarWine;
        });
        when(() => mockRepository.updateAnnotation(wine.id, any()))
            .thenAnswer((inv) async {
          cellarWine = cellarWine.withAnnotation(inv.positionalArguments[1] as String?);
          return cellarWine;
        });
        when(() => mockRepository.decrementStock(wine.id))
            .thenAnswer((_) async {
          cellarWine = cellarWine.copyWith(
            stock: (cellarWine.stock - 1).clamp(0, 9999),
          );
          return cellarWine;
        });

        // ACT & ASSERT - Étape 1: Ajouter le vin
        await mockRepository.addWineToCellar(wine);
        expect(cellarWine.stock, equals(1));
        expect(cellarWine.rating, equals(0));
        expect(cellarWine.annotation, isNull);

        // Étape 2: Augmenter le stock (achat de bouteilles)
        await mockRepository.incrementStock(wine.id);
        await mockRepository.incrementStock(wine.id);
        expect(cellarWine.stock, equals(3));

        // Étape 3: Déguster et noter
        await mockRepository.updateRating(wine.id, 4);
        await mockRepository.updateAnnotation(wine.id, 'Parfait avec du fromage');
        expect(cellarWine.rating, equals(4));
        expect(cellarWine.annotation, equals('Parfait avec du fromage'));

        // Étape 4: Consommer des bouteilles
        await mockRepository.decrementStock(wine.id);
        expect(cellarWine.stock, equals(2));

        // Étape 5: Améliorer la note après vieillissement
        await mockRepository.updateRating(wine.id, 5);
        await mockRepository.updateAnnotation(wine.id, 'Superbe après 2 ans de cave');
        expect(cellarWine.rating, equals(5));
        expect(cellarWine.annotation, equals('Superbe après 2 ans de cave'));
      });
    });
  });
}
