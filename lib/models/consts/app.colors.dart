import 'package:flutter/material.dart';
import 'package:futdraw/models/theme.color.set.dart';

class CommonsColors {
  static const Color scaffoldBackgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color onPrimaryColor = Colors.white;
  static const Color onSurfaceColor = Colors.white;
  static const Color unselectedLabelColor = Colors.white;
  static const Color bodyMediumColor = Color(0xFFBDBDBD);
  static const Color iconColor = Color.fromARGB(255, 255, 255, 255);
}

class ThemeColors {
  static const ThemeColorSet green = ThemeColorSet(
    primary: Color.fromARGB(255, 57, 105, 59),
    secondary: Color.fromARGB(255, 31, 78, 32),
    label: Color.fromARGB(255, 57, 105, 59),
    thumb: Color.fromARGB(255, 57, 105, 59),
    overlay: Color.fromARGB(48, 57, 105, 59),
    selected: Color.fromARGB(255, 57, 105, 59),
  );

  static const ThemeColorSet blue = ThemeColorSet(
    primary: Colors.blue,
    secondary: Color.fromARGB(255, 32, 30, 185),
    label: Colors.blue,
    thumb: Colors.blue,
    overlay: Color.fromARGB(48, 0, 0, 255),
    selected: Colors.blue,
  );

  static const ThemeColorSet purple = ThemeColorSet(
    primary: Color.fromARGB(255, 128, 0, 128),
    secondary: Color.fromARGB(255, 75, 0, 130),
    label: Color.fromARGB(255, 128, 0, 128),
    thumb: Color.fromARGB(255, 128, 0, 128),
    overlay: Color.fromARGB(48, 128, 0, 128),
    selected: Color.fromARGB(255, 128, 0, 128),
  );

  static const ThemeColorSet red = ThemeColorSet(
    primary: Color.fromARGB(255, 146, 48, 41),
    secondary: Color.fromARGB(255, 109, 1, 1),
    label: Color.fromARGB(255, 146, 48, 41),
    thumb: Color.fromARGB(255, 146, 48, 41),
    overlay: Color.fromARGB(255, 109, 1, 1),
    selected: Color.fromARGB(255, 146, 48, 41),
  );
}
