import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/components/widgets/group_actions_header.dart';
import 'package:futdraw/components/widgets/player.list.dart';
import 'package:futdraw/components/widgets/player_row.dart';
import 'package:futdraw/components/widgets/position_chip.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/data/remote/player_remote_datasource.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/position_palette.dart';
import 'package:futdraw/views/player.list.view.dart';
import 'package:provider/provider.dart';

Player _player(
  String nome, {
  PlayerPosition position = PlayerPosition.midfielder,
  double nota = 7,
  bool reserva = false,
  bool capitao = false,
}) => Player(
  id: nome,
  grupoId: 'g1',
  nome: nome,
  nota: nota,
  ehCapitao: capitao,
  urlFoto: null,
  position: position,
  reserva: reserva,
);

class _FakeDataSource extends PlayerRemoteDataSource {
  _FakeDataSource() : super(Dio());
}

class _FakeRepository extends PlayerRepository {
  _FakeRepository() : super(_FakeDataSource());
}

/// Controlador que nao fala com a rede. A tela so precisa de `players` e de um
/// `getAllByGroupId` que nao explode.
class _FakeController extends PlayerController {
  _FakeController(List<Player> seed) : super(_FakeRepository()) {
    players = seed;
  }

  @override
  Future<List<Player>> getAllByGroupId(
    BuildContext context,
    String groupId,
  ) async => players;
}

Widget _wrap(Widget child, {bool isDark = true}) => MaterialApp(
  theme: AppTheme.build(ThemeColor.violeta, isDark),
  home: child,
);

Widget _screen(List<Player> players, {String nome = 'Teste grupo'}) {
  final group = Group(id: 'g1', nome: nome);

  return ChangeNotifierProvider<PlayerController>.value(
    value: _FakeController(players),
    child: _wrap(PlayerListScreen(group: group)),
  );
}

void main() {
  group('ordem do elenco', () {
    test('agrupa por setor, do gol ao ataque, e ordena por nome dentro dele', () {
      final lista = [
        _player('Zeca', position: PlayerPosition.striker),
        _player('Ana', position: PlayerPosition.goalkeeper),
        _player('Bruno', position: PlayerPosition.striker),
        _player('Carlos', position: PlayerPosition.defender),
        _player('Duda', position: PlayerPosition.midfielder),
      ]..sort(comparePlayersForRoster);

      expect(
        lista.map((p) => p.nome).toList(),
        ['Ana', 'Carlos', 'Duda', 'Bruno', 'Zeca'],
      );
    });

    test('e uma ordem total: o resultado nao depende da entrada', () {
      final base = [
        _player('Ana', position: PlayerPosition.goalkeeper),
        _player('Bruno', position: PlayerPosition.striker),
        _player('Carlos', position: PlayerPosition.defender),
        _player('Duda', position: PlayerPosition.midfielder),
      ];

      final aa = List.of(base)..sort(comparePlayersForRoster);
      final bb = (List.of(base)..shuffle())..sort(comparePlayersForRoster);

      expect(aa.map((p) => p.nome), bb.map((p) => p.nome));
    });
  });

  group('PositionChip', () {
    testWidgets('cada posicao tem nome, icone e cor propria', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Scaffold(
            body: Column(
              children: [
                PositionChip(position: PlayerPosition.goalkeeper),
                PositionChip(position: PlayerPosition.defender),
                PositionChip(position: PlayerPosition.midfielder),
                PositionChip(position: PlayerPosition.striker),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Goleiro'), findsOneWidget);
      expect(find.text('Defesa'), findsOneWidget);
      expect(find.text('Meio'), findsOneWidget);
      expect(find.text('Ataque'), findsOneWidget);

      final palette = const PositionPalette.dark();
      final cores = <Color>{};
      for (final position in PlayerPosition.values) {
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byWidget(
              tester.widgetList<PositionChip>(find.byType(PositionChip)).firstWhere(
                (chip) => chip.position == position,
              ),
            ),
            matching: find.byType(Icon),
          ),
        );
        expect(icon.color, palette.inkFor(position));
        cores.add(icon.color!);
      }

      // Quatro cores, nao uma repetida quatro vezes: era exatamente esse o
      // defeito do card antigo.
      expect(cores.length, 4);
    });
  });

  group('PlayerRow', () {
    testWidgets('mostra nome, posicao e nota', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: PlayerRow(
              player: _player(
                'Bisteca',
                position: PlayerPosition.goalkeeper,
                nota: 6.5,
              ),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Bisteca'), findsOneWidget);
      expect(find.text('Goleiro'), findsOneWidget);
      expect(find.text('6.5'), findsOneWidget);
    });

    testWidgets('Substituir so aparece quando ha para onde substituir', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: PlayerRow(
              player: _player('Neto'),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
      expect(find.text('Substituir'), findsNothing);
    });

    testWidgets('com onSwap, o menu oferece Substituir', (tester) async {
      Player? trocado;

      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: PlayerRow(
              player: _player('Walli'),
              onEdit: () {},
              onDelete: () {},
              onSwap: (p) => trocado = p,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Substituir'));
      await tester.pumpAndSettle();

      expect(trocado?.nome, 'Walli');
    });
  });

  group('GroupActionsHeader', () {
    testWidgets('as tres acoes tem nome e disparam', (tester) async {
      final chamadas = <String>[];

      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: GroupActionsHeader(
              titulares: 12,
              reservas: 4,
              onSortear: () => chamadas.add('sortear'),
              onPartidas: () => chamadas.add('partidas'),
              onRanking: () => chamadas.add('ranking'),
            ),
          ),
        ),
      );

      expect(find.text('12 titulares · 4 reservas'), findsOneWidget);

      for (final label in ['Sortear', 'Partidas', 'Ranking']) {
        expect(find.text(label), findsOneWidget);
        await tester.tap(find.text(label));
      }
      await tester.pump();

      expect(chamadas, ['sortear', 'partidas', 'ranking']);
    });

    testWidgets('empilha em vez de truncar num aparelho estreito', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: GroupActionsHeader(
              titulares: 1,
              reservas: 1,
              onSortear: () {},
              onPartidas: () {},
              onRanking: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Partidas'), findsOneWidget);
      expect(find.text('1 titular · 1 reserva'), findsOneWidget);
    });
  });

  group('PlayerListScreen', () {
    testWidgets('mostra o nome do grupo inteiro, sem cortar', (tester) async {
      await tester.pumpWidget(
        _screen([
          _player('Bisteca', position: PlayerPosition.goalkeeper),
        ], nome: 'Teste grupo do Lucas'),
      );
      await tester.pumpAndSettle();

      // SliverAppBar.large mantem duas copias do titulo (expandida e
      // colapsada); o que importa e que nenhuma delas trunca em uma linha.
      final titulos = tester.widgetList<Text>(
        find.text('Teste grupo do Lucas'),
      );
      expect(titulos, isNotEmpty);
      for (final titulo in titulos) {
        expect(titulo.maxLines, 2);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('as duas abas contam o elenco', (tester) async {
      await tester.pumpWidget(
        _screen([
          _player('Bisteca', position: PlayerPosition.goalkeeper),
          _player('Walli', position: PlayerPosition.striker),
          _player('Neto', reserva: true),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Titulares (2)'), findsOneWidget);
      expect(find.text('Reservas (1)'), findsOneWidget);
    });

    testWidgets('as acoes do grupo saem da AppBar e ganham nome', (
      tester,
    ) async {
      await tester.pumpWidget(_screen([_player('Bisteca')]));
      await tester.pumpAndSettle();

      expect(find.text('Sortear'), findsOneWidget);
      expect(find.text('Partidas'), findsOneWidget);
      expect(find.text('Ranking'), findsOneWidget);

      // A barra fica com duas acoes de icone, nao cinco.
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month), findsNothing);
      expect(find.byIcon(Icons.leaderboard), findsNothing);
    });

    testWidgets('elenco vazio oferece o proximo passo', (tester) async {
      await tester.pumpWidget(_screen([]));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum titular ainda'), findsOneWidget);
      expect(find.text('Adicionar jogador'), findsWidgets);
    });

    for (final escala in [1.0, 1.3, 2.0]) {
      testWidgets(
        'nao estoura num aparelho pequeno a ${(escala * 100).round()}% de texto',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(escala)),
              child: _screen([
                _player('Joao Marcos de Alcantara Sobrinho', capitao: true),
                _player('Bisteca', position: PlayerPosition.goalkeeper),
                _player('Walli', position: PlayerPosition.striker),
              ], nome: 'Grupo da quinta com nome bem comprido'),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
