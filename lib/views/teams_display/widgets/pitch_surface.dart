import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:futdraw/theme/pitch_theme.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_painters.dart';

/// A turfa. Desenha pelo shader quando ele existe, pelo `CustomPainter` quando
/// nao existe.
///
/// **Por que o fallback nao e provisorio.** Ele responde por tres casos que
/// nunca vao embora:
///
/// 1. **O primeiro frame.** `FragmentProgram.fromAsset` e assincrono. Sem
///    fallback o campo pisca preto antes de aparecer, que e pior do que nao ter
///    shader nenhum.
/// 2. **A captura do PNG.** flutter/flutter#163521: shader dentro de
///    `RepaintBoundary.toImage` sai espelhado na vertical em parte dos
///    aparelhos Android. A imagem compartilhada e o produto que sai do app;
///    ela desenha pelo painter, sempre (`enabled: false`).
/// 3. **O teste.** Em `flutter test` o `.frag` nao esta compilado no bundle. A
///    varredura de tema continua provando o que provava antes.
///
/// O que o shader acrescenta e uma coisa so, mas e a que faltava: a listra de
/// corte deixa de ser duas cores alternadas e vira o termo anisotropico -- a
/// lamina deitada devolve ou engole luz conforme a direcao do refletor, e por
/// isso o contraste **inverte de sinal** ao cruzar o eixo da luz. E o que
/// separa um campo de transmissao de um adesivo listrado.
class PitchSurface extends StatefulWidget {
  const PitchSurface({super.key, required this.theme, this.enabled = true});

  final PitchTheme theme;

  /// `false` forca o caminho do `CustomPainter`. Quem captura PNG passa false.
  final bool enabled;

  /// Desliga o shader em toda a suite de teste, de uma vez. Ligado em
  /// `test/flutter_test_config.dart`.
  @visibleForTesting
  static bool debugDisableShader = false;

  @override
  State<PitchSurface> createState() => _PitchSurfaceState();
}

class _PitchSurfaceState extends State<PitchSurface> {
  static const String _asset = 'assets/shaders/pitch_turf.frag';

  /// Programa compartilhado por todas as instancias: sao quantos times houver
  /// no `TabBarView`, e compilar o mesmo shader uma vez por aba seria
  /// desperdicio puro.
  static ui.FragmentProgram? _program;
  static Future<void>? _loading;
  static bool _unavailable = false;

  ui.FragmentShader? _shader;

  CustomPainter? _painter;
  Object? _painterKey;

  @override
  void initState() {
    super.initState();
    _ensureProgram();
  }

  @override
  void didUpdateWidget(PitchSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) _ensureProgram();
  }

  void _ensureProgram() {
    if (!_shaderWanted) return;
    if (_program != null) {
      _shader ??= _program!.fragmentShader();
      return;
    }

    _loading ??= _load();
    _loading!.then((_) {
      if (!mounted || _program == null) return;
      setState(() => _shader ??= _program!.fragmentShader());
    });
  }

  static Future<void> _load() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(_asset);
    } catch (error, stack) {
      // Aparelho sem Impeller, bundle sem o shader compilado, driver que
      // recusou o programa: qualquer um destes cai no painter e o usuario
      // nao ve diferenca de funcionamento, so de acabamento.
      _unavailable = true;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'futdraw',
          context: ErrorDescription('compilando $_asset; usando o fallback'),
          silent: true,
        ),
      );
    }
  }

  bool get _shaderWanted =>
      widget.enabled && !_unavailable && !PitchSurface.debugDisableShader;

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  /// O painter sobrevive aos rebuilds.
  ///
  /// `PitchView` reconstroi a cada frame da coreografia de entrada, e um
  /// painter novo por frame alocaria um `MaskFilter.blur` por frame -- custo
  /// puro, ja que `shouldRepaint` ia recusar repintar de qualquer jeito.
  CustomPainter _painterFor(PitchTheme theme, ui.FragmentShader? shader) {
    final key = (theme, shader);
    if (_painter != null && _painterKey == key) return _painter!;

    _painterKey = key;
    return _painter = shader == null
        ? PitchSurfacePainter(theme: theme)
        : PitchTurfPainter(theme: theme, shader: shader);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painterFor(widget.theme, _shaderWanted ? _shader : null),
      isComplex: true,
      willChange: false,
    );
  }
}

/// Ponte entre `PitchTheme` e os uniformes do `pitch_turf.frag`.
///
/// A ordem dos slots e a ordem de declaracao no GLSL, achatada: um `vec2`
/// ocupa dois, um `vec3` ocupa tres. Trocar a ordem la sem trocar aqui nao da
/// erro de compilacao -- da um campo roxo. Por isso os slots sao um contador
/// que anda na mesma ordem do `.frag`, e nao indices soltos, e por isso
/// `test/views/pitch_surface_test.dart` le o `.frag` e compara a lista.
class PitchTurfPainter extends CustomPainter {
  PitchTurfPainter({required this.theme, required this.shader});

  final PitchTheme theme;
  final ui.FragmentShader shader;

  /// Mesma contagem do fallback: trocar de caminho nao pode mudar o desenho.
  static const double _stripeCount = 9;

  final Paint _paint = Paint();
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(kPitchCornerRadius),
    );

    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      _shadow..color = theme.pitchShadow,
    );

    // O shader preenche opaco de borda a borda; sem o clip o gramado vira um
    // retangulo de cantos vivos por cima da tela.
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, _paint..shader = _configured(size));
    canvas.restore();
  }

  ui.FragmentShader _configured(Size size) {
    var slot = 0;
    void f(double value) => shader.setFloat(slot++, value);
    void rgb(Color color) {
      f(color.r);
      f(color.g);
      f(color.b);
    }

    f(size.width);
    f(size.height);

    rgb(theme.turfNear);
    rgb(theme.turfMid);
    rgb(theme.turfFar);

    // `Alignment` vai de -1 a 1; o shader pensa em uv de 0 a 1.
    f((theme.floodlightCenter.x + 1) / 2);
    f((theme.floodlightCenter.y + 1) / 2);
    f(theme.floodlightIntensity);
    rgb(theme.floodlightColor);

    f(_stripeCount);
    f(theme.stripeStrength);
    f(theme.turfWear);

    rgb(theme.vignetteColor);
    f(theme.vignetteStrength);
    f(theme.noiseOpacity);

    return shader;
  }

  @override
  bool shouldRepaint(PitchTurfPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.shader != shader;
}
