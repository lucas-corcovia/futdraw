import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';

class Configuration {
  GenerationAlgorithm generationAlgorithm;
  ThemeColor themeColor;

  Configuration({required this.generationAlgorithm, required this.themeColor});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      generationAlgorithm: getGenerationAlgorithm(json),
      themeColor: getThemeColor(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generationAlgorithm': generationAlgorithm.index,
      'themeColor': themeColor.index,
    };
  }

  static GenerationAlgorithm getGenerationAlgorithm(Map<String, dynamic> json) {
    return GenerationAlgorithm.values[json['generationAlgorithm']];
  }

  static ThemeColor getThemeColor(Map<String, dynamic> json) {
    return ThemeColor.values[json['themeColor']];
  }

  static String getColorThemeName(ThemeColor themeColor) {
    switch (themeColor) {
      case ThemeColor.green:
        return 'Verde';
      case ThemeColor.blue:
        return 'Azul';
      case ThemeColor.red:
        return 'Vermelho';
      case ThemeColor.purple:
        return 'Roxo';
    }
  }
}
