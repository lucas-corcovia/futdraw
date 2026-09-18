import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/pitch_theme.dart';

import 'theme_probe.dart';

/// Tamanhos da matriz de resiliencia.
///
/// 360x800 e o aparelho numero um da frota mundial, e 1,3x e escala de fonte
/// de todo dia. Testar so no emulador Pixel padrao testa o caso mais facil.
const _sizes = <({Size size, double textScale, String name})>[
  (size: Size(320, 568), textScale: 1.0, name: 'pequeno'),
  (size: Size(360, 640), textScale: 1.3, name: 'compacto_texto_grande'),
  (size: Size(360, 800), textScale: 1.3, name: 'alto_texto_grande'),
  (size: Size(800, 360), textScale: 1.0, name: 'paisagem'),
];

Future<void> _pumpProbe(
  WidgetTester tester, {
  required ThemeColor color,
  required bool isDark,
  required Size size,
  required double textScale,
}) async {
  tester.view.physicalSize = size * 3.0;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        theme: AppTheme.build(color, false),
        darkTheme: AppTheme.build(color, true),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: const ThemeProbeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('varredura de tema: 8 seeds x 2 brilhancias', () {
    for (final color in ThemeColor.values) {
      for (final isDark in [true, false]) {
        final mode = isDark ? 'escuro' : 'claro';

        testWidgets('${color.name} $mode passa contraste de texto', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await _pumpProbe(
            tester,
            color: color,
            isDark: isDark,
            size: const Size(360, 800),
            textScale: 1.0,
          );

          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });

        testWidgets('${color.name} $mode tem alvos de toque adequados', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await _pumpProbe(
            tester,
            color: color,
            isDark: isDark,
            size: const Size(360, 800),
            textScale: 1.0,
          );

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          handle.dispose();
        });
      }
    }
  });

  group('matriz de resiliencia de dispositivo', () {
    for (final spec in _sizes) {
      for (final isDark in [true, false]) {
        final mode = isDark ? 'escuro' : 'claro';

        testWidgets('${spec.name} $mode nao estoura', (tester) async {
          await _pumpProbe(
            tester,
            color: ThemeColor.esmeralda,
            isDark: isDark,
            size: spec.size,
            textScale: spec.textScale,
          );

          // Overflow lanca excecao em teste: rede de regressao de graca.
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('funcional com rolagem a 200% de escala de texto', (
      tester,
    ) async {
      await _pumpProbe(
        tester,
        color: ThemeColor.esmeralda,
        isDark: true,
        size: const Size(360, 800),
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('integridade da troca de tema', () {
    testWidgets('a cor efetiva do texto muda ao virar o modo', (tester) async {
      Color colorOfTitle() => tester
          .renderObject<RenderParagraph>(find.text('Escala tipografica'))
          .text
          .style!
          .color!;

      await _pumpProbe(
        tester,
        color: ThemeColor.oceano,
        isDark: false,
        size: const Size(360, 800),
        textScale: 1.0,
      );
      final light = colorOfTitle();

      await _pumpProbe(
        tester,
        color: ThemeColor.oceano,
        isDark: true,
        size: const Size(360, 800),
        textScale: 1.0,
      );
      final dark = colorOfTitle();

      // Se estas forem iguais, alguma cor foi resolvida uma vez em vez de ser
      // derivada do tema ativo a cada build. E o defeito que produz texto
      // claro em fundo claro.
      expect(light, isNot(equals(dark)));
    });
  });

  group('invariancia da cena do campo ao seed', () {
    test('turfa, linhas e cores de posicao nao mudam com o seed', () {
      // A prova verificavel por maquina da regra "o campo e uma superficie
      // fotografica, nao tematica". Se alguem ligar a turfa ao seed, isto
      // falha imediatamente.
      final referencia = AppTheme.build(ThemeColor.esmeralda, true)
          .extension<PitchTheme>()!;

      for (final color in ThemeColor.values) {
        final atual =
            AppTheme.build(color, true).extension<PitchTheme>()!;

        expect(atual.turfNear, referencia.turfNear, reason: color.name);
        expect(atual.turfMid, referencia.turfMid, reason: color.name);
        expect(atual.turfFar, referencia.turfFar, reason: color.name);
        expect(atual.lineColor, referencia.lineColor, reason: color.name);
        expect(atual.captainGold, referencia.captainGold, reason: color.name);
        expect(
          atual.positionColors,
          referencia.positionColors,
          reason: color.name,
        );
        expect(atual.teamAccents, referencia.teamAccents, reason: color.name);
      }
    });

    test('noite e dia sao cenas diferentes, nao a mesma com texto invertido', () {
      final noite = AppTheme.build(ThemeColor.esmeralda, true)
          .extension<PitchTheme>()!;
      final dia = AppTheme.build(ThemeColor.esmeralda, false)
          .extension<PitchTheme>()!;

      expect(noite.turfNear, isNot(dia.turfNear));
      expect(noite.vignetteStrength, greaterThan(dia.vignetteStrength));
      expect(noite.floodlightIntensity, greaterThan(dia.floodlightIntensity));
    });
  });
}
