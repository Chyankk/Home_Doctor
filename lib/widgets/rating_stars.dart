import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final MainAxisAlignment mainAxisAlignment;
  final Color color;
  final double size;

  StarRating({
    this.starCount = 5,
    this.rating = .0,
    this.onRatingChanged,
    this.color,
    this.size,
    this.mainAxisAlignment,
  });

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        size: size ?? 32.0,
        color: Theme.of(context).buttonColor,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        size: size ?? 32.0,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      icon = new Icon(
        Icons.star,
        size: size ?? 32.0,
        color: color ?? Theme.of(context).primaryColor,
      );
    }
    return new InkResponse(
      onTap:
          onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        children:
            new List.generate(starCount, (index) => buildStar(context, index)));
  }
}
