import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wines_app/domain/entities/filter_sort_options.dart';
import 'package:wines_app/presentation/providers/cellar_providers.dart';

void main() {
  group('Filter Providers', () {
    // =========================================================================
    // FILTER SORT OPTIONS PROVIDER TESTS
    // =========================================================================

    group('filterSortOptionsProvider', () {
      test('devrait avoir des options par défaut', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // ACT
        final options = container.read(filterSortOptionsProvider);

        // ASSERT
        expect(options.searchQuery, isNull);
        expect(options.minRating, isNull);
        expect(options.colorFilter, equals(WineColor.all));
        expect(options.sortField, equals(SortField.addedAt));
        expect(options.ascending, isFalse);
      });

      test('devrait permettre de modifier searchQuery', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // ACT
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(searchQuery: 'Margaux');

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.searchQuery, equals('Margaux'));
      });

      test('devrait permettre de modifier colorFilter', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // ACT
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(colorFilter: WineColor.rouge);

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.colorFilter, equals(WineColor.rouge));
      });

      test('devrait permettre de modifier sortField', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // ACT
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(sortField: SortField.rating);

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.sortField, equals(SortField.rating));
      });

      test('devrait permettre de modifier ascending', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // ACT
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(ascending: true);

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.ascending, isTrue);
      });

      test('devrait permettre de modifier plusieurs options', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // ACT
        container.read(filterSortOptionsProvider.notifier).state = 
            FilterSortOptions(
              searchQuery: 'Bordeaux',
              minRating: 4,
              colorFilter: WineColor.rouge,
              sortField: SortField.rating,
              ascending: false,
              cepages: {'Merlot', 'Cabernet'},
            );

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.searchQuery, equals('Bordeaux'));
        expect(options.minRating, equals(4));
        expect(options.colorFilter, equals(WineColor.rouge));
        expect(options.sortField, equals(SortField.rating));
        expect(options.ascending, isFalse);
        expect(options.cepages, contains('Merlot'));
        expect(options.cepages, contains('Cabernet'));
      });

      test('devrait permettre de réinitialiser avec copyWith', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);
        
        // Set initial values
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(
              searchQuery: 'Test',
              minRating: 3,
            );

        // ACT - utiliser copyWith pour modifier une seule valeur
        final current = container.read(filterSortOptionsProvider);
        container.read(filterSortOptionsProvider.notifier).state = 
            current.copyWith(minRating: 5);

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.searchQuery, equals('Test')); // préservé
        expect(options.minRating, equals(5)); // modifié
      });

      test('devrait permettre de réinitialiser avec clearFilters', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);
        
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(
              searchQuery: 'Test',
              minRating: 3,
              colorFilter: WineColor.rouge,
              sortField: SortField.rating,
            );

        // ACT
        final current = container.read(filterSortOptionsProvider);
        container.read(filterSortOptionsProvider.notifier).state = 
            current.clearFilters();

        // ASSERT
        final options = container.read(filterSortOptionsProvider);
        expect(options.searchQuery, isNull);
        expect(options.minRating, isNull);
        expect(options.colorFilter, equals(WineColor.all));
        expect(options.sortField, equals(SortField.rating)); // tri conservé
      });
    });

    // =========================================================================
    // HASACTIVEFILTERS SCENARIOS
    // =========================================================================

    group('hasActiveFilters workflow', () {
      test('devrait détecter quand des filtres sont actifs', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Initialement pas de filtres
        var options = container.read(filterSortOptionsProvider);
        expect(options.hasActiveFilters, isFalse);

        // ACT - ajouter un filtre
        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(minRating: 3);

        // ASSERT
        options = container.read(filterSortOptionsProvider);
        expect(options.hasActiveFilters, isTrue);
      });

      test('devrait détecter quand les filtres sont réinitialisés', () {
        // ARRANGE
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(filterSortOptionsProvider.notifier).state = 
            const FilterSortOptions(
              searchQuery: 'Test',
              minRating: 4,
            );

        var options = container.read(filterSortOptionsProvider);
        expect(options.hasActiveFilters, isTrue);

        // ACT
        container.read(filterSortOptionsProvider.notifier).state = 
            options.clearFilters();

        // ASSERT
        options = container.read(filterSortOptionsProvider);
        expect(options.hasActiveFilters, isFalse);
      });
    });
  });
}
