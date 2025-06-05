import 'package:flutter/material.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/group.dart';
import 'package:provider/provider.dart';

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
  static List<Team> generateBalancedTeams({
    required BuildContext context,
    required List<Player> players,
    required int numberOfTeams,
    required Group? group,
  }) {
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

    _balancedTeams(context, teams, players);

    _distributePlayersEvenly(goalkeepers, teams);

    teams.sort((a, b) => a.name.compareTo(b.name));

    return teams;
  }

  static void _balancedTeams(
    BuildContext context,
    List<Team> teams,
    List<Player> players,
  ) {
    var algorithm =
        context
            .read<ConfigurationsController>()
            .configuration
            .generationAlgorithm;

    switch (algorithm) {
      case GenerationAlgorithm.balanced:
        _distributePlayersBalanced(teams);
      case GenerationAlgorithm.snakeDraft:
        _distributePlayersSnakeDraft(players, teams);
    }
  }

  static void _distributePlayersShuffleEvenly(
    List<Player> players,
    List<Team> teams,
  ) {
    if (players.isEmpty || teams.isEmpty) return;

    players.shuffle();
    int playersPerTeam = (players.length / teams.length).ceil();

    for (int i = 0; i < teams.length; i++) {
      teams[i] = teams[i].copyWith(
        players: players.sublist(i * playersPerTeam, (i + 1) * playersPerTeam),
      );
    }
  }

  // Distribute players evenly across teams
  static void _distributePlayersEvenly(List<Player> players, List<Team> teams) {
    if (players.isEmpty || teams.isEmpty) return;

    // For captains, make sure they are distributed to different teams
    if (players.every((p) => p.ehCapitao)) {
      // If all players in this group are captains (rare case)
      // Make sure not to exceed number of teams
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

  // Distribute players using snake draft order (1->2->3->3->2->1)
  static void _distributePlayersSnakeDraft(
    List<Player> players,
    List<Team> teams,
  ) {
    if (players.isEmpty || teams.isEmpty) return;

    bool forward = true;
    int teamIndex = 0;

    for (final player in players) {
      teams[teamIndex] = teams[teamIndex].copyWith(
        players: [...teams[teamIndex].players, player],
      );

      // Calculate next team index with snake draft logic
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

  // Make final adjustments to balance team skills
  static void _distributePlayersBalanced(List<Team> teams) {
    if (teams.length <= 1) return;

    bool improved = true;
    while (improved) {
      improved = false;

      // Find the most and least skilled teams
      teams.sort((a, b) => b.averageSkill.compareTo(a.averageSkill));

      final strongestTeam = teams.first;
      final weakestTeam = teams.last;

      if (strongestTeam.averageSkill - weakestTeam.averageSkill < 1.0) {
        // Teams are already fairly balanced
        break;
      }

      // Try to swap players to improve balance
      for (final playerA in strongestTeam.players) {
        if (playerA.isGoalkeeper) continue; // Don't swap goalkeepers

        for (final playerB in weakestTeam.players) {
          if (playerB.isGoalkeeper) continue; // Don't swap goalkeepers

          // Calculate new average skills after potential swap
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

          // Check if the swap improves balance
          final currentDiff =
              strongestTeam.averageSkill - weakestTeam.averageSkill;
          final newDiff = math.max(
            newStrongTeam.averageSkill - newWeakTeam.averageSkill,
            newWeakTeam.averageSkill - newStrongTeam.averageSkill,
          );

          if (newDiff < currentDiff) {
            // Apply the swap
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
