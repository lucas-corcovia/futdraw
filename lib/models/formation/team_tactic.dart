import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';

/// Quantos jogadores por setor uma tatica pede.
///
/// Existe para separar duas coisas que o codigo antigo misturava: **quantos
/// de cada setor** (isto aqui) e **quem vai em qual slot**
/// (`FormationAssigner`). O antigo `_reorganizeTeamByTactic` decidia as duas
/// com numeros cravados no meio da tela e, pior, aplicava o resultado
/// mutando `Player.position` e jogando fora quem sobrava.
class TeamTactic {
  const TeamTactic({
    required this.goalkeepers,
    required this.defenders,
    required this.midfielders,
    required this.strikers,
  });

  final int goalkeepers;
  final int defenders;
  final int midfielders;
  final int strikers;

  int get outfield => defenders + midfielders + strikers;
  int get total => goalkeepers + outfield;

  /// Padrao por modalidade, igual ao que `add.group.dart` oferece no
  /// formulario do grupo. So vale quando o grupo nao gravou tatica.
  static TeamTactic defaultFor(FieldType type) => switch (type) {
        FieldType.quadra => const TeamTactic(
            goalkeepers: 1, defenders: 1, midfielders: 2, strikers: 1),
        FieldType.society => const TeamTactic(
            goalkeepers: 1, defenders: 2, midfielders: 3, strikers: 1),
        FieldType.campo => const TeamTactic(
            goalkeepers: 1, defenders: 4, midfielders: 4, strikers: 2),
        FieldType.livre => const TeamTactic(
            goalkeepers: 1, defenders: 2, midfielders: 3, strikers: 1),
      };

  /// Le a tatica do grupo que a tela anterior ja tem em maos.
  ///
  /// As duas telas que abrem o campo (`team_generator_view` e
  /// `ai_team_sort_view`) seguram o `Group` inteiro e ate agora encaminhavam
  /// so o `tipoCampo`, descartando os quatro inteiros da tatica.
  static TeamTactic? ofGroup(Group? group) => group == null
      ? null
      : fromGroup(
          goalkeepers: group.taticaGoleiros,
          defenders: group.taticaDefensores,
          midfielders: group.taticaMeias,
          strikers: group.taticaAtacantes,
        );

  /// A tatica gravada no grupo, quando ela existe e faz sentido.
  ///
  /// `add.group.dart` grava zeros para `FieldType.livre` e nao valida a soma
  /// no save, entao uma tatica invalida chega aqui. Quando isso acontece o
  /// padrao da modalidade vale mais do que um numero que o usuario nem sabe
  /// que salvou.
  static TeamTactic? fromGroup({
    required int? goalkeepers,
    required int? defenders,
    required int? midfielders,
    required int? strikers,
  }) {
    final tactic = TeamTactic(
      goalkeepers: goalkeepers ?? 0,
      defenders: defenders ?? 0,
      midfielders: midfielders ?? 0,
      strikers: strikers ?? 0,
    );
    return tactic.outfield > 0 ? tactic : null;
  }

  /// Ajusta a tatica ao elenco que existe de verdade, **sem cortar ninguem**.
  ///
  /// A tatica e uma *proporcao*, nao um teto. Um grupo com tatica 4-4-2 e um
  /// time de 12 na linha vira 4-5-3, nao 4-4-2 com dois jogadores apagados --
  /// que era o que o `.take()` do codigo antigo fazia, sumindo com o jogador
  /// da lista, do campo, da imagem compartilhada e do sorteio salvo.
  ///
  /// Goleiro nao entra no rateio: quantos goleiros o time tem e um fato do
  /// sorteio, nao uma escolha de tatica.
  TeamTactic scaledTo(List<Player> players) {
    final keepers = players.where((p) => p.position == PlayerPosition.goalkeeper).length;
    final available = players.length - keepers;
    if (available <= 0) {
      return TeamTactic(
          goalkeepers: keepers, defenders: 0, midfielders: 0, strikers: 0);
    }
    if (outfield == 0) {
      return TeamTactic(
          goalkeepers: keepers,
          defenders: 0,
          midfielders: available,
          strikers: 0);
    }

    // Reparte proporcionalmente e depois distribui o resto pelo maior erro de
    // arredondamento (maior resto). Sem isso, tres divisoes com `floor`
    // perdem ate dois jogadores justamente no caso que este metodo existe
    // para proteger.
    final exact = <PlayerPosition, double>{
      PlayerPosition.defender: defenders * available / outfield,
      PlayerPosition.midfielder: midfielders * available / outfield,
      PlayerPosition.striker: strikers * available / outfield,
    };

    final counts = <PlayerPosition, int>{
      for (final entry in exact.entries) entry.key: entry.value.floor(),
    };

    var remainder = available - counts.values.reduce((a, b) => a + b);
    final byRemainder = exact.keys.toList()
      ..sort((a, b) {
        final ra = exact[a]! - counts[a]!;
        final rb = exact[b]! - counts[b]!;
        final cmp = rb.compareTo(ra);
        // Empate vai para o meio-campo: e a linha que absorve sobra sem
        // desequilibrar o time, e e o que um tecnico faz na pelada.
        return cmp != 0 ? cmp : _tieBreak(a).compareTo(_tieBreak(b));
      });

    for (var i = 0; remainder > 0; i = (i + 1) % byRemainder.length) {
      counts[byRemainder[i]] = counts[byRemainder[i]]! + 1;
      remainder--;
    }

    return TeamTactic(
      goalkeepers: keepers,
      defenders: counts[PlayerPosition.defender]!,
      midfielders: counts[PlayerPosition.midfielder]!,
      strikers: counts[PlayerPosition.striker]!,
    );
  }

  static int _tieBreak(PlayerPosition position) => switch (position) {
        PlayerPosition.midfielder => 0,
        PlayerPosition.defender => 1,
        PlayerPosition.striker => 2,
        PlayerPosition.goalkeeper => 3,
      };

  /// Rotulo brasileiro, do fundo para a frente, sem o goleiro: "4-4-2".
  String get label => [defenders, midfielders, strikers]
      .where((n) => n > 0)
      .join('-');

  @override
  bool operator ==(Object other) =>
      other is TeamTactic &&
      other.goalkeepers == goalkeepers &&
      other.defenders == defenders &&
      other.midfielders == midfielders &&
      other.strikers == strikers;

  @override
  int get hashCode =>
      Object.hash(goalkeepers, defenders, midfielders, strikers);

  @override
  String toString() => 'TeamTactic($goalkeepers-$label)';
}

