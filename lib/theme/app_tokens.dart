import 'package:flutter/material.dart';

/// Escala de 4 pt. Sao os unicos espacamentos que existem no app.
///
/// O codebase ja praticava 4/8/12/16/24/32 em ~92% dos casos; formalizar
/// custou quase nada e elimina os avulsos (3, 5, 10, 15, 20).
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Uma familia de raio so, derivada do que o app ja fazia (8/12/16/20 cobrem
/// 96% dos usos). Os avulsos 10, 14 e 28 saem.
abstract final class AppRadii {
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(20);

  static const BorderRadius card = BorderRadius.all(lg);
  static const BorderRadius control = BorderRadius.all(md);
  static const BorderRadius small = BorderRadius.all(sm);
  static const BorderRadius chip = BorderRadius.all(xl);
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(24));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// No tema escuro a profundidade vem da escada de `surfaceContainer*`, nao de
/// sombra. Estes valores servem ao tema claro e a superficies que flutuam de
/// verdade sobre conteudo.
abstract final class AppElevation {
  static const double flat = 0;
  static const double raised = 1;
  static const double floating = 3;
  static const double overlay = 6;
}

/// Duracoes e curvas da personalidade "Smooth & Premium".
///
/// Regra de ouro: saidas correm a 50-75% da entrada correspondente, e nada que
/// o usuario dispara dezenas de vezes por dia ganha animacao.
abstract final class AppMotion {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration enter = Duration(milliseconds: 400);
  static const Duration exit = Duration(milliseconds: 220);
  static const Duration page = Duration(milliseconds: 350);

  /// Coreografia de entrada da tela de times, o momento assinatura do app.
  static const Duration reveal = Duration(milliseconds: 1100);

  static const Curve entering = Easing.emphasizedDecelerate;
  static const Curve exiting = Easing.emphasizedAccelerate;
  static const Curve moving = Curves.easeInOutCubicEmphasized;
  static const Curve settling = Curves.easeOutCubic;

  /// True quando o usuario pediu menos movimento no sistema.
  ///
  /// Ate agora o app nao checava isto em lugar nenhum, entao nem o splash de
  /// 2,8 s nem o reveal da tela de times podiam ser dispensados.
  static bool isReduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Duracao que colapsa para zero sob movimento reduzido.
  static Duration at(BuildContext context, Duration duration) =>
      isReduced(context) ? Duration.zero : duration;

  /// Duracao curta de crossfade para substituir um movimento que foi cortado.
  /// Um corte seco e mais agressivo que um fade curto, e um fade curto ainda
  /// conta como "reduzido".
  static Duration fadeOnly(BuildContext context, Duration duration) =>
      isReduced(context) ? const Duration(milliseconds: 120) : duration;
}
