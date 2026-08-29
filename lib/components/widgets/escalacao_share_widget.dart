import 'package:flutter/material.dart';
import 'package:futdraw/helpers/team_generator.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

class EscalacaoShareWidget extends StatelessWidget {
  final List<Team> teams;

  const EscalacaoShareWidget({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d1117), Color(0xFF161b22)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          ...teams.asMap().entries.expand((entry) => [
                _buildTeamCard(entry.value, entry.key),
                if (entry.key < teams.length - 1) const SizedBox(height: 12),
              ]),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_soccer, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FutDraw',
              style: TextStyle(
                fontFamily: 'PervitinaDex',
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Escalação · ${teams.length} times · ${teams.fold(0, (sum, t) => sum + t.players.length)} jogadores',
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 11,
                color: Color(0xFF8b949e),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamCard(Team team, int index) {
    final teamColors = [
      const Color(0xFF1565C0),
      const Color(0xFFC62828),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFFE65100),
      const Color(0xFF00695C),
    ];
    final teamColor = teamColors[index % teamColors.length];

    final goalkeepers = team.players.where((p) => p.position == PlayerPosition.goalkeeper).toList();
    final defenders = team.players.where((p) => p.position == PlayerPosition.defender).toList();
    final midfielders = team.players.where((p) => p.position == PlayerPosition.midfielder).toList();
    final forwards = team.players.where((p) => p.position == PlayerPosition.striker).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF21262d),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363d)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: teamColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Média ${team.averageSkill.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goalkeepers.isNotEmpty) ...[
                  _buildPositionRow(goalkeepers, Icons.sports_handball, '🧤'),
                  const SizedBox(height: 6),
                ],
                if (defenders.isNotEmpty) ...[
                  _buildPositionRow(defenders, Icons.shield, '🛡'),
                  const SizedBox(height: 6),
                ],
                if (midfielders.isNotEmpty) ...[
                  _buildPositionRow(midfielders, Icons.change_circle, '⚙'),
                  const SizedBox(height: 6),
                ],
                if (forwards.isNotEmpty) ...[
                  _buildPositionRow(forwards, Icons.sports_soccer, '⚡'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionRow(List<Player> players, IconData icon, String emoji) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: players.map((p) => _buildPlayerChip(p, emoji)).toList(),
    );
  }

  Widget _buildPlayerChip(Player player, String positionEmoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF30363d),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: player.ehCapitao
              ? const Color(0xFFFFD700).withValues(alpha: 0.6)
              : const Color(0xFF444c56),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.ehCapitao)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.stars, size: 12, color: Color(0xFFFFD700)),
            ),
          Text(
            '$positionEmoji ${player.nome}',
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 12,
              color: Color(0xFFe6edf3),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF1f6feb),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              player.nota.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1,
          color: const Color(0xFF30363d),
        ),
        const SizedBox(width: 8),
        const Text(
          'futdraw.app',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 11,
            color: Color(0xFF4CAF50),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 1,
          color: const Color(0xFF30363d),
        ),
      ],
    );
  }
}
