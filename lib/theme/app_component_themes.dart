import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/theme/app_tokens.dart';

/// Temas de componente.
///
/// Antes daqui o app estilizava so appBar, filledButton, card, input e tabBar;
/// todo o resto era o padrao do Material, e cada tela recompensava isso
/// redeclarando `shape:` e `elevation:` no lugar de herdar. Com estes slots
/// preenchidos, quase toda sobrescrita local nas telas deixa de ser necessaria.
///
/// **Um vocabulario de toque so:** tinta (ink) em tudo que e Material. A unica
/// excecao documentada e o chip de jogador sobre o gramado, que nao tem
/// ancestral Material onde a tinta pudesse ser recortada, e por isso usa
/// press-por-escala.
abstract final class AppComponentThemes {
  static AppBarTheme appBar(ColorScheme scheme, TextTheme text) => AppBarTheme(
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: Colors.transparent,
    elevation: AppElevation.flat,
    scrolledUnderElevation: AppElevation.flat,
    // Mantido centralizado: o app sempre foi assim, e alinhamento de titulo e
    // identidade, nao defeito. A tela de times traz o proprio chrome.
    centerTitle: true,
    titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
    systemOverlayStyle: scheme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark,
  );

  static CardThemeData card(ColorScheme scheme) => CardThemeData(
    color: scheme.surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    elevation: AppElevation.flat,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadii.card,
      side: BorderSide(color: scheme.outlineVariant),
    ),
    // Margem pertence ao layout, nao ao card.
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  );

  static FilledButtonThemeData filledButton(
    ColorScheme scheme,
    TextTheme text,
  ) => FilledButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadii.control),
      ),
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.12);
        }
        return scheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.38);
        }
        return scheme.onPrimary;
      }),
      elevation: const WidgetStatePropertyAll(AppElevation.flat),
    ),
  );

  static OutlinedButtonThemeData outlinedButton(
    ColorScheme scheme,
    TextTheme text,
  ) => OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadii.control),
      ),
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.38);
        }
        return scheme.primary;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: scheme.onSurface.withValues(alpha: 0.12));
        }
        return BorderSide(color: scheme.outline);
      }),
    ),
  );

  static TextButtonThemeData textButton(ColorScheme scheme, TextTheme text) =>
      TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.small),
          ),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.38);
            }
            return scheme.primary;
          }),
        ),
      );

  static InputDecorationTheme input(ColorScheme scheme, TextTheme text) =>
      InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        // Rotulo persistente: placeholder-como-rotulo some no foco e falha a
        // memoria do usuario.
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      );

  static TabBarThemeData tabBar(ColorScheme scheme, TextTheme text) =>
      TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: scheme.outlineVariant,
      );

  static BottomSheetThemeData bottomSheet(ColorScheme scheme) =>
      BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        modalElevation: AppElevation.flat,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      );

  static SnackBarThemeData snackBar(ColorScheme scheme, TextTheme text) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        elevation: AppElevation.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.control),
      );

  static ChipThemeData chip(ColorScheme scheme, TextTheme text) =>
      ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.chip),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        showCheckmark: false,
      );

  static SegmentedButtonThemeData segmentedButton(
    ColorScheme scheme,
    TextTheme text,
  ) => SegmentedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadii.control),
      ),
      side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
    ),
  );

  static ListTileThemeData listTile(ColorScheme scheme, TextTheme text) =>
      ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.control),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      );

  static DividerThemeData divider(ColorScheme scheme) => DividerThemeData(
    color: scheme.outlineVariant,
    thickness: 1,
    space: 1,
  );

  static DialogThemeData dialog(ColorScheme scheme, TextTheme text) =>
      DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.overlay,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
        titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
      );

  static FloatingActionButtonThemeData fab(ColorScheme scheme) =>
      FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: AppElevation.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
      );

  static ProgressIndicatorThemeData progress(ColorScheme scheme) =>
      ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      );

  static TooltipThemeData tooltip(ColorScheme scheme, TextTheme text) =>
      TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: AppRadii.small,
        ),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
        waitDuration: const Duration(milliseconds: 500),
      );

  /// Vocabulario de transicao definido uma vez, no tema, e nunca por rota.
  ///
  /// iOS mantem a transicao Cupertino de proposito: qualquer coisa custom ali
  /// mata o back-swipe de borda, que e um defeito entregue.
  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );
}
