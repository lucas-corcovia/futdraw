import 'package:flutter/material.dart';
import 'package:futdraw/models/consts/app.colors.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/theme/app_color_scheme.dart';
import 'package:futdraw/theme/app_component_themes.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/theme/app_typography.dart';
import 'package:futdraw/theme/pitch_theme.dart';
import 'package:futdraw/theme/position_palette.dart';

/// Monta o `ThemeData` do app inteiro.
///
/// Substitui `ThemeSelector`, mantendo a mesma assinatura para que os call
/// sites em `main.dart` nao mudem de forma.
///
/// Os dois modos saem da **mesma funcao**, cada um a partir do seu proprio
/// scheme. Nunca `ThemeData.dark().copyWith(colorScheme: ...)`: isso deixa
/// dezenas de campos legados derivados da paleta escura padrao e produz
/// exatamente os defeitos de troca de tema que este arquivo existe para evitar.
abstract final class AppTheme {
  static ThemeData build(ThemeColor color, bool isDark) {
    final seed = ThemeColors.seedColors[color]!;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final scheme = AppColorScheme.build(seed, brightness);

    // Construido por scheme. Compartilhar uma instancia de TextTheme entre os
    // dois modos e a causa numero um de texto claro em fundo claro.
    final text = AppTypography.build(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      fontFamily: AppTypography.body,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: AppComponentThemes.pageTransitions,

      appBarTheme: AppComponentThemes.appBar(scheme, text),
      cardTheme: AppComponentThemes.card(scheme),
      filledButtonTheme: AppComponentThemes.filledButton(scheme, text),
      outlinedButtonTheme: AppComponentThemes.outlinedButton(scheme, text),
      textButtonTheme: AppComponentThemes.textButton(scheme, text),
      inputDecorationTheme: AppComponentThemes.input(scheme, text),
      tabBarTheme: AppComponentThemes.tabBar(scheme, text),
      bottomSheetTheme: AppComponentThemes.bottomSheet(scheme),
      snackBarTheme: AppComponentThemes.snackBar(scheme, text),
      chipTheme: AppComponentThemes.chip(scheme, text),
      segmentedButtonTheme: AppComponentThemes.segmentedButton(scheme, text),
      listTileTheme: AppComponentThemes.listTile(scheme, text),
      dividerTheme: AppComponentThemes.divider(scheme),
      dialogTheme: AppComponentThemes.dialog(scheme, text),
      floatingActionButtonTheme: AppComponentThemes.fab(scheme),
      progressIndicatorTheme: AppComponentThemes.progress(scheme),
      tooltipTheme: AppComponentThemes.tooltip(scheme, text),

      extensions: <ThemeExtension<dynamic>>[
        // A cena do campo nao segue o seed; segue a hora do dia.
        isDark ? const PitchTheme.night() : const PitchTheme.day(),
        // O codigo de cor de posicao tambem nao segue o seed: sao quatro
        // matizes fixas que o usuario aprende a ler em todo o app.
        isDark ? const PositionPalette.dark() : const PositionPalette.light(),
      ],
    );
  }
}

/// Atalhos de leitura de tema.
///
/// Sempre lidos dentro de `build`, nunca guardados em `initState` nem em campo
/// estatico: e a leitura em `build` que inscreve o widget nas mudancas de tema.
extension AppThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  PitchTheme get pitch => PitchTheme.of(this);
  PositionPalette get positions => PositionPalette.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get reducedMotion => AppMotion.isReduced(this);
}
