import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cellar_wine.dart';
import '../providers/cellar_providers.dart';
import '../widgets/annotation_widget.dart';
import '../widgets/rating_widget.dart';
import '../widgets/stock_controls.dart';

class WineDetailPage extends ConsumerWidget {
  final int wineId;

  const WineDetailPage({super.key, required this.wineId});

  Color _getWineColor(String couleur) {
    switch (couleur.toLowerCase()) {
      case 'rouge':
        return const Color(0xFF8B0000);
      case 'blanc':
        return const Color(0xFFF5DEB3);
      case 'rosé':
      case 'rose':
        return const Color(0xFFFFB6C1);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellarAsync = ref.watch(cellarNotifierProvider);
    final theme = Theme.of(context);

    return cellarAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Erreur de chargement', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.refresh(cellarNotifierProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (wines) {
        CellarWine? cellarWine;
        try {
          cellarWine = wines.firstWhere((cw) => cw.wine.id == wineId);
        } catch (_) {
          cellarWine = null;
        }

        if (cellarWine == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Détails')),
            body: const Center(child: Text('Vin non trouvé')),
          );
        }

        final wine = cellarWine.wine;
        final wineColor = _getWineColor(wine.couleur);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar avec image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        wine.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.wine_bar,
                              size: 80,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Badge couleur
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: wineColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            wine.couleur.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: wine.couleur.toLowerCase() == 'blanc'
                                  ? Colors.black87
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom et appellation
                      Text(
                        wine.nom,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wine.appellation,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Note
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Votre note',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RatingWidget(
                                rating: cellarWine.rating,
                                size: 32,
                                onRatingChanged: (rating) async {
                                  await ref
                                      .read(cellarNotifierProvider.notifier)
                                      .updateRating(wineId, rating);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stock
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: StockControls(
                                  stock: cellarWine.stock,
                                  onIncrement: () async {
                                    await ref
                                        .read(cellarNotifierProvider.notifier)
                                        .incrementStock(wineId);
                                  },
                                  onDecrement: () async {
                                    await ref
                                        .read(cellarNotifierProvider.notifier)
                                        .decrementStock(wineId);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Annotation
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: AnnotationWidget(
                            annotation: cellarWine.annotation,
                            onAnnotationChanged: (annotation) async {
                              await ref
                                  .read(cellarNotifierProvider.notifier)
                                  .updateAnnotation(wineId, annotation);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Informations détaillées
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informations',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                context,
                                Icons.location_on,
                                'Région',
                                wine.region,
                              ),
                              _buildInfoRow(
                                context,
                                Icons.eco,
                                'Cépage',
                                wine.cepage,
                              ),
                              _buildInfoRow(
                                context,
                                Icons.business,
                                'Producteur',
                                wine.producteur,
                              ),
                              if (wine.millesime != null)
                                _buildInfoRow(
                                  context,
                                  Icons.calendar_today,
                                  'Millésime',
                                  '${wine.millesime}',
                                ),
                              _buildInfoRow(
                                context,
                                Icons.percent,
                                'Degré d\'alcool',
                                '${wine.degreAlcool}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (wine.description.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  wine.description,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
