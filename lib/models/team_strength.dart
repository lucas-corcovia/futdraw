import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

/// Forca de um time por setor.
///
/// Alimenta tanto o comparativo dentro do app quanto a faixa do cartao de
/// compartilhamento, do mesmo calculo, para os dois nunca discordarem.
class TeamStrength {
  const TeamStrength({
    required this.defence,
    required this.midfield,
    required this.attack,
    required this.overall,
    required this.squadSize,
  });

  final double defence;
  final double midfield;
  final double attack;

  /// Media dos jogadores de linha, o mesmo criterio de `Team.averageSkill`:
  /// goleiro fora, porque a nota dele mede outra coisa.
  final double overall;
  final int squadSize;

  static TeamStrength of(List<Player> players) {
    double meanOf(PlayerPosition position) {
      final group = players.where((p) => p.position == position).toList();
      if (group.isEmpty) return 0;
      return group.fold(0.0, (sum, p) => sum + p.nota) / group.length;
    }

    final outfield = players
        .where((p) => p.position != PlayerPosition.goalkeeper)
        .toList();

    return TeamStrength(
      defence: meanOf(PlayerPosition.defender),
      midfield: meanOf(PlayerPosition.midfielder),
      attack: meanOf(PlayerPosition.striker),
      overall: outfield.isEmpty
          ? 0
          : outfield.fold(0.0, (sum, p) => sum + p.nota) / outfield.length,
      squadSize: players.length,
    );
  }

  /// Um setor sem nenhum jogador nao vale zero: vale "nao existe". A barra
  /// desenha vazia em vez de fingir uma forca minima.
  bool get hasDefence => defence > 0;
  bool get hasMidfield => midfield > 0;
  bool get hasAttack => attack > 0;
}

/// Quao desequilibrado ficou o sorteio.
class DrawBalance {
  const DrawBalance({required this.strengths, required this.spread});

  final List<TeamStrength> strengths;

  /// Diferenca entre a maior e a menor media. E o numero que responde a
  /// pergunta que o usuario faz olhando a tela: "ficou justo?".
  final double spread;

  static DrawBalance of(List<List<Player>> teams) {
    final strengths = teams.map(TeamStrength.of).toList();
    if (strengths.isEmpty) {
      return const DrawBalance(strengths: [], spread: 0);
    }
    final overalls = strengths.map((s) => s.overall).toList();
    final highest = overalls.reduce((a, b) => a > b ? a : b);
    final lowest = overalls.reduce((a, b) => a < b ? a : b);
    return DrawBalance(strengths: strengths, spread: highest - lowest);
  }

  /// Delta de um time em relacao a media geral do sorteio.
  double deltaFor(int index) {
    if (strengths.isEmpty) return 0;
    final mean =
        strengths.fold(0.0, (sum, s) => sum + s.overall) / strengths.length;
    return strengths[index].overall - mean;
  }
}
