import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/formation.dart';
import 'package:futdraw/models/formation/formation_assignment.dart';
import 'package:futdraw/models/formation/formation_catalog.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/views/teams_display/widgets/field_controls.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_view.dart';
import 'package:futdraw/views/teams_display/widgets/player_chip.dart';

/// O contrato do campo destravado: **um gesto, um significado**. Travado
/// arrasta para trocar; destravado arrasta para mover. Estes testes existem
/// para impedir que os dois voltem a valer ao mesmo tempo, que e o caso em que
/// soltar um chip perto de outro fica ambiguo.
void main() {
  Widget host(Widget child, {Size size = const Size(360, 560)}) => MaterialApp(
        theme: AppTheme.build(ThemeColor.violeta, true),
        home: Scaffold(
          body: Center(
            child: SizedBox(width: size.width, height: size.height, child: child),
          ),
        ),
      );

  final formation = FormationCatalog.fromTactic(
    fieldType: FieldType.campo,
    goalkeepers: 1,
    defenders: 4,
    midfielders: 4,
    strikers: 2,
  );

  final squad = <Player>[
    _player('1', 'Cassio', PlayerPosition.goalkeeper),
    for (var i = 0; i < 4; i++)
      _player('d$i', 'Zagueiro $i', PlayerPosition.defender),
    for (var i = 0; i < 4; i++)
      _player('m$i', 'Meia $i', PlayerPosition.midfielder),
    for (var i = 0; i < 2; i++)
      _player('a$i', 'Atacante $i', PlayerPosition.striker),
  ];

  Widget pitch({
    required bool free,
    void Function(String slotId, Offset normalized)? onSlotMoved,
    void Function(Player a, Player b)? onSwap,
    Formation? withFormation,
  }) {
    final f = withFormation ?? formation;
    return PitchView(
      formation: f,
      assignment: FormationAssigner.assign(squad, f),
      fieldType: FieldType.campo,
      teamAccent: const Color(0xFFE5484D),
      freePositioning: free,
      onSlotMoved: onSlotMoved,
      onPlayersSwapped: onSwap,
    );
  }

  group('campo destravado', () {
    testWidgets('arrastar um chip devolve a posicao normalizada do slot',
        (tester) async {
      String? movedSlot;
      Offset? movedTo;

      await tester.pumpWidget(host(pitch(
        free: true,
        onSlotMoved: (slotId, normalized) {
          movedSlot = slotId;
          movedTo = normalized;
        },
      )));

      final chip = find.byType(PlayerChip).first;
      final before = tester.getCenter(chip);

      await tester.drag(chip, const Offset(40, -60));
      await tester.pumpAndSettle();

      expect(movedSlot, isNotNull, reason: 'o arrasto nao reportou slot');
      expect(movedTo, isNotNull);

      // Normalizado dentro da caixa do gramado, sempre.
      expect(movedTo!.dx, inInclusiveRange(0.0, 1.0));
      expect(movedTo!.dy, inInclusiveRange(0.0, 1.0));

      // O chip andou para a direita e para cima, e e isso que a coordenada
      // precisa refletir -- nao o centro do slot original.
      final after = tester.getCenter(find.byType(PlayerChip).first);
      expect(after.dx, greaterThan(before.dx));
      expect(after.dy, lessThan(before.dy));
    });

    testWidgets('a posicao movida sobrevive no override da formacao',
        (tester) async {
      var current = formation;

      await tester.pumpWidget(host(pitch(
        free: true,
        onSlotMoved: (slotId, normalized) {
          current = current.withOverride(slotId, normalized);
        },
      )));

      await tester.drag(find.byType(PlayerChip).first, const Offset(30, 30));
      await tester.pumpAndSettle();

      expect(current.overrides, isNotEmpty);
      expect(current.isCustom, isTrue);

      // Redesenhar com a formacao nova mantem o chip no lugar novo: e isso
      // que faz a posicao sobreviver a troca de aba e entrar no PNG.
      await tester.pumpWidget(host(pitch(free: true, withFormation: current)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrastar para fora do campo gruda na borda, nao escapa',
        (tester) async {
      Offset? movedTo;

      await tester.pumpWidget(host(pitch(
        free: true,
        onSlotMoved: (_, normalized) => movedTo = normalized,
      )));

      await tester.drag(find.byType(PlayerChip).first, const Offset(-4000, -4000));
      await tester.pumpAndSettle();

      expect(movedTo, isNotNull);
      expect(movedTo!.dx, inInclusiveRange(0.0, 1.0));
      expect(movedTo!.dy, inInclusiveRange(0.0, 1.0));
    });

    testWidgets('destravado nao troca jogador: o gesto e so de mover',
        (tester) async {
      var swaps = 0;

      await tester.pumpWidget(host(pitch(
        free: true,
        onSlotMoved: (_, __) {},
        onSwap: (_, __) => swaps++,
      )));

      // Arrasta um chip por cima de outro. Travado isso trocaria.
      await tester.drag(find.byType(PlayerChip).first, const Offset(0, 80));
      await tester.pumpAndSettle();

      expect(swaps, 0);
    });
  });

  group('campo travado', () {
    testWidgets('arrastar nao reposiciona nada', (tester) async {
      var moves = 0;

      await tester.pumpWidget(host(pitch(
        free: false,
        onSlotMoved: (_, __) => moves++,
      )));

      final before = tester.getCenter(find.byType(PlayerChip).first);
      await tester.drag(find.byType(PlayerChip).first, const Offset(50, 50));
      await tester.pumpAndSettle();

      expect(moves, 0);
      expect(tester.getCenter(find.byType(PlayerChip).first), before);
    });
  });

  group('FieldControls', () {
    testWidgets('o cadeado diz o estado, nunca so o glifo', (tester) async {
      await tester.pumpWidget(host(
        FieldControls(
          freePositioning: false,
          hasOverrides: false,
          onToggleLock: () {},
          onReset: () {},
        ),
        size: const Size(360, 200),
      ));

      expect(find.text('Travado'), findsOneWidget);
      expect(
        find.text('Arraste jogadores da mesma posição para trocar'),
        findsOneWidget,
      );
    });

    testWidgets('destravado troca rotulo e dica junto', (tester) async {
      await tester.pumpWidget(host(
        FieldControls(
          freePositioning: true,
          hasOverrides: false,
          onToggleLock: () {},
          onReset: () {},
        ),
        size: const Size(360, 200),
      ));

      expect(find.text('Livre'), findsOneWidget);
      expect(find.text('Arraste para posicionar livremente'), findsOneWidget);
    });

    testWidgets('Restaurar so aparece quando ha posicao movida', (tester) async {
      await tester.pumpWidget(host(
        FieldControls(
          freePositioning: true,
          hasOverrides: false,
          onToggleLock: () {},
          onReset: () {},
        ),
        size: const Size(360, 200),
      ));
      expect(find.text('Restaurar'), findsNothing);

      await tester.pumpWidget(host(
        FieldControls(
          freePositioning: true,
          hasOverrides: true,
          onToggleLock: () {},
          onReset: () {},
        ),
        size: const Size(360, 200),
      ));
      expect(find.text('Restaurar'), findsOneWidget);
    });

    testWidgets('os botoes tem 48 dp de alvo', (tester) async {
      await tester.pumpWidget(host(
        FieldControls(
          freePositioning: true,
          hasOverrides: true,
          onToggleLock: () {},
          onReset: () {},
        ),
        size: const Size(360, 200),
      ));

      for (final label in ['Livre', 'Restaurar']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(InkWell),
        );
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('o toque no cadeado dispara', (tester) async {
      var toggles = 0;

      await tester.pumpWidget(host(
        FieldControls(
          freePositioning: false,
          hasOverrides: false,
          onToggleLock: () => toggles++,
          onReset: () {},
        ),
        size: const Size(360, 200),
      ));

      await tester.tap(find.text('Travado'));
      await tester.pumpAndSettle();

      expect(toggles, 1);
    });
  });
}

Player _player(String id, String nome, PlayerPosition position) => Player(
      id: id,
      grupoId: 'g',
      nome: nome,
      nota: 7,
      ehCapitao: false,
      urlFoto: null,
      position: position,
      reserva: false,
    );
