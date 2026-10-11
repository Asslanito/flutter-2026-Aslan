import 'package:flutter/material.dart';

enum Category {
  coding('Coding', Icons.code),
  maths('Maths', Icons.calculate_outlined),
  english('English', Icons.translate),
  physics('Physics', Icons.science_outlined),
  design('Design', Icons.draw_outlined);

  const Category(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    Category.coding => scheme.primary,
    Category.maths => scheme.secondary,
    Category.english => scheme.tertiary,
    Category.physics => scheme.onPrimaryContainer,
    Category.design => scheme.onTertiaryContainer,
  };
}
