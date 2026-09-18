import 'dart:ui' show Offset;

import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';

/// Um lugar no campo.
///
/// **Contrato de coordenada:** `position` e o *centro do chip*, normalizado na
/// caixa cheia `[0,1]x[0,1]`, com `y = 0` no gol adversario e `y = 1` no gol
/// proprio. O recuo para a caixa do chip caber dentro do gramado e
/// responsabilidade do layout, nao das coordenadas escritas aqui -- e isso que
/// mantem o mesmo catalogo valido em qualquer tamanho de tela.
class FormationSlot {
  const FormationSlot({
    required this.id,
    required this.position,
    required this.role,
    required this.row,
  });

  final String id;
  final Offset position;
  final PlayerPosition role;

  /// Indice **visual** de linha, 0 = mais recuada (o goleiro).
  ///
  /// Precisa ser desacoplado de [role]: `PlayerPosition` tem quatro valores,
  /// mas um 4-2-3-1 tem duas linhas distintas que sao ambas `midfielder`, em
  /// alturas diferentes. Sem essa separacao, 4-2-3-1, 3-4-1-2 e 4-1-4-1 sao
  /// todos irrepresentaveis -- que e exatamente por que o codigo anterior so
  /// conseguia desenhar quatro fileiras chapadas.
  final int row;

  /// Quao central o slot e. Usado para dar o lugar mais central ao jogador de
  /// maior nota da linha, que e o que um grafico de escalacao real faz.
  double get centrality => (position.dx - 0.5).abs();

  @override
  bool operator ==(Object other) =>
      other is FormationSlot &&
      other.id == id &&
      other.position == position &&
      other.role == role &&
      other.row == row;

  @override
  int get hashCode => Object.hash(id, position, role, row);
}

class Formation {
  const Formation({
    required this.id,
    required this.label,
    required this.fieldType,
    required this.slots,
    this.isCustom = false,
    this.overrides = const {},
  });

  final String id;

  /// Rotulo que o usuario le, no formato brasileiro: "4-3-3".
  final String label;
  final FieldType fieldType;
  final List<FormationSlot> slots;

  /// Uma formacao personalizada e o que antes era o "modo de edicao livre".
  /// Deixou de ser um modo com um cadeado misterioso e virou so mais uma
  /// opcao na barra de formacao.
  final bool isCustom;

  /// Posicoes movidas a mao, por id de slot, tambem normalizadas.
  ///
  /// Antes isto vivia num `Map<String, Offset>` dentro do `State` do campo e
  /// se perdia a cada rebuild, a cada troca de aba e a cada rotacao, alem de
  /// nunca entrar na imagem compartilhada.
  final Map<String, Offset> overrides;

  Offset positionOf(FormationSlot slot) => overrides[slot.id] ?? slot.position;

  int countOf(PlayerPosition role) =>
      slots.where((s) => s.role == role).length;

  int get size => slots.length;

  /// Linhas visuais, da mais recuada para a mais adiantada.
  List<int> get rows {
    final seen = slots.map((s) => s.row).toSet().toList()..sort();
    return seen;
  }

  List<FormationSlot> slotsInRow(int row) =>
      slots.where((s) => s.row == row).toList();

  /// Congela as posicoes atuais como ponto de partida editavel.
  Formation toCustom() => Formation(
    id: '${id}_custom',
    label: 'Personalizada',
    fieldType: fieldType,
    slots: slots,
    isCustom: true,
    overrides: {for (final slot in slots) slot.id: positionOf(slot)},
  );

  Formation withOverride(String slotId, Offset position) => Formation(
    id: id,
    label: label,
    fieldType: fieldType,
    slots: slots,
    isCustom: true,
    overrides: {...overrides, slotId: position},
  );

  Formation clearOverrides() => Formation(
    id: id,
    label: label,
    fieldType: fieldType,
    slots: slots,
    isCustom: false,
  );

  @override
  bool operator ==(Object other) =>
      other is Formation &&
      other.id == id &&
      other.isCustom == isCustom &&
      other.slots.length == slots.length &&
      _sameOverrides(other.overrides);

  bool _sameOverrides(Map<String, Offset> other) {
    if (other.length != overrides.length) return false;
    for (final entry in overrides.entries) {
      if (other[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, isCustom, slots.length, overrides.length);
}
