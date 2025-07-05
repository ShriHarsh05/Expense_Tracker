import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<Color> accentColorNotifier =
      ValueNotifier<Color>(Colors.teal);
  static ThemeData getTheme(Color seedColor) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
      ),
      useMaterial3: true,
    );
  }

  static void updateAccentColor(Color newColor) {
    if (accentColorNotifier.value != newColor) {
      accentColorNotifier.value = newColor;
    }
  }
}
