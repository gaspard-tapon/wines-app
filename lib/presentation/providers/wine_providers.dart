import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote_wine_datasource.dart';
import '../../data/repositories/wine_repository_impl.dart';
import '../../domain/entities/wine.dart';
import '../../domain/repositories/wine_repository.dart';
import '../../domain/usecases/get_available_wines.dart';

// DataSource provider
final remoteWineDataSourceProvider = Provider<RemoteWineDataSource>((ref) {
  return RemoteWineDataSource();
});

// Repository provider
final wineRepositoryProvider = Provider<WineRepository>((ref) {
  final dataSource = ref.watch(remoteWineDataSourceProvider);
  return WineRepositoryImpl(remoteDataSource: dataSource);
});

// Use case provider
final getAvailableWinesUseCaseProvider = Provider<GetAvailableWines>((ref) {
  final repository = ref.watch(wineRepositoryProvider);
  return GetAvailableWines(repository);
});

// State provider pour la liste des vins disponibles
final availableWinesProvider = FutureProvider<List<Wine>>((ref) async {
  final useCase = ref.watch(getAvailableWinesUseCaseProvider);
  return useCase();
});

// Provider pour la recherche dans les vins disponibles
final wineSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider pour les vins filtrés par recherche
final filteredAvailableWinesProvider = Provider<AsyncValue<List<Wine>>>((ref) {
  final winesAsync = ref.watch(availableWinesProvider);
  final searchQuery = ref.watch(wineSearchQueryProvider).toLowerCase();

  return winesAsync.whenData((wines) {
    if (searchQuery.isEmpty) return wines;
    return wines.where((wine) {
      return wine.nom.toLowerCase().contains(searchQuery) ||
          wine.appellation.toLowerCase().contains(searchQuery) ||
          wine.region.toLowerCase().contains(searchQuery) ||
          wine.producteur.toLowerCase().contains(searchQuery);
    }).toList();
  });
});
