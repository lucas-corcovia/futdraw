import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/formation.dart';
import 'package:futdraw/models/player.dart';

/// Resultado da atribuicao: qual jogador ocupa qual slot, mais o que sobrou e
/// o que faltou.
///
/// **E um view model derivado, nao uma mutacao.** Nada aqui escreve em
/// `Player.position`. O codigo anterior (`_reorganizeTeamByTactic`) mutava as
/// instancias in place, editando em silencio os mesmos objetos que a tela
/// anterior ainda segurava. Aqui esse defeito nao pode acontecer: nao existe
/// caminho que escreva no jogador.
class SlotAssignment {
  const SlotAssignment({
    required this.bySlot,
    required this.bench,
    required this.emptySlots,
    required this.outOfPositionPlayerIds,
  });

  final Map<String, Player> bySlot;

  /// Quem sobrou. Nunca escondido: vai para a faixa "Banco" abaixo do campo.
  final List<Player> bench;

  /// Slots que o elenco nao preencheu. Renderizados como token fantasma.
  final Set<String> emptySlots;

  /// Quem entrou fora da propria posicao. Ganha um anel secundario pontilhado,
  /// para o usuario ver que a formacao nao encaixou perfeitamente.
  final Set<String> outOfPositionPlayerIds;

  Player? playerAt(String slotId) => bySlot[slotId];

  bool isOutOfPosition(Player player) =>
      outOfPositionPlayerIds.contains(player.id);

  bool get isPerfectFit => emptySlots.isEmpty && bench.isEmpty;
}

abstract final class FormationAssigner {
  /// Distribui os jogadores nos slots da formacao.
  ///
  /// Determinista: mesma entrada, mesma saida, sempre. Nenhum `shuffle`,
  /// nenhum `Random`, e todos os criterios de ordenacao formam ordem total.
  static SlotAssignment assign(List<Player> players, Formation formation) {
    final pools = <PlayerPosition, List<Player>>{
      for (final position in PlayerPosition.values)
        position: players.where((p) => p.position == position).toList()
          ..sort(_byRating),
    };
    final demand = <PlayerPosition, int>{
      for (final position in PlayerPosition.values)
        position: formation.countOf(position),
    };

    final outOfPosition = <String>{};

    // Passe 1 -- realocacao entre setores, **antes** de posicionar.
    //
    // A ordem importa e nao e detalhe: se a cobertura fosse resolvida depois
    // do posicionamento, quando faltasse um atacante o passe exato ja teria
    // consumido os melhores meias e sobraria justamente o pior para subir. O
    // certo e o contrario -- quem sobe e o melhor, e um reserva assume o meio.
    for (final role in const [
      PlayerPosition.defender,
      PlayerPosition.midfielder,
      PlayerPosition.striker,
    ]) {
      var missing = demand[role]! - pools[role]!.length;
      while (missing > 0) {
        final donor = _takeDonor(pools, demand, role);
        if (donor == null) break;
        pools[role]!.add(donor);
        outOfPosition.add(donor.id);
        missing--;
      }
      pools[role]!.sort(_byRating);
    }

    final bySlot = <String, Player>{};
    final unfilled = <FormationSlot>[];

    // Passe 2 -- posicionamento: das linhas mais recuadas para as mais
    // adiantadas, e dentro da linha do slot mais central para fora. O jogador
    // de maior nota cai no lugar mais central, que e o que um grafico de
    // escalacao real faz.
    for (final row in formation.rows) {
      final slots = formation.slotsInRow(row)..sort(_byCentrality);
      for (final slot in slots) {
        final pool = pools[slot.role]!;
        if (pool.isEmpty) {
          unfilled.add(slot);
        } else {
          bySlot[slot.id] = pool.removeAt(0);
        }
      }
    }

    // Passe 3 -- sobra: quem restou vai para o banco, nunca some.
    final bench = <Player>[
      for (final position in PlayerPosition.values) ...pools[position]!,
    ]..sort(_byRating);

    return SlotAssignment(
      bySlot: bySlot,
      bench: bench,
      emptySlots: unfilled.map((s) => s.id).toSet(),
      outOfPositionPlayerIds: outOfPosition,
    );
  }

  /// Quem cobre um buraco, e com que criterio.
  ///
  /// A logica nao e "pega qualquer um": um meio que desce para a zaga deve ser
  /// o de menor nota do setor, e um meio que sobe para o ataque deve ser o de
  /// maior. E a mesma intencao do antigo `_reorganizeTeamByTactic`, agora sem
  /// mutar ninguem.
  /// So doa quem tem sobra em relacao a propria demanda: tirar de um setor que
  /// tambem esta no limite so mudaria o buraco de lugar.
  static Player? _takeDonor(
    Map<PlayerPosition, List<Player>> pools,
    Map<PlayerPosition, int> demand,
    PlayerPosition target,
  ) {
    final preferences = switch (target) {
      PlayerPosition.defender => [
        (PlayerPosition.midfielder, _Pick.lowest),
        (PlayerPosition.striker, _Pick.lowest),
      ],
      PlayerPosition.midfielder => [
        (PlayerPosition.defender, _Pick.lowest),
        (PlayerPosition.striker, _Pick.lowest),
      ],
      PlayerPosition.striker => [
        (PlayerPosition.midfielder, _Pick.highest),
        (PlayerPosition.defender, _Pick.highest),
      ],
      PlayerPosition.goalkeeper => const <(PlayerPosition, _Pick)>[],
    };

    for (final (source, pick) in preferences) {
      final pool = pools[source]!;
      if (pool.length <= demand[source]!) continue;
      // A lista esta ordenada por nota decrescente.
      return pick == _Pick.highest ? pool.removeAt(0) : pool.removeLast();
    }
    return null;
  }

  /// Nota decrescente, depois nome, depois id. Os dois ultimos criterios sao o
  /// que garante ordem total, e portanto determinismo.
  static int _byRating(Player a, Player b) {
    final byNota = b.nota.compareTo(a.nota);
    if (byNota != 0) return byNota;
    final byName = a.nome.compareTo(b.nome);
    if (byName != 0) return byName;
    return a.id.compareTo(b.id);
  }

  static int _byCentrality(FormationSlot a, FormationSlot b) {
    final byCentre = a.centrality.compareTo(b.centrality);
    if (byCentre != 0) return byCentre;
    final byX = a.position.dx.compareTo(b.position.dx);
    if (byX != 0) return byX;
    return a.id.compareTo(b.id);
  }
}

enum _Pick { highest, lowest }
