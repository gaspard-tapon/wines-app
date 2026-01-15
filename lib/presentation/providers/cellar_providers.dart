import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_cellar_datasource.dart';
import '../../data/repositories/cellar_repository_impl.dart';
import '../../domain/entities/cellar_wine.dart';
import '../../domain/entities/filter_sort_options.dart';
import '../../domain/entities/wine.dart';
import '../../domain/repositories/cellar_repository.dart';
import '../../domain/usecases/add_wine_to_cellar.dart';
import '../../domain/usecases/decrement_stock.dart';
import '../../domain/usecases/filter_and_sort_cellar_wines.dart';
import '../../domain/usecases/get_cellar_wines.dart';
import '../../domain/usecases/get_wine_details.dart';
import '../../domain/usecases/increment_stock.dart';
import '../../domain/usecases/update_wine_annotation.dart';
import '../../domain/usecases/update_wine_rating.dart';

// DataSource provider
final localCellarDataSourceProvider = Provider<LocalCellarDataSource>((ref) {
  return LocalCellarDataSource();
});

// Repository provider
final cellarRepositoryProvider = Provider<CellarRepository>((ref) {
  final dataSource = ref.watch(localCellarDataSourceProvider);
  return CellarRepositoryImpl(localDataSource: dataSource);
});

// Use case providers
final getCellarWinesUseCaseProvider = Provider<GetCellarWines>((ref) {
  final repository = ref.watch(cellarRepositoryProvider);
  return GetCellarWines(repository);
});

final addWineToCellarUseCaseProvider = Provider<AddWineToCellar>((ref) {
  final repository = ref.watch(cellarRepositoryProvider);
  return AddWineToCellar(repository);
});

final getWineDetailsUseCaseProvider = Provider<GetWineDetails>((ref) {
  final repository = ref.watch(cellarRepositoryProvider);
  return GetWineDetails(repository);
});

final incrementStockUseCaseProvider = Provider<IncrementStock>((ref) {
  final repository = ref.watch(cellarRepositoryProvider);
  return IncrementStock(repository);
});

final decrementStockUseCaseProvider = Provider<DecrementStock>((ref) {
  final repository = ref.watch(cellarRepositoryProvider);
  return DecrementStock(repository);
});

final updateWineRatingUseCaseProvider = Provider<UpdateWineRating>((ref) {
  final repository = ref.watch(cellarRepositoryProvider);
  return UpdateWineRating(repository);
});

final updateWineAnnotationUseCaseProvider = Provider<UpdateWineAnnotation>((
  ref,
) {
  final repository = ref.watch(cellarRepositoryProvider);
  return UpdateWineAnnotation(repository);
});

final filterAndSortUseCaseProvider = Provider<FilterAndSortCellarWines>((ref) {
  return FilterAndSortCellarWines();
});

// State notifier pour la cave
class CellarNotifier extends StateNotifier<AsyncValue<List<CellarWine>>> {
  final GetCellarWines _getCellarWines;
  final AddWineToCellar _addWineToCellar;
  final IncrementStock _incrementStock;
  final DecrementStock _decrementStock;
  final UpdateWineRating _updateRating;
  final UpdateWineAnnotation _updateAnnotation;

  CellarNotifier({
    required GetCellarWines getCellarWines,
    required AddWineToCellar addWineToCellar,
    required IncrementStock incrementStock,
    required DecrementStock decrementStock,
    required UpdateWineRating updateRating,
    required UpdateWineAnnotation updateAnnotation,
  }) : _getCellarWines = getCellarWines,
       _addWineToCellar = addWineToCellar,
       _incrementStock = incrementStock,
       _decrementStock = decrementStock,
       _updateRating = updateRating,
       _updateAnnotation = updateAnnotation,
       super(const AsyncValue.loading()) {
    loadCellar();
  }

  Future<void> loadCellar() async {
    state = const AsyncValue.loading();
    try {
      final wines = await _getCellarWines();
      state = AsyncValue.data(wines);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWine(Wine wine) async {
    try {
      await _addWineToCellar(wine);
      await loadCellar();
    } catch (e) {
      // Recharger quand même pour synchro
      await loadCellar();
      rethrow;
    }
  }

  Future<void> incrementStock(int wineId) async {
    try {
      await _incrementStock(wineId);
      await loadCellar();
    } catch (e) {
      await loadCellar();
      rethrow;
    }
  }

  Future<void> decrementStock(int wineId) async {
    try {
      await _decrementStock(wineId);
      await loadCellar();
    } catch (e) {
      await loadCellar();
      rethrow;
    }
  }

  Future<void> updateRating(int wineId, int rating) async {
    try {
      await _updateRating(wineId, rating);
      await loadCellar();
    } catch (e) {
      await loadCellar();
      rethrow;
    }
  }

  Future<void> updateAnnotation(int wineId, String? annotation) async {
    try {
      await _updateAnnotation(wineId, annotation);
      await loadCellar();
    } catch (e) {
      await loadCellar();
      rethrow;
    }
  }
}

// Provider pour le notifier de la cave
final cellarNotifierProvider =
    StateNotifierProvider<CellarNotifier, AsyncValue<List<CellarWine>>>((ref) {
      return CellarNotifier(
        getCellarWines: ref.watch(getCellarWinesUseCaseProvider),
        addWineToCellar: ref.watch(addWineToCellarUseCaseProvider),
        incrementStock: ref.watch(incrementStockUseCaseProvider),
        decrementStock: ref.watch(decrementStockUseCaseProvider),
        updateRating: ref.watch(updateWineRatingUseCaseProvider),
        updateAnnotation: ref.watch(updateWineAnnotationUseCaseProvider),
      );
    });

// Provider pour les options de filtrage et tri
final filterSortOptionsProvider = StateProvider<FilterSortOptions>((ref) {
  return const FilterSortOptions();
});

// Provider pour les vins de la cave filtrés et triés
final filteredCellarWinesProvider = Provider<AsyncValue<List<CellarWine>>>((
  ref,
) {
  final cellarAsync = ref.watch(cellarNotifierProvider);
  final options = ref.watch(filterSortOptionsProvider);
  final filterAndSort = ref.watch(filterAndSortUseCaseProvider);

  return cellarAsync.whenData((wines) {
    return filterAndSort(wines, options);
  });
});

// Provider pour obtenir un vin spécifique de la cave
final cellarWineByIdProvider = Provider.family<CellarWine?, int>((ref, wineId) {
  final cellarAsync = ref.watch(cellarNotifierProvider);
  return cellarAsync.maybeWhen(
    data: (wines) {
      try {
        return wines.firstWhere((cw) => cw.wine.id == wineId);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});

// Provider pour vérifier si un vin est dans la cave
final isWineInCellarProvider = Provider.family<bool, int>((ref, wineId) {
  final cellarAsync = ref.watch(cellarNotifierProvider);
  return cellarAsync.whenOrNull(
        data: (wines) => wines.any((cw) => cw.wine.id == wineId),
      ) ??
      false;
});
