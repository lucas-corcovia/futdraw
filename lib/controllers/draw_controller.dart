import 'dart:math';

import 'package:futdraw/models/player.dart';
import 'package:futdraw/models/team.dart';

class DrawController {
  List<List<Player>> sortearTimesBalanceados(
    List<Player> jogadores,
    int numTimes,
  ) {
    final rand = Random();

    final linha = [...jogadores.where((j) => !j.isGoalkeeper)];
    final goleiros = [...jogadores.where((j) => j.isGoalkeeper)];

    if (linha.length < numTimes || goleiros.length < numTimes) {
      throw Exception(
        'Número insuficiente de jogadores ou goleiros para os times informados.',
      );
    }

    linha.shuffle(rand);
    goleiros.shuffle(rand);

    linha.sort((a, b) => b.nota.compareTo(a.nota as num));
    goleiros.sort((a, b) => b.nota.compareTo(a.nota as num));

    final times = List.generate(numTimes, (_) => Team());

    for (final goleiro in goleiros) {
      final timeMaisFraco = times.reduce(
        (a, b) => a.somaNotasGoleiros < b.somaNotasGoleiros ? a : b,
      );
      timeMaisFraco.jogadores.add(goleiro);
    }

    for (final jogador in linha) {
      final timeMaisFraco = times.reduce(
        (a, b) => a.somaNotasLinha < b.somaNotasLinha ? a : b,
      );
      timeMaisFraco.jogadores.add(jogador);
    }

    return times.map((t) => t.jogadores).toList();
  }
}
