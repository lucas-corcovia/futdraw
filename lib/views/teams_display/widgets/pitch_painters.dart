import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/theme/pitch_theme.dart';

const double kPitchCornerRadius = 16;

/// Superficie do gramado: sombra, gradiente, listras de corte, refletor, grao
/// e vinheta, tudo num `paint()` so.
///
/// A versao anterior empilhava tres `ClipRRect` de widget, um por camada, e
/// cada um podia forcar uma camada de clip antialiased. Aqui e um
/// `canvas.clipRRect` unico.
///
/// **Orcamento: zero `saveLayer`.** Refletor e vinheta sao `drawRect` com
/// shader de gradiente; `clipRRect` e save/restore, que e outra coisa e e
/// barato.
class PitchSurfacePainter extends CustomPainter {
  PitchSurfacePainter({required this.theme});

  final PitchTheme theme;

  /// Ruido em coordenadas normalizadas, sorteado uma vez com semente fixa.
  ///
  /// E o truque mais barato contra o aspecto plastico de um gradiente chapado,
  /// e o que evita banding em telas de 8 bits baratas -- o unico ganho real
  /// que um fragment shader traria aqui, por uma fracao do custo e sem
  /// pipeline de assets nem caminho de fallback de primeiro frame.
  static final List<Offset> _noise = _buildNoise();

  static List<Offset> _buildNoise() {
    final random = math.Random(20260904);
    return List<Offset>.generate(
      1400,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
  }

  // Alocados uma vez, nao dentro do paint. O MowStripePainter anterior criava
  // um Paint dentro do laco de listras, dez por pintura.
  final Paint _fill = Paint();
  final Paint _stripe = Paint();
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
  late final Paint _noisePaint = Paint()
    ..strokeWidth = 1.4
    ..strokeCap = StrokeCap.round;

  Size? _cachedSize;
  List<Offset>? _scaledNoise;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(kPitchCornerRadius),
    );

    // Sombra do gramado sobre o fundo da tela. Substitui os dois BoxShadow do
    // Container antigo, que eram duas camadas desfocadas.
    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      _shadow..color = theme.pitchShadow,
    );

    canvas.save();
    canvas.clipRRect(rrect);

    // Turfa.
    _fill.shader = RadialGradient(
      center: const Alignment(0, -0.05),
      radius: 1.05,
      colors: [theme.turfNear, theme.turfMid, theme.turfFar],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, _fill);
    _fill.shader = null;

    _paintStripes(canvas, size);
    _paintFloodlight(canvas, rect);
    _paintNoise(canvas, size);
    _paintVignette(canvas, rect);

    canvas.restore();
  }

  /// Listras de corte. Cada faixa ganha um degrade suave nas bordas em vez do
  /// `drawRect` duro anterior: corte de grama nao tem aresta.
  void _paintStripes(Canvas canvas, Size size) {
    const stripes = 9;
    final height = size.height / stripes;

    for (var i = 0; i < stripes; i++) {
      final top = i * height;
      final band = Rect.fromLTWH(0, top, size.width, height);
      final color = i.isEven ? theme.stripeLight : theme.stripeDark;

      _stripe.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(band);
      canvas.drawRect(band, _stripe);
    }
    _stripe.shader = null;
  }

  /// Poca de luz do refletor. No tema de dia vira uma lavagem quente ampla.
  void _paintFloodlight(Canvas canvas, Rect rect) {
    _fill.shader = RadialGradient(
      center: theme.floodlightCenter,
      radius: 0.95,
      colors: [
        theme.floodlightColor.withValues(alpha: theme.floodlightIntensity),
        theme.floodlightColor.withValues(alpha: 0),
      ],
      stops: const [0.0, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, _fill);
    _fill.shader = null;
  }

  void _paintNoise(Canvas canvas, Size size) {
    if (theme.noiseOpacity <= 0) return;

    if (_cachedSize != size || _scaledNoise == null) {
      _cachedSize = size;
      _scaledNoise = [
        for (final point in _noise)
          Offset(point.dx * size.width, point.dy * size.height),
      ];
    }

    // Uma chamada so, em lote. Nunca N drawCircle.
    canvas.drawPoints(
      ui.PointMode.points,
      _scaledNoise!,
      _noisePaint
        ..color = const Color(0xFFFFFFFF).withValues(alpha: theme.noiseOpacity),
    );
  }

  void _paintVignette(Canvas canvas, Rect rect) {
    _fill.shader = RadialGradient(
      center: Alignment.center,
      radius: 0.9,
      colors: [
        theme.vignetteColor.withValues(alpha: 0),
        theme.vignetteColor.withValues(alpha: theme.vignetteStrength),
      ],
      stops: const [0.45, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, _fill);
    _fill.shader = null;
  }

  @override
  bool shouldRepaint(covariant PitchSurfacePainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Marcacoes do campo, com o desenho progressivo da coreografia de entrada.
///
/// `progress` de 0 a 1 revela as linhas sendo tracadas. As metricas do caminho
/// sao calculadas **uma vez** por tamanho e modalidade; por frame so acontece
/// o `extractPath`.
class PitchLinesPainter extends CustomPainter {
  PitchLinesPainter({
    required this.theme,
    required this.fieldType,
    required this.progress,
  });

  final PitchTheme theme;
  final FieldType fieldType;
  final double progress;

  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;

  /// Segunda passada, borrada, para a linha ter borda de cal em vez de um
  /// traco duro. No tema noturno vira um leve bloom; no de dia, a sombra por
  /// baixo que impede a linha de estourar contra grama clara.
  final Paint _bleed = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);

  Size? _cachedSize;
  FieldType? _cachedType;
  List<ui.PathMetric>? _metrics;
  double _totalLength = 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    _ensureMetrics(size);
    final metrics = _metrics;
    if (metrics == null) return;

    final revealed = _totalLength * progress.clamp(0.0, 1.0);
    var consumed = 0.0;

    final path = Path();
    for (final metric in metrics) {
      if (consumed >= revealed) break;
      final take = math.min(metric.length, revealed - consumed);
      path.addPath(metric.extractPath(0, take), Offset.zero);
      consumed += metric.length;
    }

    _line
      ..color = theme.lineColor
      ..strokeWidth = theme.lineWidth;

    final bleedAlpha = theme.lineUnderShadow.a;
    if (bleedAlpha > 0) {
      canvas.drawPath(
        path,
        _bleed
          ..color = theme.lineUnderShadow
          ..strokeWidth = theme.lineWidth + 1.5,
      );
    } else {
      canvas.drawPath(
        path,
        _bleed
          ..color = theme.lineColor.withValues(alpha: 0.18)
          ..strokeWidth = theme.lineWidth + 2.5,
      );
    }

    canvas.drawPath(path, _line);
  }

  void _ensureMetrics(Size size) {
    if (_cachedSize == size && _cachedType == fieldType && _metrics != null) {
      return;
    }
    _cachedSize = size;
    _cachedType = fieldType;

    final path = PitchGeometry.build(size, fieldType);
    _metrics = path.computeMetrics().toList();
    _totalLength = _metrics!.fold(0.0, (sum, m) => sum + m.length);
  }

  @override
  bool shouldRepaint(covariant PitchLinesPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.fieldType != fieldType ||
      oldDelegate.theme != theme;
}

/// Geometria das marcacoes, por modalidade.
///
/// A geometria herdada dos painters antigos era boa e foi preservada. O que
/// mudou: `math.pi / 2` no lugar do magico `1.5708`, arcos de penalti por
/// `Path.addArc` em vez de `save/clipRect/restore`, e `FieldType.livre` com
/// desenho proprio -- antes ele caia no campo de 11 contra 11 e desenhava area
/// de penalti num 3 contra 3.
abstract final class PitchGeometry {
  static Path build(Size size, FieldType fieldType) => switch (fieldType) {
    FieldType.quadra => _quadra(size),
    FieldType.society => _society(size),
    FieldType.campo => _campo(size),
    FieldType.livre => _livre(size),
  };

  static void _perimeter(Path path, Size size) {
    path.addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(kPitchCornerRadius),
      ),
    );
  }

  static void _halfway(Path path, Size size) {
    path
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
  }

  static void _centreCircle(Path path, Size size, double radiusFactor) {
    final centre = Offset(size.width / 2, size.height / 2);
    path.addOval(
      Rect.fromCircle(center: centre, radius: size.width * radiusFactor),
    );
    path.addOval(Rect.fromCircle(center: centre, radius: 3.5));
  }

  static void _cornerArcs(Path path, Size size) {
    final r = size.width * 0.05;
    const quarter = math.pi / 2;
    path
      ..addArc(Rect.fromLTWH(-r, -r, r * 2, r * 2), 0, quarter)
      ..addArc(
        Rect.fromLTWH(size.width - r, -r, r * 2, r * 2),
        quarter,
        quarter,
      )
      ..addArc(
        Rect.fromLTWH(size.width - r, size.height - r, r * 2, r * 2),
        math.pi,
        quarter,
      )
      ..addArc(
        Rect.fromLTWH(-r, size.height - r, r * 2, r * 2),
        math.pi * 1.5,
        quarter,
      );
  }

  static void _boxes(
    Path path,
    Size size, {
    required double widthFactor,
    required double heightFactor,
  }) {
    final w = size.width * widthFactor;
    final h = size.height * heightFactor;
    final left = (size.width - w) / 2;
    path
      ..addRect(Rect.fromLTWH(left, 0, w, h))
      ..addRect(Rect.fromLTWH(left, size.height - h, w, h));
  }

  static Path _campo(Size size) {
    final path = Path();
    _perimeter(path, size);
    _halfway(path, size);
    _centreCircle(path, size, 0.125);
    _boxes(path, size, widthFactor: 0.5, heightFactor: 0.2);
    _boxes(path, size, widthFactor: 0.3, heightFactor: 0.08);

    final penaltyHeight = size.height * 0.2;
    final spotY = penaltyHeight * 0.62;
    final centreX = size.width / 2;
    path
      ..addOval(Rect.fromCircle(center: Offset(centreX, spotY), radius: 3.5))
      ..addOval(
        Rect.fromCircle(
          center: Offset(centreX, size.height - spotY),
          radius: 3.5,
        ),
      );

    // Arcos "D" desenhados como arco de verdade, nao como circulo recortado.
    final arcRadius = size.height * 0.12;
    final sweep = math.acos(
      ((penaltyHeight - spotY) / arcRadius).clamp(-1.0, 1.0),
    );
    path
      ..addArc(
        Rect.fromCircle(center: Offset(centreX, spotY), radius: arcRadius),
        sweep,
        math.pi - 2 * sweep,
      )
      ..addArc(
        Rect.fromCircle(
          center: Offset(centreX, size.height - spotY),
          radius: arcRadius,
        ),
        math.pi + sweep,
        math.pi - 2 * sweep,
      );

    _cornerArcs(path, size);
    return path;
  }

  static Path _society(Size size) {
    final path = Path();
    _perimeter(path, size);
    _halfway(path, size);
    _centreCircle(path, size, 0.125);
    _boxes(path, size, widthFactor: 0.40, heightFactor: 0.18);

    final spotY = size.height * 0.18 * 0.65;
    final centreX = size.width / 2;
    path
      ..addOval(Rect.fromCircle(center: Offset(centreX, spotY), radius: 3.5))
      ..addOval(
        Rect.fromCircle(
          center: Offset(centreX, size.height - spotY),
          radius: 3.5,
        ),
      );

    _cornerArcs(path, size);
    return path;
  }

  static Path _quadra(Size size) {
    final path = Path();
    _perimeter(path, size);
    _halfway(path, size);
    _centreCircle(path, size, 0.1);

    final arcRadius = size.width * 0.22;
    final spotY = size.height * 0.08;
    final centreX = size.width / 2;

    path
      ..addOval(Rect.fromCircle(center: Offset(centreX, spotY), radius: 3.5))
      ..addOval(
        Rect.fromCircle(
          center: Offset(centreX, size.height - spotY),
          radius: 3.5,
        ),
      )
      // Semicirculos de penalti na linha de fundo.
      ..addArc(
        Rect.fromCircle(center: Offset(centreX, 0), radius: arcRadius),
        0,
        math.pi,
      )
      ..addArc(
        Rect.fromCircle(center: Offset(centreX, size.height), radius: arcRadius),
        math.pi,
        math.pi,
      );

    return path;
  }

  /// Modalidade livre: so o perimetro e a linha de meio.
  ///
  /// Antes caia no desenho de 11 contra 11 e mostrava area de penalti mesmo
  /// num 3 contra 3.
  static Path _livre(Size size) {
    final path = Path();
    _perimeter(path, size);
    _halfway(path, size);
    _centreCircle(path, size, 0.11);
    return path;
  }
}
