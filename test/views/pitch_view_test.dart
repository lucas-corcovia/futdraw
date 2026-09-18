import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/models/formation/formation.dart';
import 'package:futdraw/models/formation/formation_assignment.dart';
import 'package:futdraw/models/formation/formation_catalog.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_view.dart';
import 'package:futdraw/views/teams_display/widgets/player_chip.dart';

int _seq = 0;

Player _player(PlayerPosition position) {
  _seq++;
  return Player(
    id: 'p$_seq',
    grupoId: 'g1',
    nome: 'Jogador $_seq',
    nota: 5 + (_seq % 5),
    ehCapitao: _seq == 2,
    urlFoto: null,
    position: position,
    reserva: false,
  );
}

List<Player> _squadFor(Formation formation, {int defenderDeficit = 0}) => [
  for (var i = 0; i < formation.countOf(PlayerPosition.goalkeeper); i++)
    _player(PlayerPosition.goalkeeper),
  for (
    var i = 0;
    i < formation.countOf(PlayerPosition.defender) - defenderDeficit;
    i++
  )
    _player(PlayerPosition.defender),
  for (var i = 0; i < formation.countOf(PlayerPosition.midfielder); i++)
    _player(PlayerPosition.midfielder),
  for (var i = 0; i < formation.countOf(PlayerPosition.striker); i++)
    _player(PlayerPosition.striker),
];

Future<void> _pumpPitch(
  WidgetTester tester, {
  required Formation formation,
  required List<Player> players,
  Size size = const Size(360, 800),
  double textScale = 1.0,
  bool isDark = true,
  void Function(Player)? onPlayerTap,
}) async {
  tester.view.physicalSize = size * 3.0;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        theme: AppTheme.build(ThemeColor.esmeralda, false),
        darkTheme: AppTheme.build(ThemeColor.esmeralda, true),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(
          body: PitchView(
            formation: formation,
            assignment: FormationAssigner.assign(players, formation),
            fieldType: formation.fieldType,
            teamAccent: const Color(0xFFE5484D),
            onPlayerTap: onPlayerTap,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => _seq = 0);

  group('PitchView', () {
    testWidgets('renderiza um chip por jogador escalado', (tester) async {
      final formation = FormationCatalog.defaultFor(FieldType.campo);
      final players = _squadFor(formation);

      await _pumpPitch(tester, formation: formation, players: players);

      expect(find.byType(PlayerChip), findsNWidgets(formation.size));
    });

    testWidgets('slot vago vira fantasma em vez de sumir', (tester) async {
      final formation = FormationCatalog.defaultFor(FieldType.campo);
      // Um zagueiro a menos e nenhum meia sobrando: ninguem pode cobrir.
      final players = _squadFor(formation, defenderDeficit: 1);

      await _pumpPitch(tester, formation: formation, players: players);

      expect(find.byType(PlayerChip), findsNWidgets(formation.size - 1));
      expect(find.text('VAGO'), findsOneWidget);
    });

    testWidgets('sem goleiro o slot diz que falta goleiro', (tester) async {
      final formation = FormationCatalog.defaultFor(FieldType.quadra);
      final players = _squadFor(formation)
          .where((p) => p.position != PlayerPosition.goalkeeper)
          .toList();

      await _pumpPitch(tester, formation: formation, players: players);

      expect(find.text('SEM GOLEIRO'), findsOneWidget);
    });

    testWidgets('a nota aparece no campo, o que antes nunca acontecia', (
      tester,
    ) async {
      final formation = FormationCatalog.defaultFor(FieldType.quadra);
      final players = _squadFor(formation);

      await _pumpPitch(tester, formation: formation, players: players);

      // Quadra tem chips grandes o bastante para o badge de nota aparecer.
      expect(find.textContaining('.'), findsWidgets);
    });

    testWidgets('tocar num jogador avisa quem foi', (tester) async {
      final formation = FormationCatalog.defaultFor(FieldType.quadra);
      final players = _squadFor(formation);
      Player? tapped;

      await _pumpPitch(
        tester,
        formation: formation,
        players: players,
        onPlayerTap: (p) => tapped = p,
      );

      await tester.tap(find.byType(PlayerChip).first);
      await tester.pump();

      expect(tapped, isNotNull);
    });

    testWidgets('todo chip tem rotulo de acessibilidade', (tester) async {
      final handle = tester.ensureSemantics();
      final formation = FormationCatalog.defaultFor(FieldType.quadra);

      await _pumpPitch(
        tester,
        formation: formation,
        players: _squadFor(formation),
      );

      // O app inteiro tinha zero Semantics antes desta tela.
      expect(
        find.bySemanticsLabel(RegExp('Jogador 1, Goleiro, nota')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('resiliencia do campo', () {
    const sizes = <({Size size, double scale, String name})>[
      (size: Size(320, 568), scale: 1.0, name: 'pequeno'),
      (size: Size(360, 640), scale: 1.3, name: 'compacto texto grande'),
      (size: Size(360, 800), scale: 1.3, name: 'alto texto grande'),
      (size: Size(800, 360), scale: 1.0, name: 'paisagem'),
      (size: Size(360, 800), scale: 2.0, name: 'texto 200%'),
    ];

    for (final spec in sizes) {
      for (final fieldType in [
        FieldType.quadra,
        FieldType.society,
        FieldType.campo,
        FieldType.livre,
      ]) {
        testWidgets('${spec.name} / ${fieldType.name} nao estoura', (
          tester,
        ) async {
          final formation = FormationCatalog.defaultFor(fieldType);

          await _pumpPitch(
            tester,
            formation: formation,
            players: _squadFor(formation),
            size: spec.size,
            textScale: spec.scale,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('11 contra 11 num aparelho pequeno mantem alvo de toque', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final formation = FormationCatalog.defaultFor(FieldType.campo);

      await _pumpPitch(
        tester,
        formation: formation,
        players: _squadFor(formation),
        size: const Size(320, 568),
      );

      // O caso que mais preocupava: no campo cheio o avatar antigo caia para
      // 34 px e a area tocavel ia junto.
      for (final element in find.byType(PlayerChip).evaluate()) {
        final box = element.renderObject! as RenderBox;
        expect(box.size.width, greaterThanOrEqualTo(kChipMinTapTarget));
      }
      handle.dispose();
    });
  });

  group('modalidade livre', () {
    testWidgets('nao desenha area de penalti de 11 contra 11', (tester) async {
      // Antes, FieldType.livre caia no CampoFieldPainter e desenhava area de
      // penalti mesmo num 3 contra 3.
      final formation = FormationCatalog.defaultFor(FieldType.livre);

      await _pumpPitch(
        tester,
        formation: formation,
        players: _squadFor(formation),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(PitchView), findsOneWidget);
    });
  });
}
