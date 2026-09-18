import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/theme/pitch_theme.dart';
import 'package:futdraw/theme/position_palette.dart';

/// Luminancia relativa WCAG 2.1.
double _luminance(Color color) {
  double channel(double value) =>
      value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4) as double;

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Compoe `foreground` (que pode ter alpha) sobre `background`.
Color _over(Color foreground, Color background) {
  final a = foreground.a;
  return Color.from(
    alpha: 1,
    red: foreground.r * a + background.r * (1 - a),
    green: foreground.g * a + background.g * (1 - a),
    blue: foreground.b * a + background.b * (1 - a),
  );
}

/// Matiz em graus, para provar que as quatro posicoes nao colidem.
double _hue(Color color) => HSLColor.fromColor(color).hue;

void main() {
  group('PositionPalette', () {
    const modes = {
      'escuro': PositionPalette.dark(),
      'claro': PositionPalette.light(),
    };

    for (final entry in modes.entries) {
      final mode = entry.key;
      final palette = entry.value;

      test('$mode: texto do chip tem contraste de corpo sobre o fundo', () {
        for (final position in PlayerPosition.values) {
          final tone = palette.toneFor(position);
          final ratio = _contrast(tone.ink, tone.container);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Modo $mode, ${position.name}: ink sobre container e '
                '${ratio.toStringAsFixed(2)}:1, abaixo de 4.5:1',
          );
        }
      });

      test('$mode: a borda do chip se destaca do proprio fundo', () {
        for (final position in PlayerPosition.values) {
          final tone = palette.toneFor(position);
          expect(
            _contrast(tone.outline, tone.container),
            greaterThan(1.1),
            reason:
                'Modo $mode, ${position.name}: a borda desaparece dentro do '
                'chip',
          );
        }
      });

      test('$mode: as quatro matizes ficam a pelo menos 40 graus', () {
        final hues = {
          for (final position in PlayerPosition.values)
            position: _hue(palette.toneFor(position).ink),
        };

        for (final a in PlayerPosition.values) {
          for (final b in PlayerPosition.values) {
            if (a.index >= b.index) continue;
            final raw = (hues[a]! - hues[b]!).abs();
            final distance = math.min(raw, 360 - raw);
            expect(
              distance,
              greaterThanOrEqualTo(40),
              reason:
                  'Modo $mode: ${a.name} e ${b.name} estao a '
                  '${distance.toStringAsFixed(0)} graus, perto demais para '
                  'serem lidas como cores diferentes',
            );
          }
        }
      });
    }

    test('a cor de campo e legivel sobre a superficie do chip', () {
      // O chip do campo tem fundo proprio, semitransparente sobre a turfa. E
      // contra ele, ja composto, que a cor precisa contrastar -- foi por
      // confundir isso que o meio-campo ficou roxo por meses.
      for (final pitch in [const PitchTheme.night(), const PitchTheme.day()]) {
        final surface = _over(pitch.chipSurface, pitch.turfMid);
        for (final position in PlayerPosition.values) {
          final ratio = _contrast(pitch.colorFor(position), surface);
          expect(
            ratio,
            greaterThanOrEqualTo(3.0),
            reason:
                '${position.name} sobre chipSurface e '
                '${ratio.toStringAsFixed(2)}:1, abaixo de 3:1',
          );
        }
      }
    });

    test('PitchTheme usa a tabela canonica, sem uma segunda copia', () {
      expect(const PitchTheme.night().positionColors, kPositionTurfColors);
      expect(const PitchTheme.day().positionColors, kPositionTurfColors);
    });

    test('meio-campo e verde, defensor e azul', () {
      // O pedido explicito: defensor azul, meio verde, atacante vermelho,
      // goleiro amarelo. Travado em teste porque a tentacao de "harmonizar com
      // o seed" volta toda vez que alguem mexe no tema.
      final palette = const PositionPalette.dark();
      expect(_hue(palette.inkFor(PlayerPosition.midfielder)), inInclusiveRange(80, 160));
      expect(_hue(palette.inkFor(PlayerPosition.defender)), inInclusiveRange(180, 250));
      expect(_hue(palette.inkFor(PlayerPosition.goalkeeper)), inInclusiveRange(30, 60));
      final striker = _hue(palette.inkFor(PlayerPosition.striker));
      expect(striker < 20 || striker > 340, isTrue, reason: 'atacante deve ser vermelho');
    });

    test('lerp entre os dois modos nao perde nenhuma posicao', () {
      final mid = const PositionPalette.dark()
          .lerp(const PositionPalette.light(), 0.5);
      expect(mid.tones.keys, containsAll(PlayerPosition.values));
    });
  });
}
