import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/group.dart';
import '../models/player.dart';
import 'dart:math' as math;

class Team {
  final String name;
  final List<Player> players;
  final double averageSkill;

  Team({required this.name, required this.players})
    : averageSkill =
          players.isEmpty
              ? 0.0
              : players
                      .where((p) => !p.isGoalkeeper)
                      .fold(0.0, (sum, player) => sum + player.nota) /
                  players.length;

  int get goalkeepersCount => players.where((p) => p.isGoalkeeper).length;
  int get captainsCount => players.where((p) => p.ehCapitao).length;

  Team copyWith({String? name, List<Player>? players}) {
    return Team(
      name: name ?? this.name,
      players: players ?? List.from(this.players),
    );
  }
}

class TeamGenerator {
  TeamGenerator({
    required this.algorithm,
    required this.players,
    required this.group,
    required this.numberOfTeams,
  });

  GenerationAlgorithm algorithm;
  List<Player> players = [];
  Group? group;
  int numberOfTeams;

  List<Team> generate() {
    if (numberOfTeams <= 0 || players.isEmpty) {
      return [];
    }

    final fieldPlayers =
        players.where((p) => !p.isGoalkeeper).toList()..shuffle();
    final goalkeepers =
        players.where((p) => p.isGoalkeeper).toList()..shuffle();
    final captains = fieldPlayers.where((p) => p.ehCapitao).toList()..shuffle();
    fieldPlayers.removeWhere((p) => p.ehCapitao);

    List<Team> teams = List.generate(
      numberOfTeams,
      (index) => Team(name: 'Time ${index + 1}', players: []),
    );

    _distributePlayersShuffleEvenly(fieldPlayers, teams);

    _distributePlayersEvenly(captains, teams);

    _balancedTeams(algorithm, teams, players);

    _distributePlayersEvenly(goalkeepers, teams);

    teams.sort((a, b) => a.name.compareTo(b.name));

    return teams;
  }

  void _balancedTeams(
    GenerationAlgorithm algorithm,
    List<Team> teams,
    List<Player> players,
  ) {
    switch (algorithm) {
      case GenerationAlgorithm.balanced:
        _distributePlayersBalanced(teams);
      case GenerationAlgorithm.snakeDraft:
        _distributePlayersSnakeDraft(players, teams);
    }
  }

  void _distributePlayersShuffleEvenly(List<Player> players, List<Team> teams) {
    if (players.isEmpty || teams.isEmpty) return;

    players.shuffle();
    int playersPerTeam = (players.length / teams.length).ceil();

    for (int i = 0; i < teams.length; i++) {
      int startIndex = i * playersPerTeam;
      int endIndex = math.min(startIndex + playersPerTeam, players.length);

      teams[i] = teams[i].copyWith(
        players: players.sublist(startIndex, endIndex),
      );
    }
  }

  void _distributePlayersEvenly(List<Player> players, List<Team> teams) {
    if (players.isEmpty || teams.isEmpty) return;

    if (players.every((p) => p.ehCapitao)) {
      int limit = math.min(players.length, teams.length);
      for (int i = 0; i < limit; i++) {
        teams[i] = teams[i].copyWith(
          players: [...teams[i].players, players[i]],
        );
      }
      return;
    }

    int teamIndex = 0;
    for (final player in players) {
      teams[teamIndex] = teams[teamIndex].copyWith(
        players: [...teams[teamIndex].players, player],
      );

      teamIndex = (teamIndex + 1) % teams.length;
    }
  }

  void _distributePlayersSnakeDraft(List<Player> players, List<Team> teams) {
    if (players.isEmpty || teams.isEmpty) return;

    bool forward = true;
    int teamIndex = 0;

    for (final player in players) {
      teams[teamIndex] = teams[teamIndex].copyWith(
        players: [...teams[teamIndex].players, player],
      );

      if (forward) {
        teamIndex++;
        if (teamIndex >= teams.length) {
          teamIndex = teams.length - 1;
          forward = false;
        }
      } else {
        teamIndex--;
        if (teamIndex < 0) {
          teamIndex = 0;
          forward = true;
        }
      }
    }
  }

  void _distributePlayersBalanced(List<Team> teams) {
    if (teams.length <= 1) return;

    bool improved = true;
    while (improved) {
      improved = false;

      teams.sort((a, b) => b.averageSkill.compareTo(a.averageSkill));

      final strongestTeam = teams.first;
      final weakestTeam = teams.last;

      if (strongestTeam.averageSkill - weakestTeam.averageSkill < 1.0) {
        break;
      }

      for (final playerA in strongestTeam.players) {
        if (playerA.isGoalkeeper) continue;

        for (final playerB in weakestTeam.players) {
          if (playerB.isGoalkeeper) continue;

          final strongTeamPlayers =
              List<Player>.from(strongestTeam.players)
                ..remove(playerA)
                ..add(playerB);

          final weakTeamPlayers =
              List<Player>.from(weakestTeam.players)
                ..remove(playerB)
                ..add(playerA);

          final newStrongTeam = Team(
            name: strongestTeam.name,
            players: strongTeamPlayers,
          );

          final newWeakTeam = Team(
            name: weakestTeam.name,
            players: weakTeamPlayers,
          );

          final currentDiff =
              strongestTeam.averageSkill - weakestTeam.averageSkill;
          final newDiff = math.max(
            newStrongTeam.averageSkill - newWeakTeam.averageSkill,
            newWeakTeam.averageSkill - newStrongTeam.averageSkill,
          );

          if (newDiff < currentDiff) {
            final strongIndex = teams.indexOf(strongestTeam);
            final weakIndex = teams.indexOf(weakestTeam);

            teams[strongIndex] = newStrongTeam;
            teams[weakIndex] = newWeakTeam;

            improved = true;
            break;
          }
        }

        if (improved) break;
      }
    }
  }
}
