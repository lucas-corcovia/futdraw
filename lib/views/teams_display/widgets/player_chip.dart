import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/player_avatar.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/theme/app_typography.dart';
import 'package:futdraw/theme/pitch_theme.dart';
import 'package:futdraw/utils/extensions.dart';

/// Alvo de toque minimo. O chip antigo era tocavel apenas na area do avatar,
/// que no campo de 11 contra 11 chegava a 34 px.
const double kChipMinTapTarget = 48;

/// Abaixo deste tamanho o badge de nota sai e fica so anel e nome.
const double _kNotaBadgeThreshold = 44;

/// O jogador no gramado.
///
/// Mudancas em relacao ao chip anterior, que empilhava tres badges num circulo
/// de 34 px e -- apesar de o cabecalho anunciar "Media" -- nunca mostrava a
/// nota de ninguem:
///
/// * a nota aparece;
/// * a letra da posicao sai (o slot ja diz onde o jogador esta) e vai para a
///   ficha, o que desfaz o amontoado de tres badges;
/// * capitao vira uma bracadeira dourada no proprio anel, em vez de uma
///   estrela concorrendo com os outros badges;
/// * uma elipse de sombra assenta o jogador no gramado, que e o que faz ele
///   *pisar* no campo em vez de flutuar;
/// * a area de toque nunca fica abaixo de 48 dp.
class PlayerChip extends StatelessWidget {
  const PlayerChip({
    super.key,
    required this.player,
    required this.avatarSize,
    required this.teamAccent,
    this.labelWidth,
    this.isSelected = false,
    this.isDropTarget = false,
    this.isOutOfPosition = false,
    this.opacity = 1.0,
  });

  final Player player;
  final double avatarSize;
  final Color teamAccent;

  /// Largura maxima do losango de nome. Vem do espacamento do slot, para dois
  /// nomes vizinhos nunca se tocarem.
  final double? labelWidth;

  final bool isSelected;
  final bool isDropTarget;
  final bool isOutOfPosition;
  final double opacity;

  double get _totalWidth => math.max(avatarSize, labelWidth ?? avatarSize);

  @override
  Widget build(BuildContext context) {
    final pitch = context.pitch;
    final scheme = context.scheme;
    final highlighted = isSelected || isDropTarget;

    final ringColor = highlighted
        ? scheme.primary
        : pitch.colorFor(player.position);

    return Semantics(
      label: _semanticsLabel(),
      button: true,
      selected: isSelected,
      child: SizedBox(
        width: math.max(_totalWidth, kChipMinTapTarget),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AnimatedOpacity na folha, nunca o widget Opacity envolvendo a
            // subarvore: Opacity sobre conteudo complexo dispara saveLayer.
            AnimatedOpacity(
              opacity: opacity,
              duration: AppMotion.fast,
              child: SizedBox(
                width: math.max(avatarSize, kChipMinTapTarget),
                height: math.max(avatarSize, kChipMinTapTarget),
                child: Center(
                  child: _Badge(
                    player: player,
                    avatarSize: avatarSize,
                    ringColor: ringColor,
                    highlighted: highlighted,
                    isOutOfPosition: isOutOfPosition,
                    teamAccent: teamAccent,
                    pitch: pitch,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            _NameLozenge(
              name: player.nome,
              maxWidth: _totalWidth,
              pitch: pitch,
              opacity: opacity,
            ),
          ],
        ),
      ),
    );
  }

  String _semanticsLabel() {
    final parts = <String>[player.nome, player.position.displayName];
    parts.add('nota ${player.nota.toStringAsFixed(1)}');
    if (player.ehCapitao) parts.add('capitao');
    if (isOutOfPosition) parts.add('fora de posicao');
    return parts.join(', ');
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.player,
    required this.avatarSize,
    required this.ringColor,
    required this.highlighted,
    required this.isOutOfPosition,
    required this.teamAccent,
    required this.pitch,
  });

  final Player player;
  final double avatarSize;
  final Color ringColor;
  final bool highlighted;
  final bool isOutOfPosition;
  final Color teamAccent;
  final PitchTheme pitch;

  @override
  Widget build(BuildContext context) {
    final showNota = avatarSize >= _kNotaBadgeThreshold;

    return SizedBox.square(
      dimension: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sombra de contato, anel de posicao, bracadeira e marca de fora de
          // posicao saem todos de um painter so.
          Positioned.fill(
            child: CustomPaint(
              painter: _ChipRingPainter(
                ringColor: ringColor,
                highlighted: highlighted,
                isCaptain: player.ehCapitao,
                isOutOfPosition: isOutOfPosition,
                captainGold: pitch.captainGold,
                shadowColor: pitch.pitchShadow,
              ),
              child: Padding(
                padding: EdgeInsets.all(highlighted ? 3.5 : 2.5),
                child: PlayerAvatar(
                  url: player.urlFoto,
                  name: player.nome,
                  size: avatarSize,
                  backgroundColor: pitch.chipSurface,
                  foregroundColor: pitch.chipOnSurface,
                ),
              ),
            ),
          ),
          if (showNota)
            Positioned(
              right: -2,
              bottom: -2,
              child: _NotaBadge(
                nota: player.nota,
                accent: teamAccent,
                pitch: pitch,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotaBadge extends StatelessWidget {
  const _NotaBadge({
    required this.nota,
    required this.accent,
    required this.pitch,
  });

  final double nota;
  final Color accent;
  final PitchTheme pitch;

  @override
  Widget build(BuildContext context) {
    // Escala de texto travada: este badge tem largura de dois digitos por
    // desenho, e ele nunca carrega informacao que so exista aqui -- a nota
    // tambem esta na ficha do jogador e na lista.
    return MediaQuery.withNoTextScaling(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: AppRadii.pill,
          border: Border.all(color: pitch.chipSurface, width: 1.5),
        ),
        child: Text(
          nota.toStringAsFixed(1),
          style: AppTypography.scoreboardLabel.copyWith(
            fontSize: 10,
            letterSpacing: 0,
            color: _onAccent(accent),
          ),
        ),
      ),
    );
  }

  /// Preto ou branco, o que tiver mais contraste sobre o acento do time.
  static Color _onAccent(Color accent) =>
      accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

class _NameLozenge extends StatelessWidget {
  const _NameLozenge({
    required this.name,
    required this.maxWidth,
    required this.pitch,
    required this.opacity,
  });

  final String name;
  final double maxWidth;
  final PitchTheme pitch;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: AppMotion.fast,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: pitch.chipSurface,
            borderRadius: AppRadii.pill,
          ),
          child: Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.pitchChipName.copyWith(
              color: pitch.chipOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sombra de contato, anel de posicao, bracadeira de capitao e marca de fora
/// de posicao.
class _ChipRingPainter extends CustomPainter {
  _ChipRingPainter({
    required this.ringColor,
    required this.highlighted,
    required this.isCaptain,
    required this.isOutOfPosition,
    required this.captainGold,
    required this.shadowColor,
  });

  final Color ringColor;
  final bool highlighted;
  final bool isCaptain;
  final bool isOutOfPosition;
  final Color captainGold;
  final Color shadowColor;

  static final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Elipse de contato: e o que faz o jogador pisar no gramado em vez de
    // flutuar sobre ele.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centre.dx, size.height * 0.99),
        width: size.width * 0.82,
        height: size.height * 0.22,
      ),
      _shadow..color = shadowColor,
    );

    final ringWidth = highlighted ? 3.0 : 2.0;
    final ringRadius = radius - ringWidth / 2;

    if (highlighted) {
      canvas.drawCircle(
        centre,
        ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth + 4
          ..color = ringColor.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.drawCircle(
      centre,
      ringRadius,
      _stroke
        ..color = ringColor
        ..strokeWidth = ringWidth,
    );

    if (isOutOfPosition) {
      _paintDashedRing(canvas, centre, ringRadius - ringWidth - 1.5);
    }

    if (isCaptain) {
      // Bracadeira: um arco curto no alto do anel, nao mais uma estrela
      // disputando espaco com os outros badges.
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: ringRadius),
        -math.pi * 0.78,
        math.pi * 0.56,
        false,
        _stroke
          ..color = captainGold
          ..strokeWidth = ringWidth + 1.5,
      );
    }
  }

  void _paintDashedRing(Canvas canvas, Offset centre, double radius) {
    if (radius <= 0) return;
    const segments = 14;
    const gap = 0.35;
    final step = (math.pi * 2) / segments;

    for (var i = 0; i < segments; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        i * step,
        step * (1 - gap),
        false,
        _stroke
          ..color = ringColor.withValues(alpha: 0.75)
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChipRingPainter old) =>
      old.ringColor != ringColor ||
      old.highlighted != highlighted ||
      old.isCaptain != isCaptain ||
      old.isOutOfPosition != isOutOfPosition ||
      old.captainGold != captainGold ||
      old.shadowColor != shadowColor;
}
