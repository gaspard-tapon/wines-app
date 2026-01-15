import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/domain/entities/filter_sort_options.dart';

void main() {
  group('FilterSortOptions', () {
    // =========================================================================
    // CREATION TESTS
    // =========================================================================

    group('création', () {
      test('devrait créer des options avec les valeurs par défaut', () {
        // ARRANGE & ACT
        const options = FilterSortOptions();

        // ASSERT
        expect(options.searchQuery, isNull);
        expect(options.minRating, isNull);
        expect(options.colorFilter, equals(WineColor.all));
        expect(options.minMillesime, isNull);
        expect(options.maxMillesime, isNull);
        expect(options.hasStock, isNull);
        expect(options.cepages, isEmpty);
        expect(options.sortField, equals(SortField.addedAt));
        expect(options.ascending, isFalse);
      });

      test('devrait créer des options avec des valeurs personnalisées', () {
        // ARRANGE
        const searchQuery = 'Margaux';
        const minRating = 4;
        const colorFilter = WineColor.rouge;
        const minMillesime = 2015;
        const maxMillesime = 2020;
        const hasStock = true;
        final cepages = {'Cabernet', 'Merlot'};
        const sortField = SortField.rating;
        const ascending = true;

        // ACT
        final options = FilterSortOptions(
          searchQuery: searchQuery,
          minRating: minRating,
          colorFilter: colorFilter,
          minMillesime: minMillesime,
          maxMillesime: maxMillesime,
          hasStock: hasStock,
          cepages: cepages,
          sortField: sortField,
          ascending: ascending,
        );

        // ASSERT
        expect(options.searchQuery, equals(searchQuery));
        expect(options.minRating, equals(minRating));
        expect(options.colorFilter, equals(colorFilter));
        expect(options.minMillesime, equals(minMillesime));
        expect(options.maxMillesime, equals(maxMillesime));
        expect(options.hasStock, equals(hasStock));
        expect(options.cepages, equals(cepages));
        expect(options.sortField, equals(sortField));
        expect(options.ascending, equals(ascending));
      });
    });

    // =========================================================================
    // COPYWITH TESTS
    // =========================================================================

    group('copyWith', () {
      test('devrait créer une copie identique sans paramètres', () {
        // ARRANGE
        final original = FilterSortOptions(
          searchQuery: 'test',
          minRating: 3,
          colorFilter: WineColor.rouge,
        );

        // ACT
        final copy = original.copyWith();

        // ASSERT
        expect(copy.searchQuery, equals(original.searchQuery));
        expect(copy.minRating, equals(original.minRating));
        expect(copy.colorFilter, equals(original.colorFilter));
      });

      test('devrait modifier uniquement searchQuery', () {
        // ARRANGE
        const original = FilterSortOptions(
          searchQuery: 'ancien',
          minRating: 4,
        );

        // ACT
        final copy = original.copyWith(searchQuery: 'nouveau');

        // ASSERT
        expect(copy.searchQuery, equals('nouveau'));
        expect(copy.minRating, equals(4));
      });

      test('devrait modifier plusieurs options à la fois', () {
        // ARRANGE
        const original = FilterSortOptions();

        // ACT
        final copy = original.copyWith(
          colorFilter: WineColor.blanc,
          sortField: SortField.name,
          ascending: true,
        );

        // ASSERT
        expect(copy.colorFilter, equals(WineColor.blanc));
        expect(copy.sortField, equals(SortField.name));
        expect(copy.ascending, isTrue);
      });
    });

    // =========================================================================
    // CLEARFILTERS TESTS
    // =========================================================================

    group('clearFilters', () {
      test('devrait réinitialiser tous les filtres mais garder le tri', () {
        // ARRANGE
        final original = FilterSortOptions(
          searchQuery: 'test',
          minRating: 4,
          colorFilter: WineColor.rouge,
          minMillesime: 2015,
          maxMillesime: 2020,
          hasStock: true,
          cepages: {'Merlot'},
          sortField: SortField.rating,
          ascending: true,
        );

        // ACT
        final cleared = original.clearFilters();

        // ASSERT
        expect(cleared.searchQuery, isNull);
        expect(cleared.minRating, isNull);
        expect(cleared.colorFilter, equals(WineColor.all));
        expect(cleared.minMillesime, isNull);
        expect(cleared.maxMillesime, isNull);
        expect(cleared.hasStock, isNull);
        expect(cleared.cepages, isEmpty);
        // Le tri est conservé
        expect(cleared.sortField, equals(SortField.rating));
        expect(cleared.ascending, isTrue);
      });

      test('devrait retourner des options sans filtres si déjà vides', () {
        // ARRANGE
        const original = FilterSortOptions();

        // ACT
        final cleared = original.clearFilters();

        // ASSERT
        expect(cleared.hasActiveFilters, isFalse);
      });
    });

    // =========================================================================
    // HASACTIVEFILTERS TESTS
    // =========================================================================

    group('hasActiveFilters', () {
      test('devrait retourner false si aucun filtre actif', () {
        // ARRANGE
        const options = FilterSortOptions();

        // ACT & ASSERT
        expect(options.hasActiveFilters, isFalse);
      });

      test('devrait retourner true si searchQuery est défini', () {
        // ARRANGE
        const options = FilterSortOptions(searchQuery: 'test');

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner true si minRating est défini', () {
        // ARRANGE
        const options = FilterSortOptions(minRating: 3);

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner true si colorFilter n\'est pas "all"', () {
        // ARRANGE
        const options = FilterSortOptions(colorFilter: WineColor.rouge);

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner true si minMillesime est défini', () {
        // ARRANGE
        const options = FilterSortOptions(minMillesime: 2015);

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner true si maxMillesime est défini', () {
        // ARRANGE
        const options = FilterSortOptions(maxMillesime: 2020);

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner true si hasStock est défini', () {
        // ARRANGE
        const options = FilterSortOptions(hasStock: true);

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner true si cepages n\'est pas vide', () {
        // ARRANGE
        final options = FilterSortOptions(cepages: {'Merlot'});

        // ACT & ASSERT
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait retourner false si seulement tri est modifié', () {
        // ARRANGE
        const options = FilterSortOptions(
          sortField: SortField.name,
          ascending: true,
        );

        // ACT & ASSERT
        expect(options.hasActiveFilters, isFalse);
      });
    });
  });

  // ===========================================================================
  // ENUMS TESTS
  // ===========================================================================

  group('SortField Enum', () {
    test('devrait avoir toutes les valeurs attendues', () {
      // ARRANGE & ACT & ASSERT
      expect(SortField.values, contains(SortField.name));
      expect(SortField.values, contains(SortField.rating));
      expect(SortField.values, contains(SortField.millesime));
      expect(SortField.values, contains(SortField.stock));
      expect(SortField.values, contains(SortField.addedAt));
      expect(SortField.values.length, equals(5));
    });
  });

  group('WineColor Enum', () {
    test('devrait avoir toutes les valeurs attendues', () {
      // ARRANGE & ACT & ASSERT
      expect(WineColor.values, contains(WineColor.all));
      expect(WineColor.values, contains(WineColor.rouge));
      expect(WineColor.values, contains(WineColor.blanc));
      expect(WineColor.values, contains(WineColor.rose));
      expect(WineColor.values.length, equals(4));
    });
  });
}
