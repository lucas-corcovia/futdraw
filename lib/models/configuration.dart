import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';

class Configuration {
  GenerationAlgorithm generationAlgorithm;
  ThemeColor themeColor;
  bool isDarkMode;
  bool gerarIndependenteDaPosicao;

  Configuration({
    required this.generationAlgorithm,
    required this.themeColor,
    required this.isDarkMode,
    this.gerarIndependenteDaPosicao = false,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      generationAlgorithm: _parseAlgorithm(json),
      themeColor: _parseThemeColor(json),
      isDarkMode: (json['isDarkMode'] as bool?) ?? true,
      gerarIndependenteDaPosicao: (json['gerarIndependenteDaPosicao'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generationAlgorithm': generationAlgorithm.index,
      'themeColor': themeColor.index,
      'isDarkMode': isDarkMode,
      'gerarIndependenteDaPosicao': gerarIndependenteDaPosicao,
    };
  }

  static GenerationAlgorithm _parseAlgorithm(Map<String, dynamic> json) {
    final index = json['generationAlgorithm'] as int? ?? 0;
    if (index >= 0 && index < GenerationAlgorithm.values.length) {
      return GenerationAlgorithm.values[index];
    }
    return GenerationAlgorithm.balanced;
  }

  static ThemeColor _parseThemeColor(Map<String, dynamic> json) {
    final index = json['themeColor'] as int? ?? 0;
    if (index >= 0 && index < ThemeColor.values.length) {
      return ThemeColor.values[index];
    }
    return ThemeColor.esmeralda;
  }
}
