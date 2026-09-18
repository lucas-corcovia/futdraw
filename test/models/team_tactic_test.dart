import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/team_tactic.dart';
import 'package:futdraw/models/player.dart';

/// A regra que estes testes existem para travar: **a tatica e proporcao, nao
/// teto.** O codigo anterior (`_reorganizeTeamByTactic`) cortava o elenco com
/// `.take()` em cima de contagens cravadas, e um time de 11 voltava com 7 --
/// os outros 4 sumiam da lista, do campo, da imagem compartilhada e do
/// sorteio salvo, sem aviso nenhum.
void main() {
  List<Player> squad({required int keepers, required int outfield}) => [
        for (var i = 0; i < keepers; i++)
          _player('g$i', PlayerPosition.goalkeeper),
        for (var i = 0; i < outfield; i++)
          _player('o$i', PlayerPosition.midfielder),
      ];

  group('scaledTo nao perde jogador', () {
    const campo = TeamTactic(
      goalkeepers: 1,
      defenders: 4,
      midfielders: 4,
      strikers: 2,
    );

    test('todo tamanho de elenco de 1 a 30 fecha a conta', () {
      for (var keepers = 0; keepers <= 2; keepers++) {
        for (var outfield = 0; outfield <= 30; outfield++) {
          final scaled = campo.scaledTo(
            squad(keepers: keepers, outfield: outfield),
          );

          expect(
            scaled.outfield,
            outfield,
            reason: 'tatica 4-4-2 com $outfield na linha perdeu ou inventou '
                'jogador: virou ${scaled.label}',
          );
          expect(scaled.goalkeepers, keepers);
          expect(scaled.total, keepers + outfield);
        }
      }
    });

    test('o elenco exato da tatica devolve a propria tatica', () {
      final scaled = campo.scaledTo(squad(keepers: 1, outfield: 10));

      expect(scaled.defenders, 4);
      expect(scaled.midfielders, 4);
      expect(scaled.strikers, 2);
      expect(scaled.label, '4-4-2');
    });

    test('o caso que o codigo antigo apagava: 12 na linha viram 12', () {
      // 4-4-2 com 12 na linha. O `.take(2)/.take(3)/.take(1)` antigo
      // devolvia 6 e descartava 6 jogadores.
      final scaled = campo.scaledTo(squad(keepers: 1, outfield: 12));

      expect(scaled.outfield, 12);
      expect(scaled.defenders, greaterThanOrEqualTo(4));
      expect(scaled.strikers, greaterThanOrEqualTo(2));
    });

    test('elenco menor que a tatica encolhe em vez de criar slot vazio', () {
      final scaled = campo.scaledTo(squad(keepers: 1, outfield: 5));

      expect(scaled.outfield, 5);
      expect(scaled.defenders, greaterThan(0));
      expect(scaled.midfielders, greaterThan(0));
    });

    test('a sobra do arredondamento vai para o meio-campo', () {
      // 1-2-3-1 com 7 na linha: 2.33 / 3.5 / 1.17 -> 2/3/1 e sobra 1.
      const society = TeamTactic(
        goalkeepers: 1,
        defenders: 2,
        midfielders: 3,
        strikers: 1,
      );
      final scaled = society.scaledTo(squad(keepers: 1, outfield: 7));

      expect(scaled.outfield, 7);
      expect(scaled.midfielders, 4);
    });

    test('time so de goleiros nao quebra', () {
      final scaled = campo.scaledTo(squad(keepers: 3, outfield: 0));

      expect(scaled.goalkeepers, 3);
      expect(scaled.outfield, 0);
    });
  });

  group('fromGroup', () {
    test('tatica gravada e aceita', () {
      final tactic = TeamTactic.fromGroup(
        goalkeepers: 1,
        defenders: 4,
        midfielders: 3,
        strikers: 3,
      );

      expect(tactic, isNotNull);
      expect(tactic!.label, '4-3-3');
    });

    test('os zeros que add.group grava para campo livre viram nulo', () {
      // FieldType.livre grava 0-0-0-0; usar isso daria um time sem linha.
      final tactic = TeamTactic.fromGroup(
        goalkeepers: 0,
        defenders: 0,
        midfielders: 0,
        strikers: 0,
      );

      expect(tactic, isNull);
    });

    test('grupo sem tatica gravada vira nulo', () {
      final tactic = TeamTactic.fromGroup(
        goalkeepers: null,
        defenders: null,
        midfielders: null,
        strikers: null,
      );

      expect(tactic, isNull);
    });
  });

  group('defaultFor', () {
    test('cada modalidade tem linha, e a soma bate com o padrao do grupo', () {
      // Os mesmos numeros que `_defaultTatica` oferece em add.group.dart.
      expect(TeamTactic.defaultFor(FieldType.campo).label, '4-4-2');
      expect(TeamTactic.defaultFor(FieldType.society).label, '2-3-1');
      expect(TeamTactic.defaultFor(FieldType.quadra).label, '1-2-1');

      for (final type in FieldType.values) {
        expect(
          TeamTactic.defaultFor(type).outfield,
          greaterThan(0),
          reason: '$type sem jogador de linha',
        );
      }
    });
  });
}

Player _player(String id, PlayerPosition position) => Player(
      id: id,
      grupoId: 'g',
      nome: id,
      nota: 7,
      ehCapitao: false,
      urlFoto: null,
      position: position,
      reserva: false,
    );
