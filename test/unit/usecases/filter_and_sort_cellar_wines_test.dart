import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/domain/entities/filter_sort_options.dart';
import 'package:wines_app/domain/usecases/filter_and_sort_cellar_wines.dart';
import '../../helpers/test_data.dart';

void main() {
  late FilterAndSortCellarWines useCase;

  setUp(() {
    useCase = FilterAndSortCellarWines();
  });

  group('FilterAndSortCellarWines UseCase', () {
    // =========================================================================
    // NO FILTER TESTS
    // =========================================================================

    group('sans filtres', () {
      test('devrait retourner tous les vins si aucun filtre', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions();

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.length, equals(wines.length));
      });
    });

    // =========================================================================
    // SEARCH QUERY FILTER TESTS
    // =========================================================================

    group('filtre par recherche textuelle', () {
      test('devrait filtrer par nom du vin', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(searchQuery: 'Margaux');

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.length, equals(1));
        expect(result.first.wine.nom, contains('Margaux'));
      });

      test('devrait filtrer par appellation', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(searchQuery: 'Provence');

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.isNotEmpty, isTrue);
        expect(
          result.every(
            (cw) =>
                cw.wine.appellation.toLowerCase().contains('provence') ||
                cw.wine.nom.toLowerCase().contains('provence') ||
                cw.wine.producteur.toLowerCase().contains('provence'),
          ),
          isTrue,
        );
      });

      test('devrait être insensible à la casse', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const optionsLower = FilterSortOptions(searchQuery: 'margaux');
        const optionsUpper = FilterSortOptions(searchQuery: 'MARGAUX');

        // ACT
        final resultLower = useCase.call(wines, optionsLower);
        final resultUpper = useCase.call(wines, optionsUpper);

        // ASSERT
        expect(resultLower.length, equals(resultUpper.length));
      });

      test('devrait retourner une liste vide si aucune correspondance', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(searchQuery: 'inexistant');

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result, isEmpty);
      });
    });

    // =========================================================================
    // RATING FILTER TESTS
    // =========================================================================

    group('filtre par note minimum', () {
      test('devrait filtrer les vins avec une note >= minRating', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(minRating: 4);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.every((cw) => cw.rating >= 4), isTrue);
      });

      test('devrait exclure les vins non notés si minRating > 0', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(minRating: 1);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.every((cw) => cw.rating >= 1), isTrue);
      });
    });

    // =========================================================================
    // COLOR FILTER TESTS
    // =========================================================================

    group('filtre par couleur', () {
      test('devrait filtrer uniquement les vins rouges', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(colorFilter: WineColor.rouge);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every((cw) => cw.wine.couleur.toLowerCase() == 'rouge'),
          isTrue,
        );
      });

      test('devrait filtrer uniquement les vins blancs', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(colorFilter: WineColor.blanc);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every((cw) => cw.wine.couleur.toLowerCase() == 'blanc'),
          isTrue,
        );
      });

      test('devrait filtrer les vins rosés (avec accent ou sans)', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(colorFilter: WineColor.rose);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every((cw) {
            final couleur = cw.wine.couleur.toLowerCase();
            return couleur == 'rosé' || couleur == 'rose';
          }),
          isTrue,
        );
      });

      test('devrait retourner tous les vins si colorFilter est all', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(colorFilter: WineColor.all);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.length, equals(wines.length));
      });
    });

    // =========================================================================
    // MILLESIME FILTER TESTS
    // =========================================================================

    group('filtre par millésime', () {
      test('devrait filtrer par millésime minimum', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(minMillesime: 2020);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every(
            (cw) => cw.wine.millesime != null && cw.wine.millesime! >= 2020,
          ),
          isTrue,
        );
      });

      test('devrait filtrer par millésime maximum', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(maxMillesime: 2019);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every(
            (cw) => cw.wine.millesime != null && cw.wine.millesime! <= 2019,
          ),
          isTrue,
        );
      });

      test('devrait filtrer par plage de millésimes', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          minMillesime: 2018,
          maxMillesime: 2020,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every(
            (cw) =>
                cw.wine.millesime != null &&
                cw.wine.millesime! >= 2018 &&
                cw.wine.millesime! <= 2020,
          ),
          isTrue,
        );
      });

      test('devrait exclure les vins sans millésime si filtre actif', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(minMillesime: 2000);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.every((cw) => cw.wine.millesime != null), isTrue);
      });
    });

    // =========================================================================
    // STOCK FILTER TESTS
    // =========================================================================

    group('filtre par stock', () {
      test('devrait filtrer les vins en stock (hasStock = true)', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(hasStock: true);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.every((cw) => cw.stock > 0), isTrue);
      });

      test('devrait filtrer les vins épuisés (hasStock = false)', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(hasStock: false);

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.every((cw) => cw.stock <= 0), isTrue);
      });
    });

    // =========================================================================
    // CEPAGE FILTER TESTS
    // =========================================================================

    group('filtre par cépage', () {
      test('devrait filtrer par un cépage unique', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        final options = FilterSortOptions(cepages: {'Chardonnay'});

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(
          result.every(
            (cw) => cw.wine.cepage.toLowerCase().contains('chardonnay'),
          ),
          isTrue,
        );
      });

      test('devrait filtrer par plusieurs cépages (OR)', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        final options = FilterSortOptions(cepages: {'Merlot', 'Chardonnay'});

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result.isNotEmpty, isTrue);
        expect(
          result.every(
            (cw) =>
                cw.wine.cepage.toLowerCase().contains('merlot') ||
                cw.wine.cepage.toLowerCase().contains('chardonnay'),
          ),
          isTrue,
        );
      });
    });

    // =========================================================================
    // SORT TESTS
    // =========================================================================

    group('tri', () {
      test('devrait trier par nom en ordre croissant', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          sortField: SortField.name,
          ascending: true,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        for (var i = 0; i < result.length - 1; i++) {
          expect(
            result[i].wine.nom.compareTo(result[i + 1].wine.nom) <= 0,
            isTrue,
          );
        }
      });

      test('devrait trier par nom en ordre décroissant', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          sortField: SortField.name,
          ascending: false,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        for (var i = 0; i < result.length - 1; i++) {
          expect(
            result[i].wine.nom.compareTo(result[i + 1].wine.nom) >= 0,
            isTrue,
          );
        }
      });

      test('devrait trier par rating en ordre décroissant', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          sortField: SortField.rating,
          ascending: false,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].rating >= result[i + 1].rating, isTrue);
        }
      });

      test('devrait trier par stock', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          sortField: SortField.stock,
          ascending: false,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].stock >= result[i + 1].stock, isTrue);
        }
      });

      test('devrait trier par date d\'ajout', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          sortField: SortField.addedAt,
          ascending: true,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        for (var i = 0; i < result.length - 1; i++) {
          expect(
            result[i].addedAt.isBefore(result[i + 1].addedAt) ||
                result[i].addedAt.isAtSameMomentAs(result[i + 1].addedAt),
            isTrue,
          );
        }
      });

      test('devrait trier par millésime (null traité comme 0)', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          sortField: SortField.millesime,
          ascending: true,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        for (var i = 0; i < result.length - 1; i++) {
          final a = result[i].wine.millesime ?? 0;
          final b = result[i + 1].wine.millesime ?? 0;
          expect(a <= b, isTrue);
        }
      });
    });

    // =========================================================================
    // COMBINED FILTER AND SORT TESTS
    // =========================================================================

    group('filtres et tri combinés', () {
      test('devrait appliquer plusieurs filtres et trier le résultat', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(
          colorFilter: WineColor.rouge,
          minRating: 3,
          sortField: SortField.rating,
          ascending: false,
        );

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        // Tous les vins sont rouges
        expect(
          result.every((cw) => cw.wine.couleur.toLowerCase() == 'rouge'),
          isTrue,
        );
        // Tous ont une note >= 3
        expect(result.every((cw) => cw.rating >= 3), isTrue);
        // Triés par rating décroissant
        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].rating >= result[i + 1].rating, isTrue);
        }
      });
    });

    // =========================================================================
    // EDGE CASES
    // =========================================================================

    group('cas limites', () {
      test(
        'devrait retourner une liste vide si la liste d\'entrée est vide',
        () {
          // ARRANGE
          const options = FilterSortOptions();

          // ACT
          final result = useCase.call([], options);

          // ASSERT
          expect(result, isEmpty);
        },
      );

      test('devrait gérer une recherche avec caractères spéciaux', () {
        // ARRANGE
        final wines = TestData.cellarWineList;
        const options = FilterSortOptions(searchQuery: 'test@#\$%');

        // ACT
        final result = useCase.call(wines, options);

        // ASSERT
        expect(result, isEmpty); // Aucune correspondance attendue
      });
    });
  });
}
