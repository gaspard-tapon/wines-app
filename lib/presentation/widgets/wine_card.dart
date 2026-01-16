import 'package:flutter/material.dart';
import '../../domain/entities/cellar_wine.dart';
import '../../domain/entities/wine.dart';
import 'rating_widget.dart';

class WineCard extends StatelessWidget {
  final Wine wine;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCellar;
  final bool isInCellar;

  const WineCard({
    super.key,
    required this.wine,
    this.onTap,
    this.onAddToCellar,
    this.isInCellar = false,
  });

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wineColor = _getWineColor(wine.couleur);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge couleur
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    wine.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.wine_bar,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: wineColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      wine.couleur.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: wine.couleur.toLowerCase() == 'blanc'
                            ? Colors.black87
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isInCellar)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wine.nom,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wine.appellation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          wine.region,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (wine.millesime != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${wine.millesime}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (onAddToCellar != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onAddToCellar,
                        icon: Icon(isInCellar ? Icons.add : Icons.add_circle),
                        label: Text(isInCellar ? 'Ajouter +1' : 'Ajouter'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CellarWineCard extends StatelessWidget {
  final CellarWine cellarWine;
  final VoidCallback? onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CellarWineCard({
    super.key,
    required this.cellarWine,
    this.onTap,
    this.onIncrement,
    this.onDecrement,
  });

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wine = cellarWine.wine;
    final wineColor = _getWineColor(wine.couleur);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 100,
                  child: Stack(
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
                              size: 32,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          color: wineColor,
                          child: Text(
                            wine.couleur.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: wine.couleur.toLowerCase() == 'blanc'
                                  ? Colors.black87
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Contenu
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            wine.nom,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (wine.millesime != null) ...[
                          Text(
                            '${wine.millesime}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),
                    Text(
                      wine.appellation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingDisplay(rating: cellarWine.rating, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
