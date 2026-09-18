import 'package:flutter/material.dart';

/// Constroi os dois `ColorScheme` do app a partir do seed que o usuario
/// escolheu (sao 8 opcoes, persistidas em `ConfigurationsController`).
///
/// `ColorScheme.fromSeed` e um gerador, nao uma resposta: a saida crua e o
/// visual de app Flutter nao terminado. Aqui ela e afinada.
///
/// Duas decisoes que valem explicar:
///
/// 1. **`DynamicSchemeVariant.fidelity`.** Os 8 seeds sao a rampa 600 do
///    Tailwind, todos saturados. A variante padrao (`tonalSpot`) apaga essa
///    saturacao, e ai os 8 temas ficam parecidos entre si. `fidelity` mantem o
///    matiz da marca reconhecivel.
///
/// 2. **A escada de superficie e neutra e fixa, nao tingida pelo seed.** O
///    estilo e "broadcast esportivo": o chrome e o pacote grafico da
///    transmissao, constante, e a cor do time entra por cima. Um chrome que
///    mudasse de tom junto com o seed brigaria com o gramado, que tambem nao
///    segue o seed.
abstract final class AppColorScheme {
  static ColorScheme build(Color seed, Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    return brightness == Brightness.dark ? _tuneDark(base) : _tuneLight(base);
  }

  /// Preto fosco de estudio. Nunca `#000`: preto puro mata a escada de
  /// elevacao e borra em rolagem sobre OLED.
  static ColorScheme _tuneDark(ColorScheme base) => base.copyWith(
    surface: const Color(0xFF0D0F0E),
    surfaceContainerLowest: const Color(0xFF0A0C0B),
    surfaceContainerLow: const Color(0xFF121514),
    surfaceContainer: const Color(0xFF171A19),
    surfaceContainerHigh: const Color(0xFF1E2221),
    surfaceContainerHighest: const Color(0xFF262B29),
    surfaceDim: const Color(0xFF080A09),
    surfaceBright: const Color(0xFF2C3130),
    onSurface: const Color(0xFFE8ECEA),
    onSurfaceVariant: const Color(0xFFA9B2AE),
    outline: const Color(0xFF6B7370),
    outlineVariant: const Color(0xFF2A302E),
  );

  static ColorScheme _tuneLight(ColorScheme base) => base.copyWith(
    surface: const Color(0xFFF7F8F7),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF1F3F2),
    surfaceContainer: const Color(0xFFEBEEEC),
    surfaceContainerHigh: const Color(0xFFE5E9E7),
    surfaceContainerHighest: const Color(0xFFDFE4E1),
    surfaceDim: const Color(0xFFDCE0DE),
    surfaceBright: const Color(0xFFFDFEFD),
    onSurface: const Color(0xFF141816),
    onSurfaceVariant: const Color(0xFF4A524E),
    outline: const Color(0xFF767F7B),
    outlineVariant: const Color(0xFFD6DBD8),
  );
}
