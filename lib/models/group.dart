import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.group.dart';
import 'package:futdraw/helpers/time.of.day.dart';
import 'package:futdraw/models/player.dart';

class Group {
  int id;
  String nome;
  List<int> gameDays;
  TimeOfDay gameTime;
  bool fixedGoalkeepers;
  int maxStarters;
  String? defaultLocation;
  FieldType fieldType;
  int gameTimeMinutes;
  int playersPerTeam;
  String? avatarPath;

  int totalPlayersCount;
  int captainCount;
  int substituteCount;
  int goalkeppersCount;
  int playersCount;
  List<Player> players;

  Group({
    required this.id,
    required this.nome,
    required this.gameDays,
    required this.gameTime,
    required this.fixedGoalkeepers,
    required this.maxStarters,
    required this.defaultLocation,
    required this.fieldType,
    required this.gameTimeMinutes,
    required this.playersPerTeam,
    required this.avatarPath,
    this.totalPlayersCount = 0,
    this.captainCount = 0,
    this.substituteCount = 0,
    this.goalkeppersCount = 0,
    this.playersCount = 0,
    this.players = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      nome: json['nome'] as String,
      avatarPath: json['avatarPath'] as String?,
      gameDays: List<int>.from(jsonDecode(json['gameDays'])),
      fixedGoalkeepers: (json['fixedGoalkeepers'] as int) == 1,
      maxStarters: json['maxStarters'] as int,
      defaultLocation: json['defaultLocation'],
      fieldType: FieldType.values.firstWhere(
        (t) => t.index == (json['fieldType'] as int),
        orElse: () => FieldType.livre,
      ),
      gameTime: TimeOfDayHelper.fromDb(json['gameTime']),
      gameTimeMinutes: json['gameTimeMinutes'] as int,
      playersPerTeam: json['playersPerTeam'] as int,
      totalPlayersCount: json['totalPlayersCount'],
      captainCount: json['captainCount'],
      substituteCount: json['substituteCount'],
      goalkeppersCount: json['goalkeppersCount'],
      playersCount: json['playersCount'],
    );
  }

  Map<String, dynamic> toUpdate() {
    return {
      'nome': nome,
      'avatarPath': avatarPath,
      'gameDays': jsonEncode(gameDays),
      'fixedGoalkeepers': fixedGoalkeepers ? 1 : 0,
      'maxStarters': maxStarters,
      'defaultLocation': defaultLocation,
      'fieldType': fieldType.index,
      'gameTime': TimeOfDayHelper.toDb(gameTime),
      'gameTimeMinutes': gameTimeMinutes,
      'playersPerTeam': playersPerTeam,
    };
  }

  // Get formatted game days string
  String get formattedGameDays {
    if (gameDays.isEmpty) return 'Não definido';
    return gameDays.join(', ');
  }

  // Get formatted game time
  String get formattedGameTime {
    return gameTime.toString();
  }

  // Get formatted game duration
  String get formattedGameDuration {
    if (gameTimeMinutes <= 0) return 'Não definido';
    final hours = gameTimeMinutes ~/ 60;
    final minutes = gameTimeMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
    return '${minutes}min';
  }
}
