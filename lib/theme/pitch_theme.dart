import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/theme/position_palette.dart';

/// Tokens da cena do campo: turfa, linhas, luz e os codigos de cor que o
/// usuario aprende a ler.
///
/// A regra que este arquivo existe para impor: **o campo e uma superficie
/// fotografica, nao uma superficie tematica.** O seed escolhido pelo usuario
/// (sao 8) nunca toca turfa, linha nem refletor; ele e dono do chrome. Se o
/// gramado seguisse o seed, o tema carmesim daria um campo vermelho e o
/// realismo, que e metade do pedido, iria embora.
@immutable
class PitchTheme extends ThemeExtension<PitchTheme> {
  const PitchTheme({
    required this.turfNear,
    required this.turfMid,
    required this.turfFar,
    required this.stripeLight,
    required this.stripeDark,
    required this.stripeStrength,
    required this.turfWear,
    required this.floodlightColor,
    required this.floodlightIntensity,
    required this.floodlightCenter,
    required this.vignetteColor,
    required this.vignetteStrength,
    required this.noiseOpacity,
    required this.pitchShadow,
    required this.lineColor,
    required this.lineUnderShadow,
    required this.lineWidth,
    required this.chipSurface,
    required this.chipOnSurface,
    required this.chipGhost,
    required this.captainGold,
    required this.positionColors,
    required this.teamAccents,
    required this.scoreboardGlass,
    required this.scoreboardBorder,
  });

  // Superficie
  final Color turfNear;
  final Color turfMid;
  final Color turfFar;
  final Color stripeLight;
  final Color stripeDark;

  /// Forca do termo anisotropico da listra, no shader de turfa. Nao e alfa de
  /// cor: a listra do gramado nao e cor, e luz devolvida pela lamina deitada.
  final double stripeStrength;

  /// Quanto a grama rala nas zonas mais pisadas (areas, circulo, marcas de
  /// penalti). Pisado clareia e perde saturacao, nunca vira marrom.
  final double turfWear;
  final Color floodlightColor;
  final double floodlightIntensity;
  final Alignment floodlightCenter;
  final Color vignetteColor;
  final double vignetteStrength;

  /// Ruido estatico por cima da turfa. E o truque mais barato contra o aspecto
  /// plastico de um gradiente chapado, e evita banding em telas de 8 bits.
  final double noiseOpacity;
  final Color pitchShadow;

  // Linhas
  final Color lineColor;

  /// Sombra de 1 px sob a linha. So o tema de dia usa, para a cal nao estourar
  /// contra grama clara.
  final Color lineUnderShadow;
  final double lineWidth;

  // Chips de jogador
  final Color chipSurface;
  final Color chipOnSurface;

  /// Slot vazio: a formacao nao coube no elenco.
  final Color chipGhost;

  /// Bracadeira de capitao. Fixa de proposito: antes usava
  /// `colorScheme.tertiary`, o que pintava a bracadeira de roxo no tema violeta
  /// e de rosa no tema rosa. Bracadeira de capitao e dourada.
  final Color captainGold;

  /// Rampa categorica de posicao. Vem de `kPositionTurfColors`, em
  /// `position_palette.dart`: o codigo de cor e do app inteiro, nao do campo, e
  /// so existe uma copia dele.
  ///
  /// A regra que vale aqui e **luminancia, nao matiz**. O `Colors.green` cru
  /// que existia antes para meio-campo sumia porque era pintado direto sobre a
  /// turfa e tinha luminancia parecida com a dela; o verde claro de hoje e
  /// lido sobre `chipSurface`, que e quase preta. Tambem nao e harmonizada com
  /// o seed: no tema esmeralda a harmonizacao empurraria estas cores
  /// justamente para o verde da turfa.
  final Map<PlayerPosition, Color> positionColors;

  /// Acentos por time, fixos. Derivar 6 cores de um seed so produz 6 matizes
  /// quase iguais, e ai os times ficam indistinguiveis exatamente onde
  /// distinguir importa: no comparativo e na imagem compartilhada.
  final List<Color> teamAccents;

  // Placar sobre o campo
  final Color scoreboardGlass;
  final Color scoreboardBorder;

  Color accentForTeam(int index) => teamAccents[index % teamAccents.length];

  Color colorFor(PlayerPosition position) => positionColors[position]!;

  static const Map<PlayerPosition, Color> _positions = kPositionTurfColors;

  static const List<Color> _accents = [
    Color(0xFFE5484D),
    Color(0xFF3E7BFA),
    Color(0xFFF5A524),
    Color(0xFF8E4EC6),
    Color(0xFF12A594),
    Color(0xFFEC4899),
  ];

  static const Color _gold = Color(0xFFF5C542);

  /// Jogo noturno sob refletor. E o tema primario.
  const PitchTheme.night()
      : turfNear = const Color(0xFF1B6B37),
        turfMid = const Color(0xFF0E4526),
        turfFar = const Color(0xFF072C18),
        stripeLight = const Color(0x14FFFFFF),
        stripeDark = const Color(0x1A000000),
        stripeStrength = 0.26,
        turfWear = 0.30,
        floodlightColor = const Color(0xFFFFF4D6),
        floodlightIntensity = 0.16,
        floodlightCenter = const Alignment(0, -0.75),
        vignetteColor = const Color(0xFF000000),
        vignetteStrength = 0.42,
        noiseOpacity = 0.035,
        pitchShadow = const Color(0x99000000),
        lineColor = const Color(0xEBFFFFFF),
        lineUnderShadow = const Color(0x00000000),
        lineWidth = 2.0,
        chipSurface = const Color(0xCC0B1A12),
        chipOnSurface = const Color(0xFFF2F5F3),
        chipGhost = const Color(0x66FFFFFF),
        captainGold = _gold,
        positionColors = _positions,
        teamAccents = _accents,
        scoreboardGlass = const Color(0x33FFFFFF),
        scoreboardBorder = const Color(0x4DFFFFFF);

  /// Jogo de dia. Nao e o tema escuro com texto claro: e outra hora do dia.
  const PitchTheme.day()
      : turfNear = const Color(0xFF3FA35C),
        turfMid = const Color(0xFF2A8348),
        turfFar = const Color(0xFF1D6236),
        stripeLight = const Color(0x1FFFFFFF),
        stripeDark = const Color(0x14000000),
        stripeStrength = 0.18,
        turfWear = 0.24,
        floodlightColor = const Color(0xFFFFFBEF),
        floodlightIntensity = 0.10,
        floodlightCenter = const Alignment(-0.2, -0.6),
        vignetteColor = const Color(0xFF06301A),
        vignetteStrength = 0.18,
        noiseOpacity = 0.028,
        pitchShadow = const Color(0x4D000000),
        lineColor = const Color(0xF5FFFFFF),
        lineUnderShadow = const Color(0x33063018),
        lineWidth = 2.2,
        chipSurface = const Color(0xD90C2418),
        chipOnSurface = const Color(0xFFFFFFFF),
        chipGhost = const Color(0x59FFFFFF),
        captainGold = _gold,
        positionColors = _positions,
        teamAccents = _accents,
        scoreboardGlass = const Color(0x3D000000),
        scoreboardBorder = const Color(0x4DFFFFFF);

  static PitchTheme of(BuildContext context) =>
      Theme.of(context).extension<PitchTheme>() ?? const PitchTheme.night();

  @override
  PitchTheme copyWith({
    Color? turfNear,
    Color? turfMid,
    Color? turfFar,
    Color? stripeLight,
    Color? stripeDark,
    double? stripeStrength,
    double? turfWear,
    Color? floodlightColor,
    double? floodlightIntensity,
    Alignment? floodlightCenter,
    Color? vignetteColor,
    double? vignetteStrength,
    double? noiseOpacity,
    Color? pitchShadow,
    Color? lineColor,
    Color? lineUnderShadow,
    double? lineWidth,
    Color? chipSurface,
    Color? chipOnSurface,
    Color? chipGhost,
    Color? captainGold,
    Map<PlayerPosition, Color>? positionColors,
    List<Color>? teamAccents,
    Color? scoreboardGlass,
    Color? scoreboardBorder,
  }) {
    return PitchTheme(
      turfNear: turfNear ?? this.turfNear,
      turfMid: turfMid ?? this.turfMid,
      turfFar: turfFar ?? this.turfFar,
      stripeLight: stripeLight ?? this.stripeLight,
      stripeDark: stripeDark ?? this.stripeDark,
      stripeStrength: stripeStrength ?? this.stripeStrength,
      turfWear: turfWear ?? this.turfWear,
      floodlightColor: floodlightColor ?? this.floodlightColor,
      floodlightIntensity: floodlightIntensity ?? this.floodlightIntensity,
      floodlightCenter: floodlightCenter ?? this.floodlightCenter,
      vignetteColor: vignetteColor ?? this.vignetteColor,
      vignetteStrength: vignetteStrength ?? this.vignetteStrength,
      noiseOpacity: noiseOpacity ?? this.noiseOpacity,
      pitchShadow: pitchShadow ?? this.pitchShadow,
      lineColor: lineColor ?? this.lineColor,
      lineUnderShadow: lineUnderShadow ?? this.lineUnderShadow,
      lineWidth: lineWidth ?? this.lineWidth,
      chipSurface: chipSurface ?? this.chipSurface,
      chipOnSurface: chipOnSurface ?? this.chipOnSurface,
      chipGhost: chipGhost ?? this.chipGhost,
      captainGold: captainGold ?? this.captainGold,
      positionColors: positionColors ?? this.positionColors,
      teamAccents: teamAccents ?? this.teamAccents,
      scoreboardGlass: scoreboardGlass ?? this.scoreboardGlass,
      scoreboardBorder: scoreboardBorder ?? this.scoreboardBorder,
    );
  }

  @override
  PitchTheme lerp(covariant PitchTheme? other, double t) {
    if (other == null) return this;
    return PitchTheme(
      turfNear: Color.lerp(turfNear, other.turfNear, t)!,
      turfMid: Color.lerp(turfMid, other.turfMid, t)!,
      turfFar: Color.lerp(turfFar, other.turfFar, t)!,
      stripeLight: Color.lerp(stripeLight, other.stripeLight, t)!,
      stripeDark: Color.lerp(stripeDark, other.stripeDark, t)!,
      stripeStrength: _lerpDouble(stripeStrength, other.stripeStrength, t),
      turfWear: _lerpDouble(turfWear, other.turfWear, t),
      floodlightColor: Color.lerp(floodlightColor, other.floodlightColor, t)!,
      floodlightIntensity: _lerpDouble(
        floodlightIntensity,
        other.floodlightIntensity,
        t,
      ),
      floodlightCenter:
          Alignment.lerp(floodlightCenter, other.floodlightCenter, t)!,
      vignetteColor: Color.lerp(vignetteColor, other.vignetteColor, t)!,
      vignetteStrength: _lerpDouble(vignetteStrength, other.vignetteStrength, t),
      noiseOpacity: _lerpDouble(noiseOpacity, other.noiseOpacity, t),
      pitchShadow: Color.lerp(pitchShadow, other.pitchShadow, t)!,
      lineColor: Color.lerp(lineColor, other.lineColor, t)!,
      lineUnderShadow: Color.lerp(lineUnderShadow, other.lineUnderShadow, t)!,
      lineWidth: _lerpDouble(lineWidth, other.lineWidth, t),
      chipSurface: Color.lerp(chipSurface, other.chipSurface, t)!,
      chipOnSurface: Color.lerp(chipOnSurface, other.chipOnSurface, t)!,
      chipGhost: Color.lerp(chipGhost, other.chipGhost, t)!,
      captainGold: Color.lerp(captainGold, other.captainGold, t)!,
      positionColors: {
        for (final entry in positionColors.entries)
          entry.key: Color.lerp(entry.value, other.positionColors[entry.key], t)!,
      },
      teamAccents: [
        for (var i = 0; i < teamAccents.length; i++)
          Color.lerp(teamAccents[i], other.teamAccents[i], t)!,
      ],
      scoreboardGlass: Color.lerp(scoreboardGlass, other.scoreboardGlass, t)!,
      scoreboardBorder: Color.lerp(scoreboardBorder, other.scoreboardBorder, t)!,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
