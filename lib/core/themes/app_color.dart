import 'package:flutter/material.dart';

class AppColors {
  static Color containerSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return brightness == Brightness.light
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainer;
  }
}
