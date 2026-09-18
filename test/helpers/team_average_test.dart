import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/helpers/team_generator.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

Player _p(String id, double nota, PlayerPosition position) => Player(
  id: id,
  grupoId: 'g1',
  nome: id,
  nota: nota,
  ehCapitao: false,
  urlFoto: null,
  position: position,
  reserva: false,
);

void main() {
  group('Team.averageSkill', () {
    test('ignora goleiros no numerador E no denominador', () {
      // O bug anterior somava so os jogadores de linha (8.0 + 6.0 = 14.0) mas
      // dividia por players.length (3), devolvendo 4.67 em vez de 7.0.
      final team = Team(
        name: 'Time 1',
        players: [
          _p('gk', 2.0, PlayerPosition.goalkeeper),
          _p('a', 8.0, PlayerPosition.defender),
          _p('b', 6.0, PlayerPosition.striker),
        ],
      );

      expect(team.averageSkill, closeTo(7.0, 0.0001));
    });

    test('time sem goleiro calcula a media de todos', () {
      final team = Team(
        name: 'Time 1',
        players: [
          _p('a', 5.0, PlayerPosition.defender),
          _p('b', 7.0, PlayerPosition.midfielder),
        ],
      );

      expect(team.averageSkill, closeTo(6.0, 0.0001));
    });

    test('time so de goleiros usa a media deles, nao zero', () {
      final team = Team(
        name: 'Time 1',
        players: [
          _p('gk1', 6.0, PlayerPosition.goalkeeper),
          _p('gk2', 8.0, PlayerPosition.goalkeeper),
        ],
      );

      expect(team.averageSkill, closeTo(7.0, 0.0001));
    });

    test('time vazio e zero', () {
      expect(Team(name: 'Time 1', players: []).averageSkill, 0.0);
    });

    test('media do servidor vence o calculo local', () {
      final team = Team(
        name: 'Time 1',
        players: [_p('a', 8.0, PlayerPosition.defender)],
        averageSkill: 6.3,
      );

      expect(team.averageSkill, closeTo(6.3, 0.0001));
    });
  });

  group('Team.copyWith', () {
    test('renomear preserva a media do servidor', () {
      final team = Team(
        name: 'Time 1',
        players: [_p('a', 8.0, PlayerPosition.defender)],
        averageSkill: 6.3,
      );

      expect(team.copyWith(name: 'Time 2').averageSkill, closeTo(6.3, 0.0001));
    });

    test('trocar o elenco descarta a media do servidor e recalcula', () {
      final team = Team(
        name: 'Time 1',
        players: [_p('a', 8.0, PlayerPosition.defender)],
        averageSkill: 6.3,
      );

      final changed = team.copyWith(
        players: [
          _p('a', 8.0, PlayerPosition.defender),
          _p('b', 4.0, PlayerPosition.striker),
        ],
      );

      expect(changed.averageSkill, closeTo(6.0, 0.0001));
    });
  });

  group('PlayerPosition sem duplicatas de rotulo', () {
    test('nenhum caminho de UI expoe o enum cru', () {
      // O bug: '${player.position}' imprimia "PlayerPosition.striker".
      for (final position in PlayerPosition.values) {
        expect(position.toString(), contains('PlayerPosition.'));
      }
    });
  });
}
