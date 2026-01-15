import 'package:flutter/material.dart';
import '../../domain/entities/filter_sort_options.dart';

class FilterSortDialog extends StatefulWidget {
  final FilterSortOptions currentOptions;

  const FilterSortDialog({
    super.key,
    required this.currentOptions,
  });

  @override
  State<FilterSortDialog> createState() => _FilterSortDialogState();
}

class _FilterSortDialogState extends State<FilterSortDialog> {
  late FilterSortOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.currentOptions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtres et tri',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (_options.hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _options = _options.clearFilters();
                        });
                      },
                      child: const Text('Réinitialiser'),
                    ),
                ],
              ),
              const Divider(),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tri
                      _buildSectionTitle('Trier par'),
                      _buildSortOptions(),
                      const SizedBox(height: 16),

                      // Filtres
                      _buildSectionTitle('Filtres'),
                      const SizedBox(height: 8),

                      // Filtre par couleur
                      _buildSubtitle('Couleur'),
                      _buildColorFilter(),
                      const SizedBox(height: 12),

                      // Filtre par note minimum
                      _buildSubtitle('Note minimum'),
                      _buildRatingFilter(),
                      const SizedBox(height: 12),

                      // Filtre par stock
                      _buildSubtitle('Stock'),
                      _buildStockFilter(),
                      const SizedBox(height: 12),

                      // Filtre par millésime
                      _buildSubtitle('Millésime'),
                      _buildMillesimeFilter(),
                    ],
                  ),
                ),
              ),

              const Divider(),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_options),
                    child: const Text('Appliquer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        _buildSortTile(SortField.addedAt, 'Date d\'ajout'),
        _buildSortTile(SortField.name, 'Nom'),
        _buildSortTile(SortField.rating, 'Note'),
        _buildSortTile(SortField.millesime, 'Millésime'),
        _buildSortTile(SortField.stock, 'Stock'),
      ],
    );
  }

  Widget _buildSortTile(SortField field, String label) {
    final isSelected = _options.sortField == field;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      leading: Radio<SortField>(
        value: field,
        groupValue: _options.sortField,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _options = _options.copyWith(sortField: value);
            });
          }
        },
      ),
      trailing: isSelected
          ? IconButton(
              icon: Icon(
                _options.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
              onPressed: () {
                setState(() {
                  _options = _options.copyWith(ascending: !_options.ascending);
                });
              },
            )
          : null,
      onTap: () {
        setState(() {
          _options = _options.copyWith(sortField: field);
        });
      },
    );
  }

  Widget _buildColorFilter() {
    return Wrap(
      spacing: 8,
      children: WineColor.values.map((color) {
        final isSelected = _options.colorFilter == color;
        String label;
        Color? chipColor;
        switch (color) {
          case WineColor.all:
            label = 'Tous';
          case WineColor.rouge:
            label = 'Rouge';
            chipColor = const Color(0xFF8B0000);
          case WineColor.blanc:
            label = 'Blanc';
            chipColor = const Color(0xFFF5DEB3);
          case WineColor.rose:
            label = 'Rosé';
            chipColor = const Color(0xFFFFB6C1);
        }
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _options = _options.copyWith(colorFilter: color);
            });
          },
          backgroundColor: chipColor?.withValues(alpha: 0.3),
          selectedColor: chipColor?.withValues(alpha: 0.7),
        );
      }).toList(),
    );
  }

  Widget _buildRatingFilter() {
    return Wrap(
      spacing: 8,
      children: [null, 1, 2, 3, 4, 5].map((rating) {
        final isSelected = _options.minRating == rating;
        return FilterChip(
          label: rating == null
              ? const Text('Tous')
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rating+'),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, size: 14),
                  ],
                ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _options = _options.copyWith(minRating: rating);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildStockFilter() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Tous'),
          selected: _options.hasStock == null,
          onSelected: (selected) {
            setState(() {
              _options = FilterSortOptions(
                searchQuery: _options.searchQuery,
                minRating: _options.minRating,
                colorFilter: _options.colorFilter,
                minMillesime: _options.minMillesime,
                maxMillesime: _options.maxMillesime,
                hasStock: null,
                cepages: _options.cepages,
                sortField: _options.sortField,
                ascending: _options.ascending,
              );
            });
          },
        ),
        FilterChip(
          label: const Text('En stock'),
          selected: _options.hasStock == true,
          onSelected: (selected) {
            setState(() {
              _options = _options.copyWith(hasStock: selected ? true : null);
            });
          },
        ),
        FilterChip(
          label: const Text('Épuisé'),
          selected: _options.hasStock == false,
          onSelected: (selected) {
            setState(() {
              _options = _options.copyWith(hasStock: selected ? false : null);
            });
          },
        ),
      ],
    );
  }

  Widget _buildMillesimeFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Min',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: _options.minMillesime?.toString() ?? '',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              setState(() {
                _options = FilterSortOptions(
                  searchQuery: _options.searchQuery,
                  minRating: _options.minRating,
                  colorFilter: _options.colorFilter,
                  minMillesime: parsed,
                  maxMillesime: _options.maxMillesime,
                  hasStock: _options.hasStock,
                  cepages: _options.cepages,
                  sortField: _options.sortField,
                  ascending: _options.ascending,
                );
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Max',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: _options.maxMillesime?.toString() ?? '',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              setState(() {
                _options = FilterSortOptions(
                  searchQuery: _options.searchQuery,
                  minRating: _options.minRating,
                  colorFilter: _options.colorFilter,
                  minMillesime: _options.minMillesime,
                  maxMillesime: parsed,
                  hasStock: _options.hasStock,
                  cepages: _options.cepages,
                  sortField: _options.sortField,
                  ascending: _options.ascending,
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

Future<FilterSortOptions?> showFilterSortDialog(
  BuildContext context,
  FilterSortOptions currentOptions,
) {
  return showDialog<FilterSortOptions>(
    context: context,
    builder: (context) => FilterSortDialog(currentOptions: currentOptions),
  );
}
