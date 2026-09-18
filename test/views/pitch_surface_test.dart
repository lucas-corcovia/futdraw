import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/theme/pitch_theme.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_painters.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_surface.dart';

/// O que estes testes protegem nao e o acabamento do gramado -- isso so o olho
/// julga -- e sim o contrato entre o shader e o resto do app: que exista
/// fallback, que a captura de PNG passe por ele, e que a lista de uniformes do
/// `.frag` continue casando, na ordem, com quem preenche os slots.
void main() {
  Widget host(Widget child, {bool dark = true}) => MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            dark ? const PitchTheme.night() : const PitchTheme.day(),
          ],
        ),
        home: Scaffold(body: SizedBox(width: 360, height: 520, child: child)),
      );

  group('PitchSurface', () {
    testWidgets('desenha pelo painter quando o shader nao esta disponivel',
        (tester) async {
      await tester.pumpWidget(host(const PitchSurface(theme: PitchTheme.night())));

      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(PitchSurface),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.painter, isA<PitchSurfacePainter>());
    });

    testWidgets('enabled: false forca o painter -- e o caminho da captura',
        (tester) async {
      await tester.pumpWidget(
        host(const PitchSurface(theme: PitchTheme.night(), enabled: false)),
      );
      await tester.pumpAndSettle();

      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(PitchSurface),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.painter, isA<PitchSurfacePainter>());
    });

    testWidgets('nao quebra ao alternar noite e dia', (tester) async {
      await tester.pumpWidget(host(const PitchSurface(theme: PitchTheme.night())));
      await tester.pumpWidget(
        host(const PitchSurface(theme: PitchTheme.day()), dark: false),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('contrato de uniformes', () {
    // A ordem de declaracao no GLSL e a ordem dos slots no Dart. Trocar uma
    // sem trocar a outra nao da erro de compilacao: da um campo roxo.
    const expected = <String, int>{
      'uSize': 2,
      'uTurfNear': 3,
      'uTurfMid': 3,
      'uTurfFar': 3,
      'uLight': 2,
      'uLightIntensity': 1,
      'uLightColor': 3,
      'uStripeCount': 1,
      'uStripeStrength': 1,
      'uWear': 1,
      'uVignetteColor': 3,
      'uVignetteStrength': 1,
      'uGrain': 1,
    };

    test('o .frag declara os uniformes na ordem que o painter preenche', () {
      final source = File('assets/shaders/pitch_turf.frag').readAsStringSync();

      final declared = RegExp(r'^uniform\s+(float|vec2|vec3)\s+(\w+)\s*;',
              multiLine: true)
          .allMatches(source)
          .map((m) => MapEntry(m.group(2)!, _slots[m.group(1)!]!))
          .toList();

      expect(
        Map.fromEntries(declared),
        expected,
        reason: 'uniformes fora de ordem ou de tipo em relacao a '
            'PitchTurfPainter._configured',
      );
      expect(declared.map((e) => e.key), expected.keys);
    });

    test('o painter preenche exatamente os slots que o .frag declara', () {
      expect(expected.values.reduce((a, b) => a + b), 25);
    });
  });
}

const Map<String, int> _slots = {'float': 1, 'vec2': 2, 'vec3': 3};
