import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../util/functions.dart';

class GeminiRating extends StatelessWidget {
  const GeminiRating(
      {super.key, required this.onRating, required this.visible});

  final Function(double) onRating;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    pp('GeminiRating ... build, visible: $visible');
    return visible
        ? Card(
      elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.indigo,
                ),
                onRatingUpdate: (rating) {
                  pp('🍎🍎🍎 onRatingUpdate: rating: 🍎$rating 🍎 calling onRating() ...');
                  onRating(rating);
                },
              ),
            ),
          )
        : gapW8;
  }
}
