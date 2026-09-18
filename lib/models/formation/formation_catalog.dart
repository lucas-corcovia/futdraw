import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/formation.dart';

FormationSlot _slot(
  String id,
  double x,
  double y,
  PlayerPosition role,
  int row,
) => FormationSlot(id: id, position: Offset(x, y), role: role, row: row);

const _gk = PlayerPosition.goalkeeper;
const _def = PlayerPosition.defender;
const _mid = PlayerPosition.midfielder;
const _atk = PlayerPosition.striker;

/// Catalogo de formacoes por modalidade.
///
/// Os presets sao escritos a mao, com assimetrias de proposito: laterais ficam
/// alguns centesimos mais adiantados que zagueiros centrais, volantes recuam,
/// pontas abrem mais que o centroavante. Fileiras perfeitamente igualmente
/// espacadas sao o que o codigo antigo produzia, e sao exatamente o que faz a
/// tela parecer um diagrama em vez de uma escalacao.
abstract final class FormationCatalog {
  static List<Formation> presetsFor(FieldType fieldType) => switch (fieldType) {
    FieldType.quadra => _quadra,
    FieldType.society => _society,
    FieldType.campo => _campo,
    FieldType.livre => const [],
  };

  static Formation defaultFor(FieldType fieldType) => switch (fieldType) {
    FieldType.quadra => _quadra.first,
    FieldType.society => _society.first,
    FieldType.campo => _campo.first,
    // "Livre" nao tem preset: a formacao sai das contagens reais do elenco.
    FieldType.livre => derivedFromCounts(
      fieldType: FieldType.livre,
      goalkeepers: 1,
      defenders: 2,
      midfielders: 2,
      strikers: 1,
    ),
  };

  /// Resolve a tatica guardada no grupo.
  ///
  /// Primeiro procura um preset com exatamente essas contagens, para que
  /// `[1,4,4,2]` devolva o 4-4-2 desenhado a mao e nao uma grade gerada. So
  /// sintetiza quando nao encontra.
  static Formation fromTactic({
    required FieldType fieldType,
    required int goalkeepers,
    required int defenders,
    required int midfielders,
    required int strikers,
  }) {
    for (final preset in presetsFor(fieldType)) {
      if (preset.countOf(_gk) == goalkeepers &&
          preset.countOf(_def) == defenders &&
          preset.countOf(_mid) == midfielders &&
          preset.countOf(_atk) == strikers) {
        return preset;
      }
    }
    return derivedFromCounts(
      fieldType: fieldType,
      goalkeepers: goalkeepers,
      defenders: defenders,
      midfielders: midfielders,
      strikers: strikers,
    );
  }

  static final Map<String, Formation> _synthesized = {};

  /// Sintetiza uma formacao a partir de contagens.
  ///
  /// E tambem o fallback gracioso: e o comportamento que a tela ja tinha antes
  /// da v2 -- fileiras distribuidas pela contagem -- so que agora com um leve
  /// arco, para os jogadores das pontas ficarem um pouco mais recuados que os
  /// do centro, como numa escalacao de verdade.
  static Formation derivedFromCounts({
    required FieldType fieldType,
    required int goalkeepers,
    required int defenders,
    required int midfielders,
    required int strikers,
  }) {
    final key =
        '${fieldType.name}_${goalkeepers}_${defenders}_${midfielders}_$strikers';
    final cached = _synthesized[key];
    if (cached != null) return cached;

    final bands = _bandsFor(fieldType);
    final slots = <FormationSlot>[];
    var row = 0;

    void addLine(int count, PlayerPosition role, double y, String prefix) {
      if (count <= 0) return;
      for (var i = 0; i < count; i++) {
        final x = (i + 1) / (count + 1);
        // Arco: quem esta na ponta recua um pouco.
        final spread = count > 1 ? (2 * i / (count - 1)) - 1 : 0.0;
        final arc = 0.025 * (1 - math.cos(math.pi * spread)) / 2;
        slots.add(_slot('$prefix${i + 1}', x, y + arc, role, row));
      }
      row++;
    }

    addLine(goalkeepers, _gk, bands.gk, 'GK');
    addLine(defenders, _def, bands.def, 'D');
    addLine(midfielders, _mid, bands.mid, 'M');
    addLine(strikers, _atk, bands.atk, 'A');

    final label = [
      defenders,
      midfielders,
      strikers,
    ].where((n) => n > 0).join('-');

    final formation = Formation(
      id: key,
      label: label.isEmpty ? 'Livre' : label,
      fieldType: fieldType,
      slots: slots,
    );
    _synthesized[key] = formation;
    return formation;
  }

  /// Faixas de altura por modalidade. Herdadas do `_FieldLayout` que vivia
  /// privado dentro do widget do campo.
  static ({double gk, double def, double mid, double atk}) _bandsFor(
    FieldType fieldType,
  ) => switch (fieldType) {
    FieldType.quadra => (gk: 0.88, def: 0.66, mid: 0.44, atk: 0.22),
    FieldType.society => (gk: 0.89, def: 0.70, mid: 0.48, atk: 0.24),
    FieldType.campo || FieldType.livre => (
      gk: 0.92,
      def: 0.72,
      mid: 0.50,
      atk: 0.24,
    ),
  };

  // ── Campo, 11 contra 11 ────────────────────────────────────────────────

  static const List<Formation> _campo = [
    Formation(
      id: 'campo_442',
      label: '4-4-2',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.14, 0.69), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.38, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.62, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D4', position: Offset(0.86, 0.69), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.13, 0.46), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.38, 0.51), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.62, 0.51), role: _mid, row: 2),
        FormationSlot(id: 'M4', position: Offset(0.87, 0.46), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.37, 0.22), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.63, 0.22), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'campo_433',
      label: '4-3-3',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.14, 0.69), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.38, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.62, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D4', position: Offset(0.86, 0.69), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.27, 0.52), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.50, 0.57), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.73, 0.52), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.14, 0.27), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.50, 0.18), role: _atk, row: 3),
        FormationSlot(id: 'A3', position: Offset(0.86, 0.27), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'campo_4231',
      label: '4-2-3-1',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.14, 0.69), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.38, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.62, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D4', position: Offset(0.86, 0.69), role: _def, row: 1),
        // Dupla de volantes: a linha que so existe porque `row` e independente
        // de `PlayerPosition`.
        FormationSlot(id: 'M1', position: Offset(0.36, 0.57), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.64, 0.57), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.15, 0.36), role: _mid, row: 3),
        FormationSlot(id: 'M4', position: Offset(0.50, 0.34), role: _mid, row: 3),
        FormationSlot(id: 'M5', position: Offset(0.85, 0.36), role: _mid, row: 3),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.16), role: _atk, row: 4),
      ],
    ),
    Formation(
      id: 'campo_352',
      label: '3-5-2',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.25, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.50, 0.76), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.75, 0.73), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.08, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.31, 0.55), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.50, 0.58), role: _mid, row: 2),
        FormationSlot(id: 'M4', position: Offset(0.69, 0.55), role: _mid, row: 2),
        FormationSlot(id: 'M5', position: Offset(0.92, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.37, 0.21), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.63, 0.21), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'campo_532',
      label: '5-3-2',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.09, 0.67), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.31, 0.75), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.50, 0.77), role: _def, row: 1),
        FormationSlot(id: 'D4', position: Offset(0.69, 0.75), role: _def, row: 1),
        FormationSlot(id: 'D5', position: Offset(0.91, 0.67), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.28, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.50, 0.54), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.72, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.37, 0.22), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.63, 0.22), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'campo_451',
      label: '4-5-1',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.14, 0.69), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.38, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.62, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D4', position: Offset(0.86, 0.69), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.10, 0.47), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.31, 0.53), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.50, 0.56), role: _mid, row: 2),
        FormationSlot(id: 'M4', position: Offset(0.69, 0.53), role: _mid, row: 2),
        FormationSlot(id: 'M5', position: Offset(0.90, 0.47), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.20), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'campo_343',
      label: '3-4-3',
      fieldType: FieldType.campo,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.92), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.25, 0.73), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.50, 0.76), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.75, 0.73), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.11, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.37, 0.55), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.63, 0.55), role: _mid, row: 2),
        FormationSlot(id: 'M4', position: Offset(0.89, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.16, 0.26), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.50, 0.19), role: _atk, row: 3),
        FormationSlot(id: 'A3', position: Offset(0.84, 0.26), role: _atk, row: 3),
      ],
    ),
  ];

  // ── Society, 7 contra 7 ────────────────────────────────────────────────

  static const List<Formation> _society = [
    Formation(
      id: 'society_231',
      label: '2-3-1',
      fieldType: FieldType.society,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.90), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.29, 0.71), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.71, 0.71), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.15, 0.48), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.50, 0.53), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.85, 0.48), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.22), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'society_321',
      label: '3-2-1',
      fieldType: FieldType.society,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.90), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.19, 0.71), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.50, 0.75), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.81, 0.71), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.32, 0.48), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.68, 0.48), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.22), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'society_222',
      label: '2-2-2',
      fieldType: FieldType.society,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.90), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.30, 0.72), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.70, 0.72), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.28, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.72, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.32, 0.24), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.68, 0.24), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'society_312',
      label: '3-1-2',
      fieldType: FieldType.society,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.90), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.19, 0.71), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.50, 0.75), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.81, 0.71), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.50, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.32, 0.24), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.68, 0.24), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'society_132',
      label: '1-3-2',
      fieldType: FieldType.society,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.90), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.50, 0.74), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.19, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.50, 0.54), role: _mid, row: 2),
        FormationSlot(id: 'M3', position: Offset(0.81, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.32, 0.24), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.68, 0.24), role: _atk, row: 3),
      ],
    ),
  ];

  // ── Quadra / futsal, 5 contra 5 ────────────────────────────────────────

  static const List<Formation> _quadra = [
    Formation(
      id: 'quadra_121',
      label: '1-2-1',
      fieldType: FieldType.quadra,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.88), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.50, 0.70), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.23, 0.49), role: _mid, row: 2),
        FormationSlot(id: 'M2', position: Offset(0.77, 0.49), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.24), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'quadra_211',
      label: '2-1-1',
      fieldType: FieldType.quadra,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.88), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.29, 0.70), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.71, 0.70), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.50, 0.48), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.24), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'quadra_22',
      label: '2-2',
      fieldType: FieldType.quadra,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.88), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.29, 0.66), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.71, 0.66), role: _def, row: 1),
        FormationSlot(id: 'A1', position: Offset(0.29, 0.28), role: _atk, row: 2),
        FormationSlot(id: 'A2', position: Offset(0.71, 0.28), role: _atk, row: 2),
      ],
    ),
    Formation(
      id: 'quadra_112',
      label: '1-1-2',
      fieldType: FieldType.quadra,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.88), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.50, 0.72), role: _def, row: 1),
        FormationSlot(id: 'M1', position: Offset(0.50, 0.50), role: _mid, row: 2),
        FormationSlot(id: 'A1', position: Offset(0.29, 0.26), role: _atk, row: 3),
        FormationSlot(id: 'A2', position: Offset(0.71, 0.26), role: _atk, row: 3),
      ],
    ),
    Formation(
      id: 'quadra_31',
      label: '3-1',
      fieldType: FieldType.quadra,
      slots: [
        FormationSlot(id: 'GK', position: Offset(0.50, 0.88), role: _gk, row: 0),
        FormationSlot(id: 'D1', position: Offset(0.21, 0.67), role: _def, row: 1),
        FormationSlot(id: 'D2', position: Offset(0.50, 0.71), role: _def, row: 1),
        FormationSlot(id: 'D3', position: Offset(0.79, 0.67), role: _def, row: 1),
        FormationSlot(id: 'A1', position: Offset(0.50, 0.28), role: _atk, row: 2),
      ],
    ),
  ];
}
