// Banco de prova da cena do campo. Nao entra no app: existe para olhar a
// turfa em aparelho de verdade sem precisar de API, login nem sorteio.
//
//   flutter run -t tool/pitch_preview.dart
//
// Mostra o mesmo PitchView da tela de times, com um botao para alternar entre
// o shader e o fallback em CustomPainter -- que e a comparacao que importa.
import 'package:flutter/material.dart';
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

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatefulWidget {
  const _PreviewApp();

  @override
  State<_PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<_PreviewApp> {
  bool _shader = true;
  bool _dark = true;
  bool _free = false;
  Formation? _custom;

  @override
  Widget build(BuildContext context) {
    final formation = _custom ??
        FormationCatalog.fromTactic(
          fieldType: FieldType.campo,
          goalkeepers: 1,
          defenders: 4,
          midfielders: 4,
          strikers: 2,
        );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(ThemeColor.violeta, _dark),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: PitchView(
                          formation: formation,
                          assignment:
                              FormationAssigner.assign(_squad, formation),
                          fieldType: FieldType.campo,
                          teamAccent: const Color(0xFFE5484D),
                          shaderEnabled: _shader,
                          freePositioning: _free,
                          onSlotMoved: (slotId, normalized) => setState(() {
                            _custom =
                                formation.withOverride(slotId, normalized);
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FieldControls(
                          freePositioning: _free,
                          hasOverrides: formation.overrides.isNotEmpty,
                          onToggleLock: () => setState(() => _free = !_free),
                          onReset: () => setState(
                              () => _custom = formation.clearOverrides()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      onPressed: () => setState(() => _shader = !_shader),
                      child: Text(_shader ? 'Shader' : 'Painter'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => setState(() => _dark = !_dark),
                      child: Text(_dark ? 'Noite' : 'Dia'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Player> _squad = [
  _p('1', 'Cassio', PlayerPosition.goalkeeper, 7.5),
  _p('2', 'Fagner', PlayerPosition.defender, 7.0),
  _p('3', 'Gil', PlayerPosition.defender, 6.8),
  _p('4', 'Balbuena', PlayerPosition.defender, 7.2),
  _p('5', 'Fabio Santos', PlayerPosition.defender, 6.5),
  _p('6', 'Ralf', PlayerPosition.midfielder, 6.9),
  _p('7', 'Renato Augusto', PlayerPosition.midfielder, 8.2),
  _p('8', 'Rodriguinho', PlayerPosition.midfielder, 7.6),
  _p('9', 'Jadson', PlayerPosition.midfielder, 7.4),
  _p('10', 'Romero', PlayerPosition.striker, 7.1),
  _p('11', 'Jo', PlayerPosition.striker, 7.8),
];

Player _p(String id, String nome, PlayerPosition position, double nota) =>
    Player(
      id: id,
      grupoId: 'preview',
      nome: nome,
      nota: nota,
      ehCapitao: id == '10',
      urlFoto: null,
      position: position,
      reserva: false,
    );
