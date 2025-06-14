import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.group.dart';
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
      case ThemeColor.blue:
        return 'Azul';
      case ThemeColor.green:
        return 'Verde';
      case ThemeColor.purple:
        return 'Roxo';
      case ThemeColor.red:
        return 'Vermelho';
    }
  }
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
