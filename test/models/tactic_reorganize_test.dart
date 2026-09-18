import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/formation_assignment.dart';
import 'package:futdraw/models/formation/formation_catalog.dart';
import 'package:futdraw/models/formation/team_tactic.dart';
import 'package:futdraw/models/player.dart';

/// Reproduz o caminho inteiro de "Reorganizar por Tatica" fora da tela:
/// tatica do grupo -> `scaledTo` -> `FormationCatalog.fromTactic` ->
/// `FormationAssigner.assign`.
///
/// Sao os quatro defeitos do `_reorganizeTeamByTactic` antigo, cada um com um
/// teste que falha se ele voltar.
void main() {
  ({int defenders, int midfielders, int strikers, SlotAssignment assignment})
      reorganize({
    required TeamTactic? groupTactic,
    required FieldType fieldType,
    required List<Player> players,
  }) {
    final base = groupTactic ?? TeamTactic.defaultFor(fieldType);
    final tactic = base.scaledTo(players);
    final formation = FormationCatalog.fromTactic(
      fieldType: fieldType,
      goalkeepers: tactic.goalkeepers,
      defenders: tactic.defenders,
      midfielders: tactic.midfielders,
      strikers: tactic.strikers,
    );
    return (
      defenders: tactic.defenders,
      midfielders: tactic.midfielders,
      strikers: tactic.strikers,
      assignment: FormationAssigner.assign(players, formation),
    );
  }

  List<Player> team({required int keepers, required int outfield}) => [
        for (var i = 0; i < keepers; i++)
          _player('g$i', PlayerPosition.goalkeeper, 7.0),
        for (var i = 0; i < outfield; i++)
          _player('o$i', PlayerPosition.midfielder, 6.0 + i * 0.1),
      ];

  test('D1: um time de campo com 10 na linha nao perde ninguem', () {
    // O codigo antigo caia fora dos ifs (totalField == 10), ficava com 2/3/1
    // e devolvia 6 jogadores de linha. Quatro sumiam.
    final players = team(keepers: 1, outfield: 10);
    final result = reorganize(
      groupTactic: const TeamTactic(
        goalkeepers: 1, defenders: 4, midfielders: 4, strikers: 2),
      fieldType: FieldType.campo,
      players: players,
    );

    expect(result.defenders + result.midfielders + result.strikers, 10);

    final placed = result.assignment.bySlot.values.length;
    expect(
      placed + result.assignment.bench.length,
      players.length,
      reason: 'jogador sumiu entre o elenco e o campo',
    );
  });

  test('D2: a tatica do grupo manda, nao os numeros cravados', () {
    final players = team(keepers: 1, outfield: 10);

    final quatroTresTres = reorganize(
      groupTactic: const TeamTactic(
        goalkeepers: 1, defenders: 4, midfielders: 3, strikers: 3),
      fieldType: FieldType.campo,
      players: players,
    );
    final tresCincoDois = reorganize(
      groupTactic: const TeamTactic(
        goalkeepers: 1, defenders: 3, midfielders: 5, strikers: 2),
      fieldType: FieldType.campo,
      players: players,
    );

    expect(quatroTresTres.defenders, 4);
    expect(quatroTresTres.strikers, 3);
    expect(tresCincoDois.defenders, 3);
    expect(tresCincoDois.midfielders, 5);

    // Duas taticas diferentes tem que dar dois campos diferentes. O codigo
    // antigo devolvia 2/3/1 para as duas.
    expect(
      [quatroTresTres.defenders, quatroTresTres.midfielders],
      isNot([tresCincoDois.defenders, tresCincoDois.midfielders]),
    );
  });

  test('D4: reorganizar nao muta a posicao de nenhum Player', () {
    final players = team(keepers: 1, outfield: 10);
    final before = {for (final p in players) p.id: p.position};

    reorganize(
      groupTactic: const TeamTactic(
        goalkeepers: 1, defenders: 4, midfielders: 4, strikers: 2),
      fieldType: FieldType.campo,
      players: players,
    );

    for (final p in players) {
      expect(
        p.position,
        before[p.id],
        reason: '${p.nome} teve a posicao reescrita em silencio',
      );
    }
  });

  test('D5/D6: sem tatica no grupo, o padrao e o da modalidade', () {
    // 10 na linha, e nao 6: com 6 os dois padroes convergem de verdade
    // (4:4:2 reduzido a 6 da 2-3-1, que e o proprio society), entao 6 nao
    // distingue nada. Com 10 a diferenca aparece.
    final players = team(keepers: 1, outfield: 10);

    final society = reorganize(
      groupTactic: null,
      fieldType: FieldType.society,
      players: players,
    );
    final campo = reorganize(
      groupTactic: null,
      fieldType: FieldType.campo,
      players: players,
    );

    expect(society.defenders + society.midfielders + society.strikers, 10);
    expect(campo.defenders + campo.midfielders + campo.strikers, 10);

    expect(campo.defenders, 4, reason: 'campo devia abrir em 4-4-2');
    expect(campo.midfielders, 4);
    // Society 2-3-1 esticado para 10 e mais povoado no meio que o campo.
    expect(society.midfielders, greaterThan(campo.midfielders));
  });

  test('a modalidade so deixa de importar quando as taticas convergem', () {
    // Documenta o caso acima em vez de esconde-lo: com elenco pequeno as
    // duas taticas dao o mesmo campo, e isso esta certo.
    final players = team(keepers: 1, outfield: 6);

    final society =
        reorganize(groupTactic: null, fieldType: FieldType.society, players: players);
    final campo =
        reorganize(groupTactic: null, fieldType: FieldType.campo, players: players);

    expect(
      [campo.defenders, campo.midfielders, campo.strikers],
      [society.defenders, society.midfielders, society.strikers],
    );
  });

  test('todo tamanho de time fecha a conta em toda modalidade', () {
    for (final type in FieldType.values) {
      for (var outfield = 1; outfield <= 14; outfield++) {
        final players = team(keepers: 1, outfield: outfield);
        final r = reorganize(
          groupTactic: null,
          fieldType: type,
          players: players,
        );
        expect(
          r.defenders + r.midfielders + r.strikers,
          outfield,
          reason: '$type com $outfield na linha perdeu jogador',
        );
      }
    }
  });
}

Player _player(String id, PlayerPosition position, double nota) => Player(
      id: id,
      grupoId: 'g',
      nome: id,
      nota: nota,
      ehCapitao: false,
      urlFoto: null,
      position: position,
      reserva: false,
    );
