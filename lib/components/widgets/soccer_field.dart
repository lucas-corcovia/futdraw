import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

class SoccerField extends StatefulWidget {
  final List<Player> players;
  final Function(Player, Player) onPlayersSwapped;

  const SoccerField({
    super.key,
    required this.players,
    required this.onPlayersSwapped,
  });

  @override
  State<SoccerField> createState() => _SoccerFieldState();
}

class _SoccerFieldState extends State<SoccerField> {
  List<Player> _goalkeepers = [];
  List<Player> _defenders = [];
  List<Player> _midfielders = [];
  List<Player> _forwards = [];

  @override
  void initState() {
    super.initState();
    _organizePlayers();
  }

  @override
  void didUpdateWidget(SoccerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.players != widget.players) {
      _organizePlayers();
    }
  }

  void _organizePlayers() {
    _goalkeepers =
        widget.players
            .where((p) => p.position == PlayerPosition.goalkeeper)
            .toList();
    _defenders =
        widget.players
            .where((p) => p.position == PlayerPosition.defender)
            .toList();
    _midfielders =
        widget.players
            .where((p) => p.position == PlayerPosition.midfielder)
            .toList();
    _forwards =
        widget.players
            .where((p) => p.position == PlayerPosition.striker)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldHeight = constraints.maxHeight;
        final fieldWidth = constraints.maxWidth;

        return Stack(
          children: [
            // Soccer field background
            Container(
              width: fieldWidth,
              height: fieldHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E8B42), // Base green
                    Color(0xFF0D7A3C), // Slightly darker green
                    Color(0xFF0E8B42), // Back to base green
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // Add grass pattern effect
              child: CustomPaint(
                painter: GrassPatternPainter(),
                size: Size(fieldWidth, fieldHeight),
              ),
            ),

            // Field lines
            CustomPaint(
              size: Size(fieldWidth, fieldHeight),
              painter: FieldPainter(),
            ),

            // Position the players
            ..._positionGoalkeepers(fieldWidth, fieldHeight),
            ..._positionDefenders(fieldWidth, fieldHeight),
            ..._positionMidfielders(fieldWidth, fieldHeight),
            ..._positionForwards(fieldWidth, fieldHeight),
          ],
        );
      },
    );
  }

  List<Widget> _positionGoalkeepers(double width, double height) {
    final List<Widget> positioned = [];
    final int count = _goalkeepers.length;

    if (count == 0) return positioned;

    final double yPosition = height * 0.85;
    final double spacing = width / (count + 1);

    for (int i = 0; i < count; i++) {
      positioned.add(
        Positioned(
          left: spacing * (i + 1) - 30,
          top: yPosition - 30,
          child: _buildDraggablePlayer(_goalkeepers[i], 'GK'),
        ),
      );
    }

    return positioned;
  }

  List<Widget> _positionDefenders(double width, double height) {
    final List<Widget> positioned = [];
    final int count = _defenders.length;

    if (count == 0) return positioned;

    final double yPosition = height * 0.65;
    final double spacing = width / (count + 1);

    for (int i = 0; i < count; i++) {
      positioned.add(
        Positioned(
          left: spacing * (i + 1) - 30,
          top: yPosition - 30,
          child: _buildDraggablePlayer(_defenders[i], 'DEF'),
        ),
      );
    }

    return positioned;
  }

  List<Widget> _positionMidfielders(double width, double height) {
    final List<Widget> positioned = [];
    final int count = _midfielders.length;

    if (count == 0) return positioned;

    final double yPosition = height * 0.40;
    final double spacing = width / (count + 1);

    for (int i = 0; i < count; i++) {
      positioned.add(
        Positioned(
          left: spacing * (i + 1) - 30,
          top: yPosition - 30,
          child: _buildDraggablePlayer(_midfielders[i], 'MID'),
        ),
      );
    }

    return positioned;
  }

  List<Widget> _positionForwards(double width, double height) {
    final List<Widget> positioned = [];
    final int count = _forwards.length;

    if (count == 0) return positioned;

    final double yPosition = height * 0.15;
    final double spacing = width / (count + 1);

    for (int i = 0; i < count; i++) {
      positioned.add(
        Positioned(
          left: spacing * (i + 1) - 30,
          top: yPosition - 30,
          child: _buildDraggablePlayer(_forwards[i], 'FWD'),
        ),
      );
    }

    return positioned;
  }

  Widget _buildDraggablePlayer(Player player, String position) {
    return DragTarget<Player>(
      onWillAccept: (incomingPlayer) {
        // Allow dropping only if player is from the same position
        return incomingPlayer != null && incomingPlayer.position == position;
      },
      onAccept: (incomingPlayer) {
        widget.onPlayersSwapped(player, incomingPlayer);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Draggable<Player>(
          data: player,
          feedback: _buildPlayerAvatar(player, 60, isHighlighted: true),
          childWhenDragging: _buildPlayerAvatar(player, 60, opacity: 0.3),
          child: _buildPlayerAvatar(player, 60, isHighlighted: isHighlighted),
        );
      },
    );
  }

  Widget _buildPlayerAvatar(
    Player player,
    double size, {
    double opacity = 1.0,
    bool isHighlighted = false,
  }) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isHighlighted
                        ? Theme.of(context).colorScheme.tertiary
                        : player.ehCapitao
                        ? Theme.of(context).colorScheme.tertiary
                        : _getPositionColor(player.position),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipOval(
                  child:
                      player.urlFoto != null
                          ? Image.network(
                            player.urlFoto!,
                            width: size,
                            height: size,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            color: Theme.of(context).colorScheme.primary,
                            child: Center(
                              child: Text(
                                player.nome[0].toUpperCase(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size / 3,
                                ),
                              ),
                            ),
                          ),
                ),
                if (player.ehCapitao)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_outlined,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: size / 4,
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getPositionColor(player.position),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getPositionShortLabel(player.position),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size / 5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            player.nome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size / 4,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(100),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return Colors.yellow;
      case PlayerPosition.defender:
        return Colors.blue;
      case PlayerPosition.midfielder:
        return Colors.green;
      case PlayerPosition.striker:
        return Colors.red;
    }
  }

  String _getPositionShortLabel(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return 'G';
      case PlayerPosition.defender:
        return 'D';
      case PlayerPosition.midfielder:
        return 'M';
      case PlayerPosition.striker:
        return 'A';
    }
  }
}

class GrassPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1.5
          ..isAntiAlias = true;

    // Create vertical stripes for a soccer field effect
    final double stripeWidth = size.width / 12;
    for (int i = 0; i < 12; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FieldPainter extends CustomPainter {
  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;

    // Center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 8,
      paint,
    );

    // Center dot
    final dotPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.0, dotPaint);

    // Penalty areas
    final penaltyWidth = size.width * 0.5;
    final penaltyHeight = size.height * 0.2;
    final penaltyLeft = (size.width - penaltyWidth) / 2;

    // Top penalty area
    canvas.drawRect(
      Rect.fromLTWH(penaltyLeft, 0, penaltyWidth, penaltyHeight),
      paint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        penaltyLeft,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      paint,
    );

    // Goal areas
    final goalWidth = size.width * 0.3;
    final goalHeight = size.height * 0.08;
    final goalLeft = (size.width - goalWidth) / 2;

    // Top goal area
    canvas.drawRect(Rect.fromLTWH(goalLeft, 0, goalWidth, goalHeight), paint);

    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(goalLeft, size.height - goalHeight, goalWidth, goalHeight),
      paint,
    );

    // Field outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    // Corner arcs
    final radius = size.width * 0.05;
    const startAngle = 0.0;
    const sweepAngle = 1.57; // 90 degrees in radians

    // Top-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Top-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
      startAngle + 1.57,
      sweepAngle,
      false,
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - radius * 2,
        size.height - radius * 2,
        radius * 2,
        radius * 2,
      ),
      startAngle + 3.14,
      sweepAngle,
      false,
      paint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
      startAngle + 4.71,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
