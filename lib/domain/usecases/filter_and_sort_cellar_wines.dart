import '../entities/cellar_wine.dart';
import '../entities/filter_sort_options.dart';

class FilterAndSortCellarWines {
  FilterAndSortCellarWines();

  /// Filtre et trie une liste de vins selon les options fournies
  List<CellarWine> call(List<CellarWine> wines, FilterSortOptions options) {
    var filteredWines = wines.toList();

    // Appliquer les filtres
    filteredWines = _applyFilters(filteredWines, options);

    // Appliquer le tri
    filteredWines = _applySort(filteredWines, options);

    return filteredWines;
  }

  List<CellarWine> _applyFilters(
    List<CellarWine> wines,
    FilterSortOptions options,
  ) {
    return wines.where((cellarWine) {
      // Filtre par recherche textuelle (nom)
      if (options.searchQuery != null && options.searchQuery!.isNotEmpty) {
        final query = options.searchQuery!.toLowerCase();
        if (!cellarWine.wine.nom.toLowerCase().contains(query) &&
            !cellarWine.wine.appellation.toLowerCase().contains(query) &&
            !cellarWine.wine.producteur.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtre par note minimum
      if (options.minRating != null && cellarWine.rating < options.minRating!) {
        return false;
      }

      // Filtre par couleur
      if (options.colorFilter != WineColor.all) {
        final wineColor = cellarWine.wine.couleur.toLowerCase();
        switch (options.colorFilter) {
          case WineColor.rouge:
            if (wineColor != 'rouge') return false;
          case WineColor.blanc:
            if (wineColor != 'blanc') return false;
          case WineColor.rose:
            if (wineColor != 'rosé' && wineColor != 'rose') return false;
          case WineColor.all:
            break;
        }
      }

      // Filtre par millésime minimum
      if (options.minMillesime != null) {
        if (cellarWine.wine.millesime == null ||
            cellarWine.wine.millesime! < options.minMillesime!) {
          return false;
        }
      }

      // Filtre par millésime maximum
      if (options.maxMillesime != null) {
        if (cellarWine.wine.millesime == null ||
            cellarWine.wine.millesime! > options.maxMillesime!) {
          return false;
        }
      }

      // Filtre par stock
      if (options.hasStock != null) {
        if (options.hasStock! && cellarWine.stock <= 0) return false;
        if (!options.hasStock! && cellarWine.stock > 0) return false;
      }

      // Filtre par cépages
      if (options.cepages.isNotEmpty) {
        final wineCepages = cellarWine.wine.cepage
            .toLowerCase()
            .split(', ')
            .map((e) => e.trim());
        final hasMatchingCepage = wineCepages.any(
          (c) => options.cepages.any((oc) => c.contains(oc.toLowerCase())),
        );
        if (!hasMatchingCepage) return false;
      }

      return true;
    }).toList();
  }

  List<CellarWine> _applySort(
    List<CellarWine> wines,
    FilterSortOptions options,
  ) {
    wines.sort((a, b) {
      int comparison;
      switch (options.sortField) {
        case SortField.name:
          comparison = a.wine.nom.compareTo(b.wine.nom);
        case SortField.rating:
          comparison = a.rating.compareTo(b.rating);
        case SortField.millesime:
          final aMillesime = a.wine.millesime ?? 0;
          final bMillesime = b.wine.millesime ?? 0;
          comparison = aMillesime.compareTo(bMillesime);
        case SortField.stock:
          comparison = a.stock.compareTo(b.stock);
        case SortField.addedAt:
          comparison = a.addedAt.compareTo(b.addedAt);
      }
      return options.ascending ? comparison : -comparison;
    });
    return wines;
  }
}
