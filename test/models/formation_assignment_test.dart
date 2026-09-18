import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/formation.dart';
import 'package:futdraw/models/formation/formation_assignment.dart';
import 'package:futdraw/models/formation/formation_catalog.dart';
import 'package:futdraw/models/player.dart';

int _seq = 0;

Player _player(PlayerPosition position, {double? nota}) {
  _seq++;
  return Player(
    id: 'p$_seq',
    grupoId: 'g1',
    nome: 'Jogador $_seq',
    nota: nota ?? (3 + (_seq % 7)).toDouble(),
    ehCapitao: false,
    urlFoto: null,
    position: position,
    reserva: false,
  );
}

List<Player> _squad({
  int goalkeepers = 0,
  int defenders = 0,
  int midfielders = 0,
  int strikers = 0,
}) => [
  for (var i = 0; i < goalkeepers; i++) _player(PlayerPosition.goalkeeper),
  for (var i = 0; i < defenders; i++) _player(PlayerPosition.defender),
  for (var i = 0; i < midfielders; i++) _player(PlayerPosition.midfielder),
  for (var i = 0; i < strikers; i++) _player(PlayerPosition.striker),
];

List<Player> _squadFor(Formation formation) => _squad(
  goalkeepers: formation.countOf(PlayerPosition.goalkeeper),
  defenders: formation.countOf(PlayerPosition.defender),
  midfielders: formation.countOf(PlayerPosition.midfielder),
  strikers: formation.countOf(PlayerPosition.striker),
);

/// Instantaneo profundo do estado dos jogadores, para provar que a atribuicao
/// nao muta ninguem.
List<String> _snapshot(List<Player> players) => players
    .map((p) => '${p.id}|${p.nome}|${p.nota}|${p.position}|${p.ehCapitao}')
    .toList();

void _assertInvariants(
  SlotAssignment result,
  List<Player> players,
  Formation formation,
  String label,
) {
  final placed = result.bySlot.values.toList();

  // (a) ninguem atribuido duas vezes
  final placedIds = placed.map((p) => p.id).toList();
  expect(
    placedIds.toSet().length,
    placedIds.length,
    reason: '$label: jogador atribuido a mais de um slot',
  );

  // (b) ninguem sumiu: todo jogador esta em campo ou no banco
  final accounted = {...placedIds, ...result.bench.map((p) => p.id)};
  expect(
    accounted,
    players.map((p) => p.id).toSet(),
    reason: '$label: algum jogador sumiu silenciosamente',
  );

  // (d) slot de goleiro nunca preenchido por jogador de linha
  for (final slot in formation.slots) {
    if (slot.role != PlayerPosition.goalkeeper) continue;
    final occupant = result.bySlot[slot.id];
    if (occupant != null) {
      expect(
        occupant.position,
        PlayerPosition.goalkeeper,
        reason: '$label: jogador de linha promovido a goleiro',
      );
    }
  }

  // Todo slot ou tem dono, ou esta declarado vazio.
  for (final slot in formation.slots) {
    final filled = result.bySlot.containsKey(slot.id);
    final empty = result.emptySlots.contains(slot.id);
    expect(
      filled != empty,
      isTrue,
      reason: '$label: slot ${slot.id} nem preenchido nem declarado vazio',
    );
  }
}

void main() {
  setUp(() => _seq = 0);

  group('matriz de atribuicao: toda modalidade x todo preset x desencaixes', () {
    for (final fieldType in [
      FieldType.quadra,
      FieldType.society,
      FieldType.campo,
    ]) {
      for (final formation in FormationCatalog.presetsFor(fieldType)) {
        final name = '${fieldType.name} ${formation.label}';

        test('$name: elenco exato preenche tudo, sem banco', () {
          final players = _squadFor(formation);
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
          expect(result.emptySlots, isEmpty);
          expect(result.bench, isEmpty);
          expect(result.outOfPositionPlayerIds, isEmpty);
          expect(result.isPerfectFit, isTrue);
        });

        test('$name: faltando um zagueiro, alguem cobre e fica marcado', () {
          final players = _squad(
            goalkeepers: formation.countOf(PlayerPosition.goalkeeper),
            defenders: formation.countOf(PlayerPosition.defender) - 1,
            midfielders: formation.countOf(PlayerPosition.midfielder) + 1,
            strikers: formation.countOf(PlayerPosition.striker),
          );
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
          if (formation.countOf(PlayerPosition.defender) > 0 &&
              formation.countOf(PlayerPosition.midfielder) > 0) {
            expect(
              result.outOfPositionPlayerIds,
              isNotEmpty,
              reason: '$name: cobertura nao foi sinalizada',
            );
          }
        });

        test('$name: dois meias a mais vao para o banco, nao somem', () {
          final players = _squad(
            goalkeepers: formation.countOf(PlayerPosition.goalkeeper),
            defenders: formation.countOf(PlayerPosition.defender),
            midfielders: formation.countOf(PlayerPosition.midfielder) + 2,
            strikers: formation.countOf(PlayerPosition.striker),
          );
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
          expect(result.bench.length, 2);
        });

        test('$name: sem goleiro, o slot fica fantasma em vez de mentir', () {
          final players = _squad(
            defenders: formation.countOf(PlayerPosition.defender),
            midfielders: formation.countOf(PlayerPosition.midfielder),
            strikers: formation.countOf(PlayerPosition.striker),
          );
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
          expect(
            result.emptySlots,
            contains('GK'),
            reason: '$name: slot de goleiro foi preenchido indevidamente',
          );
        });

        test('$name: dois goleiros, o segundo vai para o banco', () {
          final players = _squad(
            goalkeepers: formation.countOf(PlayerPosition.goalkeeper) + 1,
            defenders: formation.countOf(PlayerPosition.defender),
            midfielders: formation.countOf(PlayerPosition.midfielder),
            strikers: formation.countOf(PlayerPosition.striker),
          );
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
          expect(result.bench.length, 1);
          expect(result.bench.single.position, PlayerPosition.goalkeeper);
        });

        test('$name: elenco todo de meias distribui e sinaliza', () {
          final players = _squad(midfielders: formation.size);
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
        });

        test('$name: elenco vazio deixa tudo fantasma', () {
          final result = FormationAssigner.assign(const [], formation);

          expect(result.bySlot, isEmpty);
          expect(result.bench, isEmpty);
          expect(result.emptySlots.length, formation.size);
        });

        test('$name: 22 jogadores nao derrubam ninguem', () {
          final players = _squad(
            goalkeepers: 2,
            defenders: 8,
            midfielders: 8,
            strikers: 4,
          );
          final result = FormationAssigner.assign(players, formation);

          _assertInvariants(result, players, formation, name);
          expect(
            result.bySlot.length + result.bench.length,
            players.length,
          );
        });

        test('$name: nao muta nenhum Player', () {
          final players = _squadFor(formation);
          final before = _snapshot(players);

          FormationAssigner.assign(players, formation);

          expect(
            _snapshot(players),
            before,
            reason:
                '$name: a atribuicao escreveu em Player. Era exatamente o que '
                '_reorganizeTeamByTactic fazia, editando as instancias que a '
                'tela anterior ainda segurava.',
          );
        });

        test('$name: determinista em 100 execucoes', () {
          final players = _squadFor(formation);
          final first = FormationAssigner.assign(players, formation);
          final expected = {
            for (final entry in first.bySlot.entries)
              entry.key: entry.value.id,
          };

          for (var run = 0; run < 100; run++) {
            final result = FormationAssigner.assign(players, formation);
            final actual = {
              for (final entry in result.bySlot.entries)
                entry.key: entry.value.id,
            };
            expect(actual, expected, reason: '$name: execucao $run divergiu');
          }
        });
      }
    }
  });

  group('regras de cobertura', () {
    test('meia que desce para a zaga e o de menor nota do setor', () {
      final formation = FormationCatalog.presetsFor(
        FieldType.campo,
      ).firstWhere((f) => f.id == 'campo_442');

      final players = [
        _player(PlayerPosition.goalkeeper, nota: 5),
        for (var i = 0; i < 3; i++) _player(PlayerPosition.defender, nota: 7),
        _player(PlayerPosition.midfielder, nota: 9),
        _player(PlayerPosition.midfielder, nota: 8),
        _player(PlayerPosition.midfielder, nota: 7),
        _player(PlayerPosition.midfielder, nota: 6),
        _player(PlayerPosition.midfielder, nota: 2),
        _player(PlayerPosition.striker, nota: 8),
        _player(PlayerPosition.striker, nota: 7),
      ];

      final result = FormationAssigner.assign(players, formation);
      final coverId = result.outOfPositionPlayerIds.single;
      final cover = players.firstWhere((p) => p.id == coverId);

      expect(cover.nota, 2, reason: 'deveria descer o meia de menor nota');
    });

    test('meia que sobe para o ataque e o de maior nota do setor', () {
      final formation = FormationCatalog.presetsFor(
        FieldType.campo,
      ).firstWhere((f) => f.id == 'campo_442');

      final players = [
        _player(PlayerPosition.goalkeeper, nota: 5),
        for (var i = 0; i < 4; i++) _player(PlayerPosition.defender, nota: 7),
        _player(PlayerPosition.midfielder, nota: 9),
        _player(PlayerPosition.midfielder, nota: 8),
        _player(PlayerPosition.midfielder, nota: 7),
        _player(PlayerPosition.midfielder, nota: 6),
        _player(PlayerPosition.midfielder, nota: 3),
        _player(PlayerPosition.striker, nota: 8),
      ];

      final result = FormationAssigner.assign(players, formation);
      final coverId = result.outOfPositionPlayerIds.single;
      final cover = players.firstWhere((p) => p.id == coverId);

      expect(cover.nota, 9, reason: 'deveria subir o meia de maior nota');
    });

    test('o jogador de maior nota da linha fica no slot mais central', () {
      final formation = FormationCatalog.presetsFor(
        FieldType.campo,
      ).firstWhere((f) => f.id == 'campo_442');

      final players = [
        _player(PlayerPosition.goalkeeper, nota: 5),
        _player(PlayerPosition.defender, nota: 4),
        _player(PlayerPosition.defender, nota: 9),
        _player(PlayerPosition.defender, nota: 5),
        _player(PlayerPosition.defender, nota: 6),
        for (var i = 0; i < 4; i++) _player(PlayerPosition.midfielder, nota: 7),
        for (var i = 0; i < 2; i++) _player(PlayerPosition.striker, nota: 7),
      ];

      final result = FormationAssigner.assign(players, formation);
      final defenderSlots = formation.slots
          .where((s) => s.role == PlayerPosition.defender)
          .toList()
        ..sort((a, b) => a.centrality.compareTo(b.centrality));

      expect(result.bySlot[defenderSlots.first.id]!.nota, 9);
    });
  });

  group('catalogo de formacoes', () {
    test('a tatica do grupo encontra o preset desenhado a mao', () {
      final formation = FormationCatalog.fromTactic(
        fieldType: FieldType.campo,
        goalkeepers: 1,
        defenders: 4,
        midfielders: 4,
        strikers: 2,
      );

      expect(formation.id, 'campo_442');
      expect(formation.label, '4-4-2');
    });

    test('tatica sem preset equivalente e sintetizada com rotulo correto', () {
      final formation = FormationCatalog.fromTactic(
        fieldType: FieldType.campo,
        goalkeepers: 1,
        defenders: 4,
        midfielders: 1,
        strikers: 5,
      );

      expect(formation.label, '4-1-5');
      expect(formation.size, 11);
    });

    test('todo preset tem exatamente um goleiro e ids unicos', () {
      for (final fieldType in FieldType.values) {
        for (final formation in FormationCatalog.presetsFor(fieldType)) {
          expect(
            formation.countOf(PlayerPosition.goalkeeper),
            1,
            reason: formation.id,
          );
          final ids = formation.slots.map((s) => s.id).toList();
          expect(ids.toSet().length, ids.length, reason: formation.id);
        }
      }
    });

    test('todo slot fica dentro da caixa normalizada', () {
      for (final fieldType in FieldType.values) {
        for (final formation in FormationCatalog.presetsFor(fieldType)) {
          for (final slot in formation.slots) {
            expect(slot.position.dx, inInclusiveRange(0.0, 1.0));
            expect(slot.position.dy, inInclusiveRange(0.0, 1.0));
          }
        }
      }
    });

    test('o tamanho do preset bate com os jogadores por time da modalidade', () {
      const expected = {
        FieldType.quadra: 5,
        FieldType.society: 7,
        FieldType.campo: 11,
      };
      expected.forEach((fieldType, size) {
        for (final formation in FormationCatalog.presetsFor(fieldType)) {
          expect(formation.size, size, reason: formation.id);
        }
      });
    });

    test('linhas sao numeradas do fundo para a frente', () {
      for (final fieldType in FieldType.values) {
        for (final formation in FormationCatalog.presetsFor(fieldType)) {
          for (final row in formation.rows) {
            final slots = formation.slotsInRow(row);
            for (final slot in slots) {
              if (row == 0) {
                expect(
                  slot.role,
                  PlayerPosition.goalkeeper,
                  reason: '${formation.id}: linha 0 nao e o goleiro',
                );
              }
            }
          }
        }
      }
    });
  });

  group('formacao personalizada', () {
    test('toCustom congela as posicoes atuais como override', () {
      final base = FormationCatalog.defaultFor(FieldType.campo);
      final custom = base.toCustom();

      expect(custom.isCustom, isTrue);
      expect(custom.overrides.length, base.size);
      for (final slot in base.slots) {
        expect(custom.positionOf(slot), slot.position);
      }
    });

    test('mover um slot nao afeta os outros', () {
      final base = FormationCatalog.defaultFor(FieldType.campo).toCustom();
      final moved = base.withOverride('A1', const Offset(0.1, 0.1));

      expect(moved.overrides['A1'], const Offset(0.1, 0.1));
      final gk = moved.slots.firstWhere((s) => s.id == 'GK');
      expect(moved.positionOf(gk), base.positionOf(gk));
    });

    test('restaurar volta ao preset', () {
      final base = FormationCatalog.defaultFor(FieldType.campo);
      final restored = base.toCustom()
          .withOverride('A1', const Offset(0.1, 0.1))
          .clearOverrides();

      expect(restored.isCustom, isFalse);
      expect(restored.overrides, isEmpty);
      final a1 = restored.slots.firstWhere((s) => s.id == 'A1');
      expect(restored.positionOf(a1), a1.position);
    });
  });
}
