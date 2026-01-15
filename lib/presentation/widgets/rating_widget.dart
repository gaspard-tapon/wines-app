import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final bool readOnly;

  const RatingWidget({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        
        return GestureDetector(
          onTap: readOnly ? null : () => onRatingChanged?.call(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: isFilled ? Colors.amber : Colors.grey,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final int rating;
  final double size;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return RatingWidget(
      rating: rating,
      size: size,
      readOnly: true,
    );
  }
}
