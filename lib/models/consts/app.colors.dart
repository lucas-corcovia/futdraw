import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/theme_color.dart';

class CommonsColors {
  static const Color avatarFieldBackgroundColor = Color.from(
    alpha: 1.0000,
    red: 0.7490,
    green: 0.7569,
    blue: 1.0000,
  );
}

class ThemeColors {
  static const Map<ThemeColor, Color> seedColors = {
    ThemeColor.esmeralda: Color(0xFF059669),
    ThemeColor.oceano: Color(0xFF1D4ED8),
    ThemeColor.violeta: Color(0xFF7C3AED),
    ThemeColor.carmesim: Color(0xFFDC2626),
    ThemeColor.ambar: Color(0xFFD97706),
    ThemeColor.petroleo: Color(0xFF0891B2),
    ThemeColor.rosa: Color(0xFFDB2777),
    ThemeColor.laranja: Color(0xFFEA580C),
  };
}
