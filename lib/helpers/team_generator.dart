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

    final goalkeepers =
        players.where((p) => p.isGoalkeeper).toList()..shuffle();
    final captains = players.where((p) => p.ehCapitao).toList()..shuffle();
    final fieldPlayers =
        players.where((p) => !p.isGoalkeeper && !p.ehCapitao).toList()
          ..shuffle();

    List<Team> teams = List.generate(
      numberOfTeams,
      (index) => Team(name: 'Time ${index + 1}', players: []),
    );

    _balancedTeams(algorithm, teams, fieldPlayers);

    _distributePlayersEvenly(captains, teams);

    _distributePlayersEvenly(goalkeepers, teams);

    teams.sort((a, b) => a.name.compareTo(b.name));

    return teams;
  }

  void _balancedTeams(
    GenerationAlgorithm algorithm,
    List<Team> teams,
    List<Player> fieldPlayers,
  ) {
    switch (algorithm) {
      case GenerationAlgorithm.balanced:
        _distributePlayersBalanced(fieldPlayers, teams);
        break;
      case GenerationAlgorithm.snakeDraft:
        _distributePlayersSnakeDraft(fieldPlayers, teams);
        break;
    }
  }

  void _distributePlayersShuffleEvenly(
    List<Player> fieldPlayers,
    List<Team> teams,
  ) {
    if (fieldPlayers.isEmpty || teams.isEmpty) return;

    int playersPerTeam = (fieldPlayers.length / teams.length).ceil();

    for (int i = 0; i < teams.length; i++) {
      int startIndex = i * playersPerTeam;
      int endIndex = math.min(startIndex + playersPerTeam, fieldPlayers.length);

      teams[i] = teams[i].copyWith(
        players: fieldPlayers.sublist(startIndex, endIndex),
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

    players.sort((a, b) => b.nota.compareTo(a.nota));

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

  void _distributePlayersBalanced(List<Player> fieldPlayers, List<Team> teams) {
    if (teams.length <= 1) return;

    fieldPlayers.shuffle();

    _distributePlayersShuffleEvenly(fieldPlayers, teams);

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
        for (final playerB in weakestTeam.players) {
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
