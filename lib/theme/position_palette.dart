import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/player.position.dart';

/// Um tom de posicao, resolvido para o modo claro ou escuro.
///
/// Sao quatro papeis porque a posicao aparece em dois contextos muito
/// diferentes: chips sobre a superficie neutra do app (lista, filtros, formulario)
/// e chips sobre o gramado. A matiz e a mesma nos dois; o que muda e a
/// luminancia.
@immutable
class PositionTone {
  const PositionTone({
    required this.ink,
    required this.container,
    required this.outline,
    required this.onTurf,
  });

  /// Texto e icone do chip.
  final Color ink;

  /// Fundo tingido do chip, sobre a superficie do app.
  final Color container;

  /// Hairline de 1 px do chip. So existe para o chip nao sumir quando o
  /// `container` fica quase igual a superficie por baixo.
  final Color outline;

  /// A mesma matiz, clara o bastante para ser lida sobre `chipSurface` no campo.
  final Color onTurf;

  static PositionTone lerp(PositionTone a, PositionTone b, double t) =>
      PositionTone(
        ink: Color.lerp(a.ink, b.ink, t)!,
        container: Color.lerp(a.container, b.container, t)!,
        outline: Color.lerp(a.outline, b.outline, t)!,
        onTurf: Color.lerp(a.onTurf, b.onTurf, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is PositionTone &&
      other.ink == ink &&
      other.container == container &&
      other.outline == outline &&
      other.onTurf == onTurf;

  @override
  int get hashCode => Object.hash(ink, container, outline, onTurf);
}

/// As quatro cores de posicao sobre o gramado, isoladas como constantes de topo
/// porque `PitchTheme` precisa delas dentro de um construtor `const`.
///
/// Aqui a luminancia alta nao e enfeite: o chip do campo tem superficie quase
/// preta por baixo (`PitchTheme.chipSurface`), e e contra ela, nao contra a
/// turfa, que estas cores precisam contrastar.
const Color _goalkeeperTurf = Color(0xFFFFD23F);
const Color _defenderTurf = Color(0xFF6FC0F0);
const Color _midfielderTurf = Color(0xFF7BD68C);
const Color _strikerTurf = Color(0xFFFF8A80);

/// Tabela canonica de cor de posicao no campo. `PitchTheme.positionColors` sai
/// daqui; nao existe uma segunda copia.
const Map<PlayerPosition, Color> kPositionTurfColors = {
  PlayerPosition.goalkeeper: _goalkeeperTurf,
  PlayerPosition.defender: _defenderTurf,
  PlayerPosition.midfielder: _midfielderTurf,
  PlayerPosition.striker: _strikerTurf,
};

/// O codigo de cor de posicao do app inteiro: goleiro ambar, defensor azul,
/// meio-campo verde, atacante vermelho.
///
/// Mora fora de `PitchTheme` de proposito. `PitchTheme` e a cena do campo, e
/// este codigo o usuario le na lista de jogadores, no formulario e nos filtros
/// muito antes de chegar ao gramado. Duas fontes de verdade para a mesma
/// informacao e como o mesmo jogador acabaria roxo numa tela e verde na outra.
///
/// Tambem nao e harmonizado com o seed do usuario: harmonizar destruiria
/// justamente o que faz o codigo funcionar, que e ter quatro matizes fixas e
/// aprendiveis. No tema esmeralda todas convergiriam para o verde.
///
/// As cores sao dessaturadas de proposito. Quatro cores em saturacao cheia numa
/// lista de vinte linhas viram ruido; o trabalho do chip e diferenciar de
/// relance, nao chamar atencao.
@immutable
class PositionPalette extends ThemeExtension<PositionPalette> {
  const PositionPalette({required this.tones});

  final Map<PlayerPosition, PositionTone> tones;

  PositionTone toneFor(PlayerPosition position) => tones[position]!;

  /// Cor de leitura rapida da posicao, para quando so cabe uma cor.
  Color inkFor(PlayerPosition position) => tones[position]!.ink;

  /// Cor da posicao sobre o gramado.
  Color onTurfFor(PlayerPosition position) => tones[position]!.onTurf;

  static PositionPalette of(BuildContext context) =>
      Theme.of(context).extension<PositionPalette>() ??
      const PositionPalette.dark();

  const PositionPalette.dark() : tones = _dark;
  const PositionPalette.light() : tones = _light;

  static const Map<PlayerPosition, PositionTone> _dark = {
    PlayerPosition.goalkeeper: PositionTone(
      ink: Color(0xFFE3C65E),
      container: Color(0xFF2A2415),
      outline: Color(0xFF4A3F22),
      onTurf: _goalkeeperTurf,
    ),
    PlayerPosition.defender: PositionTone(
      ink: Color(0xFF8CB4D8),
      container: Color(0xFF16222B),
      outline: Color(0xFF2C3F4E),
      onTurf: _defenderTurf,
    ),
    PlayerPosition.midfielder: PositionTone(
      ink: Color(0xFF93C79D),
      container: Color(0xFF17241A),
      outline: Color(0xFF2C3F30),
      onTurf: _midfielderTurf,
    ),
    PlayerPosition.striker: PositionTone(
      ink: Color(0xFFE09A93),
      container: Color(0xFF2B1A18),
      outline: Color(0xFF4A2F2B),
      onTurf: _strikerTurf,
    ),
  };

  static const Map<PlayerPosition, PositionTone> _light = {
    PlayerPosition.goalkeeper: PositionTone(
      ink: Color(0xFF6D5800),
      container: Color(0xFFF7F0DB),
      outline: Color(0xFFE4D6AE),
      onTurf: _goalkeeperTurf,
    ),
    PlayerPosition.defender: PositionTone(
      ink: Color(0xFF285573),
      container: Color(0xFFE7F0F7),
      outline: Color(0xFFC4D9E9),
      onTurf: _defenderTurf,
    ),
    PlayerPosition.midfielder: PositionTone(
      ink: Color(0xFF2E6236),
      container: Color(0xFFE8F2E9),
      outline: Color(0xFFC6DFC9),
      onTurf: _midfielderTurf,
    ),
    PlayerPosition.striker: PositionTone(
      ink: Color(0xFF8C3930),
      container: Color(0xFFFAEDEB),
      outline: Color(0xFFEDD1CD),
      onTurf: _strikerTurf,
    ),
  };

  @override
  PositionPalette copyWith({Map<PlayerPosition, PositionTone>? tones}) =>
      PositionPalette(tones: tones ?? this.tones);

  @override
  PositionPalette lerp(covariant PositionPalette? other, double t) {
    if (other == null) return this;
    return PositionPalette(
      tones: {
        for (final entry in tones.entries)
          entry.key: PositionTone.lerp(
            entry.value,
            other.tones[entry.key] ?? entry.value,
            t,
          ),
      },
    );
  }
}
