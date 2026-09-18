import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _widthOf(String text, {FontWeight weight = FontWeight.w400}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Kanit',
        fontSize: 32,
        fontWeight: weight,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

void main() {
  group('metrica de Kanit', () {
    test('os pesos do bundle sao reais, nao negrito sintetico', () {
      // Negrito sintetizado pelo engine mantem a metrica do regular; um peso
      // de verdade muda a largura. Este teste falha se alguem remover os TTFs
      // de Medium/SemiBold/Bold do pubspec.
      final regular = _widthOf('Media', weight: FontWeight.w400);
      final semibold = _widthOf('Media', weight: FontWeight.w600);
      final bold = _widthOf('Media', weight: FontWeight.w700);

      expect(regular, isNot(closeTo(semibold, 0.01)));
      expect(semibold, isNot(closeTo(bold, 0.01)));
    });

    test('Kanit NAO tem digitos tabulares, nem com FontFeature.tabularFigures', () {
      // Achado que justifica o widget TabularNumber existir: Kanit nao traz a
      // feature OpenType `tnum`, entao pedi-la e no-op, e os digitos sao
      // fortemente proporcionais -- o "1" mede pouco mais da metade do "0".
      // Sem largura fixa, a media do placar dancaria a cada troca de jogador.
      final widths = <String, double>{
        for (final d in '0123456789'.split('')) d: _widthOf(d),
      };
      final min = widths.values.reduce((a, b) => a < b ? a : b);
      final max = widths.values.reduce((a, b) => a > b ? a : b);

      expect(
        max - min,
        greaterThan(1.0),
        reason:
            'Se isto passar a falhar, Kanit ganhou digitos tabulares e o '
            'TabularNumber pode ser trocado por FontFeature.tabularFigures. '
            'Larguras medidas: $widths',
      );
    });
  });
}
