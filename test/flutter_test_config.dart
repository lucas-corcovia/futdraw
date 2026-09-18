import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_surface.dart';

/// Carrega as fontes reais do app antes de qualquer teste.
///
/// Sem isto todo teste de golden renderiza em Ahem (o retangulo preto) e a
/// suite inteira passa a nao provar nada -- e a razao numero um de suites
/// golden de Flutter acabarem sem sentido.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // O .frag nao e compilado no bundle de teste, e FragmentProgram.fromAsset
  // falharia de forma assincrona no meio de cada pump. A turfa desenha pelo
  // PitchSurfacePainter aqui -- que e o mesmo caminho da imagem compartilhada.
  PitchSurface.debugDisableShader = true;

  await _loadFont('Kanit', const [
    'assets/fonts/KanitRegular.ttf',
    'assets/fonts/Kanit-Medium.ttf',
    'assets/fonts/Kanit-SemiBold.ttf',
    'assets/fonts/Kanit-Bold.ttf',
  ]);
  await _loadFont('PervitinaDex', const [
    'assets/fonts/PervitinaDex.ttf',
  ]);

  await testMain();
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    loader.addFont(
      File(path).readAsBytes().then(
        (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
      ),
    );
  }
  await loader.load();
}
