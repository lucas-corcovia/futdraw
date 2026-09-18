import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/consts/app.colors.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/enums/theme_color.dart';

extension StringToIntExtension on String {
  int toInt({int defaultValue = 0}) {
    return int.tryParse(this) ?? defaultValue;
  }
}

extension StringToDouble on String {
  double toDouble() {
    return double.tryParse(replaceAll(',', '.')) ?? 0.0;
  }
}

extension PlayerPositionExtension on PlayerPosition {
  String get label {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return 'Goleiro';
      case PlayerPosition.defender:
        return 'Defesa';
      case PlayerPosition.midfielder:
        return 'Meio';
      case PlayerPosition.striker:
        return 'Ataque';
    }
  }

  /// Glifo da posicao. E o segundo sinal do chip, junto com a cor e o texto:
  /// cor sozinha nao serve para quem nao distingue vermelho de verde.
  ///
  /// `change_circle` estava em meio-campo e nao dizia nada sobre a funcao; a
  /// familia agora e concreta -- a luva, o escudo, o no que liga os setores e a
  /// bola.
  IconData get icon {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return Icons.back_hand;
      case PlayerPosition.defender:
        return Icons.shield;
      case PlayerPosition.midfielder:
        return Icons.hub;
      case PlayerPosition.striker:
        return Icons.sports_soccer;
    }
  }

  /// Nome completo da posicao. Fonte unica: antes existiam quatro copias
  /// desta tabela (teams_display_view, soccer_field, escalacao_share_widget
  /// e este arquivo), e uma delas vazava o enum cru na UI.
  String get displayName {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return 'Goleiro';
      case PlayerPosition.defender:
        return 'Defensor';
      case PlayerPosition.midfielder:
        return 'Meio-Campo';
      case PlayerPosition.striker:
        return 'Atacante';
    }
  }

  /// Letra unica, para badges onde nao cabe texto.
  String get shortLabel {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return 'G';
      case PlayerPosition.defender:
        return 'Z';
      case PlayerPosition.midfielder:
        return 'M';
      case PlayerPosition.striker:
        return 'A';
    }
  }

  /// Titulo de secao, no plural.
  String get sectionTitle {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return 'Goleiros';
      case PlayerPosition.defender:
        return 'Defensores';
      case PlayerPosition.midfielder:
        return 'Meio-Campistas';
      case PlayerPosition.striker:
        return 'Atacantes';
    }
  }
}

extension ThemeColorExtension on ThemeColor {
  String get label {
    switch (this) {
      case ThemeColor.esmeralda:
        return 'Esmeralda';
      case ThemeColor.oceano:
        return 'Oceano';
      case ThemeColor.violeta:
        return 'Violeta';
      case ThemeColor.carmesim:
        return 'Carmesim';
      case ThemeColor.ambar:
        return 'Âmbar';
      case ThemeColor.petroleo:
        return 'Petróleo';
      case ThemeColor.rosa:
        return 'Rosa';
      case ThemeColor.laranja:
        return 'Laranja';
    }
  }

  Color get seed => ThemeColors.seedColors[this]!;
}

extension GenerationAlgorithmExtension on GenerationAlgorithm {
  String get label {
    switch (this) {
      case GenerationAlgorithm.balanced:
        return 'Balanceado';
      case GenerationAlgorithm.snakeDraft:
        return 'Snake Draft';
    }
  }
}

extension FieldTypeStringExtension on String {
  FieldType toFieldType() {
    return FieldType.values.firstWhere(
      (t) => t.name == this,
      orElse: () => FieldType.campo,
    );
  }
}

extension FieldTypeExtension on FieldType {
  int get defaultPlayersPerTeam {
    switch (this) {
      case FieldType.quadra:
        return 5;
      case FieldType.campo:
        return 11;
      case FieldType.society:
        return 7;
      case FieldType.livre:
        return 0;
    }
  }

  String get displayName {
    switch (this) {
      case FieldType.quadra:
        return "Quadra";
      case FieldType.campo:
        return "Campo";
      case FieldType.society:
        return "Society";
      case FieldType.livre:
        return "Livre";
    }
  }
}
