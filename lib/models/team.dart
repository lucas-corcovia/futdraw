import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

class Team {
  List<Player> jogadores = [];

  double get somaNotasGoleiros => jogadores
      .where((j) => j.position == PlayerPosition.goalkeeper)
      .fold(0.0, (sum, j) => sum + (j.nota));

  double get somaNotasLinha => jogadores
      .where((j) => j.position != PlayerPosition.goalkeeper)
      .fold(0.0, (sum, j) => sum + (j.nota));

  double get somaNotas => somaNotasGoleiros + somaNotasLinha;
}
