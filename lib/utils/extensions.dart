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

  IconData get icon {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return Icons.sports_handball;
      case PlayerPosition.defender:
        return Icons.shield;
      case PlayerPosition.midfielder:
        return Icons.change_circle;
      case PlayerPosition.striker:
        return Icons.sports_soccer;
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
