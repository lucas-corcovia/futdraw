import 'package:flutter/material.dart';

/// Escala tipografica do app.
///
/// Antes daqui, `ThemeSelector` so setava `fontFamily: 'Kanit'` e deixava a
/// escala M3 padrao intacta -- e, como o bundle tinha apenas o peso 400, todo
/// `FontWeight.bold` do app era negrito sintetizado pelo engine. Agora os
/// pesos 500/600/700 sao reais (ver `test/theme/kanit_digits_test.dart`, que
/// falha se alguem remover os TTFs).
///
/// O `TextTheme` e construido **por scheme**. Nunca compartilhar uma instancia
/// entre claro e escuro: e assim que texto claro acaba em fundo claro.
abstract final class AppTypography {
  /// Face de marca. Usada no wordmark e em nome de time, onde ela tem impacto.
  /// Deliberadamente fora dos numeros: uma face decorativa num placar troca
  /// legibilidade por estilo, e placar de transmissao real usa grotesca.
  static const String display = 'PervitinaDex';
  static const String body = 'Kanit';

  static TextTheme build(ColorScheme scheme) => _base.apply(
    fontFamily: body,
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  /// Estilos sem cor. A cor entra no uso, a partir do papel da superficie em
  /// que o texto esta -- caso contrario ela sobrevive a troca de tema.
  static const TextTheme _base = TextTheme(
    displayLarge: TextStyle(
      fontFamily: display,
      fontSize: 44,
      height: 1.1,
      letterSpacing: 2.5,
    ),
    displayMedium: TextStyle(
      fontFamily: display,
      fontSize: 34,
      height: 1.12,
      letterSpacing: 2,
    ),
    displaySmall: TextStyle(
      fontFamily: display,
      fontSize: 26,
      height: 1.15,
      letterSpacing: 1.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.18,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.22,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, height: 1.45),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.6,
    ),
  );

  /// Numero grande de placar, sem cor.
  ///
  /// Kanit e nao PervitinaDex, e sempre renderizado via `TabularNumber`: Kanit
  /// nao traz a feature OpenType `tnum` e seus digitos sao fortemente
  /// proporcionais (o "1" mede pouco mais da metade do "0"), entao sem largura
  /// fixa a media do placar dancaria a cada troca de jogador.
  static const TextStyle scoreboardValue = TextStyle(
    fontFamily: body,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );

  /// Nota do jogador numa linha de lista. E o mesmo papel de
  /// `scoreboardValue` -- um numero que se le de relance -- em escala de lista,
  /// nao de placar.
  static const TextStyle ratingValue = TextStyle(
    fontFamily: body,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
  );

  /// Rotulo curto acima ou ao lado de um numero de placar.
  static const TextStyle scoreboardLabel = TextStyle(
    fontFamily: body,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.2,
  );

  /// Nome do jogador no chip sobre o gramado. Caixa alta, tracking aberto,
  /// para aguentar qualquer turfa por baixo.
  static const TextStyle pitchChipName = TextStyle(
    fontFamily: body,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.4,
  );

  /// Dica e controle sobre o gramado. Um degrau menor que o chip, porque e
  /// texto de apoio: quem ja sabe o gesto nao deve continuar lendo.
  static const TextStyle pitchHint = TextStyle(
    fontFamily: body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );
}
