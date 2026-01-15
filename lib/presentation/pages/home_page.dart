import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/filter_sort_options.dart';
import '../providers/cellar_providers.dart';
import '../widgets/filter_sort_dialog.dart';
import '../widgets/wine_card.dart';
import 'available_wines_page.dart';
import 'wine_detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellarAsync = ref.watch(filteredCellarWinesProvider);
    final filterOptions = ref.watch(filterSortOptionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Cave'),
        centerTitle: true,
        actions: [
          // Indicateur de filtres actifs
          if (filterOptions.hasActiveFilters)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final newOptions = await showFilterSortDialog(
                context,
                filterOptions,
              );
              if (newOptions != null) {
                ref.read(filterSortOptionsProvider.notifier).state = newOptions;
              }
            },
            tooltip: 'Filtrer et trier',
          ),
        ],
      ),
      body: cellarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(cellarNotifierProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (wines) {
          if (wines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wine_bar_outlined,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    filterOptions.hasActiveFilters
                        ? 'Aucun vin ne correspond aux filtres'
                        : 'Votre cave est vide',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filterOptions.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        ref.read(filterSortOptionsProvider.notifier).state =
                            const FilterSortOptions();
                      },
                      child: const Text('Réinitialiser les filtres'),
                    )
                  else
                    Text(
                      'Ajoutez des vins depuis le catalogue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(cellarNotifierProvider.notifier).loadCellar();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wines.length,
              itemBuilder: (context, index) {
                final cellarWine = wines[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CellarWineCard(
                    cellarWine: cellarWine,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              WineDetailPage(wineId: cellarWine.wine.id),
                        ),
                      );
                    },
                    onIncrement: () {
                      ref
                          .read(cellarNotifierProvider.notifier)
                          .incrementStock(cellarWine.wine.id);
                    },
                    onDecrement: () {
                      ref
                          .read(cellarNotifierProvider.notifier)
                          .decrementStock(cellarWine.wine.id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AvailableWinesPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un vin'),
      ),
    );
  }
}
