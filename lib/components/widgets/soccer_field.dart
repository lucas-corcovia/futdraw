import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/models/consts/app.colors.dart';
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
  bool isFreeEditMode = false;
  Player? _selectedPlayer;
  final Map<String, Offset> _freePositions = {};

  // GlobalKey garante referência correta ao RenderBox do campo
  final GlobalKey _fieldKey = GlobalKey();

  static const double _avatarSize = 60.0;
  static const double _feedbackScale = 1.25;
  static const double _feedbackSize = _avatarSize * _feedbackScale;

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
          key: _fieldKey,
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
                    Color(0xFF0E8B42),
                    Color(0xFF0D7A3C),
                    Color(0xFF0E8B42),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
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

            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  setState(() {
                    if (!isFreeEditMode) {
                      _initializeFreePositions(fieldWidth, fieldHeight);
                    }
                    isFreeEditMode = !isFreeEditMode;
                  });
                },
                tooltip:
                    isFreeEditMode
                        ? 'Bloquear edição livre'
                        : 'Liberar edição livre',
                child: Icon(isFreeEditMode ? Icons.lock_open : Icons.lock),
              ),
            ),

            if (!isFreeEditMode)
              ..._positionGoalkeepers(fieldWidth, fieldHeight),
            if (!isFreeEditMode) ..._positionDefenders(fieldWidth, fieldHeight),
            if (!isFreeEditMode)
              ..._positionMidfielders(fieldWidth, fieldHeight),
            if (!isFreeEditMode) ..._positionForwards(fieldWidth, fieldHeight),
            if (isFreeEditMode) ..._buildFreePlayers(fieldWidth, fieldHeight),
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
          left: spacing * (i + 1) - _avatarSize / 2,
          top: yPosition - _avatarSize / 2,
          child: _buildSwappablePlayer(_goalkeepers[i]),
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
          left: spacing * (i + 1) - _avatarSize / 2,
          top: yPosition - _avatarSize / 2,
          child: _buildSwappablePlayer(_defenders[i]),
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
          left: spacing * (i + 1) - _avatarSize / 2,
          top: yPosition - _avatarSize / 2,
          child: _buildSwappablePlayer(_midfielders[i]),
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
          left: spacing * (i + 1) - _avatarSize / 2,
          top: yPosition - _avatarSize / 2,
          child: _buildSwappablePlayer(_forwards[i]),
        ),
      );
    }
    return positioned;
  }

  // Jogador arrastável no modo swap: DragTarget + LongPressDraggable aninhados
  Widget _buildSwappablePlayer(Player player) {
    return DragTarget<Player>(
      onWillAcceptWithDetails:
          (details) => details.data.id != player.id,
      onAcceptWithDetails: (details) {
        HapticFeedback.lightImpact();
        widget.onPlayersSwapped(player, details.data);
        setState(() => _selectedPlayer = null);
      },
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;
        final isSelected = _selectedPlayer?.id == player.id;

        return LongPressDraggable<Player>(
          data: player,
          // 200ms é responsivo sem acionar drags acidentais
          delay: const Duration(milliseconds: 200),
          onDragStarted: () {
            HapticFeedback.mediumImpact();
            setState(() => _selectedPlayer = null);
          },
          feedback: _buildDragFeedback(player),
          childWhenDragging: _buildPlayerAvatar(
            player,
            _avatarSize,
            opacity: 0.35,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                if (_selectedPlayer == null) {
                  _selectedPlayer = player;
                } else if (_selectedPlayer!.id == player.id) {
                  _selectedPlayer = null;
                } else {
                  HapticFeedback.lightImpact();
                  widget.onPlayersSwapped(_selectedPlayer!, player);
                  _selectedPlayer = null;
                }
              });
            },
            child: _buildPlayerAvatar(
              player,
              _avatarSize,
              isHighlighted: isSelected || isTarget,
            ),
          ),
        );
      },
    );
  }

  // Feedback flutuante ao arrastar: avatar ligeiramente maior com sombra elevada
  Widget _buildDragFeedback(Player player) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: _feedbackScale,
        child: _buildPlayerAvatar(player, _avatarSize, isHighlighted: true),
      ),
    );
  }

  void _initializeFreePositions(double width, double height) {
    _freePositions.clear();

    final gkY = height * 0.85;
    final gkSpacing = width / (_goalkeepers.length + 1);
    for (int i = 0; i < _goalkeepers.length; i++) {
      _freePositions[_goalkeepers[i].id] = Offset(gkSpacing * (i + 1), gkY);
    }

    final defY = height * 0.65;
    final defSpacing = width / (_defenders.length + 1);
    for (int i = 0; i < _defenders.length; i++) {
      _freePositions[_defenders[i].id] = Offset(defSpacing * (i + 1), defY);
    }

    final midY = height * 0.40;
    final midSpacing = width / (_midfielders.length + 1);
    for (int i = 0; i < _midfielders.length; i++) {
      _freePositions[_midfielders[i].id] = Offset(
        midSpacing * (i + 1),
        midY,
      );
    }

    final fwdY = height * 0.15;
    final fwdSpacing = width / (_forwards.length + 1);
    for (int i = 0; i < _forwards.length; i++) {
      _freePositions[_forwards[i].id] = Offset(fwdSpacing * (i + 1), fwdY);
    }
  }

  List<Widget> _buildFreePlayers(double width, double height) {
    const half = _avatarSize / 2;

    return widget.players.map((player) {
      final pos = _freePositions[player.id] ?? Offset(width / 2, height / 2);

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        left: pos.dx - half,
        top: pos.dy - half,
        child: Draggable<Player>(
          data: player,
          onDragStarted: () => HapticFeedback.mediumImpact(),
          feedback: _buildDragFeedback(player),
          childWhenDragging: _buildPlayerAvatar(
            player,
            _avatarSize,
            opacity: 0.3,
          ),
          child: _buildPlayerAvatar(player, _avatarSize),
          onDragEnd: (details) {
            final RenderBox? box =
                _fieldKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;

            // details.offset = canto superior esquerdo do feedback widget em coords globais
            // feedback tem escala 1.25, então seu tamanho real = _feedbackSize
            // centro do feedback em coords globais:
            const feedbackHalf = _feedbackSize / 2;
            final centerGlobal =
                details.offset + const Offset(feedbackHalf, feedbackHalf);
            final localCenter = box.globalToLocal(centerGlobal);

            // Impede que o jogador saia dos limites do campo
            final clamped = Offset(
              localCenter.dx.clamp(half, width - half),
              localCenter.dy.clamp(half, height - half),
            );

            setState(() => _freePositions[player.id] = clamped);
          },
        ),
      );
    }).toList();
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isHighlighted
                        ? Colors.white
                        : player.ehCapitao
                        ? Theme.of(context).colorScheme.tertiary
                        : _getPositionColor(player.position),
                width: isHighlighted ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isHighlighted
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                  blurRadius: isHighlighted ? 12 : 6,
                  spreadRadius: isHighlighted ? 2 : 0,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
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
                            color: CommonsColors.avatarFieldBackgroundColor,
                            child: Center(
                              child: Text(
                                player.nome[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
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
                  color: Colors.black.withAlpha(160),
                  offset: const Offset(1, 1),
                  blurRadius: 3,
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
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 1.5
          ..isAntiAlias = true;

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
          ..color = Colors.white.withValues(alpha: 0.8)
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
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.0, dotPaint);

    final penaltyWidth = size.width * 0.5;
    final penaltyHeight = size.height * 0.2;
    final penaltyLeft = (size.width - penaltyWidth) / 2;

    canvas.drawRect(
      Rect.fromLTWH(penaltyLeft, 0, penaltyWidth, penaltyHeight),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        penaltyLeft,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      paint,
    );

    final goalWidth = size.width * 0.3;
    final goalHeight = size.height * 0.08;
    final goalLeft = (size.width - goalWidth) / 2;

    canvas.drawRect(Rect.fromLTWH(goalLeft, 0, goalWidth, goalHeight), paint);

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
    const sweepAngle = 1.57;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
      startAngle + 1.57,
      sweepAngle,
      false,
      paint,
    );

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

    canvas.drawArc(
      Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
      startAngle + 4.71,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
