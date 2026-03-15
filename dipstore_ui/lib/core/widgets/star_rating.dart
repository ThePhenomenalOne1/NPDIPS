import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Function(double)? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged?.call(index + 1.0),
          child: Icon(
            index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}
