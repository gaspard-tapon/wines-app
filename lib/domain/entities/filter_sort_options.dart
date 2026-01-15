enum SortField {
  name,
  rating,
  millesime,
  stock,
  addedAt,
}

enum WineColor {
  all,
  rouge,
  blanc,
  rose,
}

class FilterSortOptions {
  final String? searchQuery;
  final int? minRating;
  final WineColor colorFilter;
  final int? minMillesime;
  final int? maxMillesime;
  final bool? hasStock;
  final Set<String> cepages;
  final SortField sortField;
  final bool ascending;

  const FilterSortOptions({
    this.searchQuery,
    this.minRating,
    this.colorFilter = WineColor.all,
    this.minMillesime,
    this.maxMillesime,
    this.hasStock,
    this.cepages = const {},
    this.sortField = SortField.addedAt,
    this.ascending = false,
  });

  FilterSortOptions copyWith({
    String? searchQuery,
    int? minRating,
    WineColor? colorFilter,
    int? minMillesime,
    int? maxMillesime,
    bool? hasStock,
    Set<String>? cepages,
    SortField? sortField,
    bool? ascending,
  }) {
    return FilterSortOptions(
      searchQuery: searchQuery ?? this.searchQuery,
      minRating: minRating ?? this.minRating,
      colorFilter: colorFilter ?? this.colorFilter,
      minMillesime: minMillesime ?? this.minMillesime,
      maxMillesime: maxMillesime ?? this.maxMillesime,
      hasStock: hasStock ?? this.hasStock,
      cepages: cepages ?? this.cepages,
      sortField: sortField ?? this.sortField,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Réinitialiser les filtres
  FilterSortOptions clearFilters() {
    return FilterSortOptions(
      sortField: sortField,
      ascending: ascending,
    );
  }

  /// Vérifie si des filtres sont actifs
  bool get hasActiveFilters =>
      searchQuery != null ||
      minRating != null ||
      colorFilter != WineColor.all ||
      minMillesime != null ||
      maxMillesime != null ||
      hasStock != null ||
      cepages.isNotEmpty;
}
