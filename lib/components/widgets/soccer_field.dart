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
            // Layer 1+2: Base de grama com gradiente radial + listras de corte
            Container(
              width: fieldWidth,
              height: fieldHeight,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment(0, -0.05),
                  radius: 1.0,
                  colors: [
                    Color(0xFF2EC066), // centro iluminado (holofote)
                    Color(0xFF178A40), // meio campo
                    Color(0xFF0A4F24), // bordas escuras
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0A4F24).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: MowStripePainter(),
                  size: Size(fieldWidth, fieldHeight),
                ),
              ),
            ),

            // Layer 3: Linhas do campo
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: FieldPainter(),
                size: Size(fieldWidth, fieldHeight),
              ),
            ),

            // Layer 4: Vinheta — sombra nas bordas simulando estádio
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: VignettePainter(),
                size: Size(fieldWidth, fieldHeight),
              ),
            ),

            // Botão de modo de edição livre
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

            const feedbackHalf = _feedbackSize / 2;
            final centerGlobal =
                details.offset + const Offset(feedbackHalf, feedbackHalf);
            final localCenter = box.globalToLocal(centerGlobal);

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

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

/// Listras horizontais de corte alternando claro/escuro (padrão de estádio).
class MowStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const int stripes = 10;
    final double stripeHeight = size.height / stripes;

    for (int i = 0; i < stripes; i++) {
      final paint =
          Paint()
            ..color =
                i.isEven
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.10);
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Marcações do campo: linha do meio, círculo central, grandes áreas,
/// áreas de gol, arcos de pênalti, manchões e cantos.
class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.90)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;

    final dotPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

    // ── Linha do meio ──────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // ── Círculo central ────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 8,
      paint,
    );

    // Ponto central
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.5, dotPaint);

    // ── Grandes áreas ──────────────────────────────────────────────────────
    final penaltyWidth = size.width * 0.5;
    final penaltyHeight = size.height * 0.2;
    final penaltyLeft = (size.width - penaltyWidth) / 2;

    // Grande área superior
    canvas.drawRect(
      Rect.fromLTWH(penaltyLeft, 0, penaltyWidth, penaltyHeight),
      paint,
    );
    // Grande área inferior
    canvas.drawRect(
      Rect.fromLTWH(
        penaltyLeft,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      paint,
    );

    // ── Áreas de gol ───────────────────────────────────────────────────────
    final goalWidth = size.width * 0.3;
    final goalHeight = size.height * 0.08;
    final goalLeft = (size.width - goalWidth) / 2;

    canvas.drawRect(
      Rect.fromLTWH(goalLeft, 0, goalWidth, goalHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(goalLeft, size.height - goalHeight, goalWidth, goalHeight),
      paint,
    );

    // ── Manchões de pênalti ────────────────────────────────────────────────
    final penaltySpotTopY = penaltyHeight * 0.62;
    final penaltySpotBottomY = size.height - penaltySpotTopY;
    final penaltySpotX = size.width / 2;

    canvas.drawCircle(Offset(penaltySpotX, penaltySpotTopY), 4.0, dotPaint);
    canvas.drawCircle(Offset(penaltySpotX, penaltySpotBottomY), 4.0, dotPaint);

    // ── Arcos de pênalti (D) ───────────────────────────────────────────────
    final arcRadius = size.height * 0.12;

    // Arco superior: apenas a porção ABAIXO da grande área superior
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, penaltyHeight, size.width, size.height - penaltyHeight),
    );
    canvas.drawCircle(
      Offset(penaltySpotX, penaltySpotTopY),
      arcRadius,
      paint,
    );
    canvas.restore();

    // Arco inferior: apenas a porção ACIMA da grande área inferior
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width, size.height - penaltyHeight),
    );
    canvas.drawCircle(
      Offset(penaltySpotX, penaltySpotBottomY),
      arcRadius,
      paint,
    );
    canvas.restore();

    // ── Contorno do campo ──────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    // ── Cantos ─────────────────────────────────────────────────────────────
    final cornerRadius = size.width * 0.05;
    const sweep = 1.5708; // π/2

    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
      0,
      sweep,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerRadius * 2,
        0,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      sweep,
      sweep,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerRadius * 2,
        size.height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      sweep * 2,
      sweep,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        0,
        size.height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      sweep * 3,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

/// Vinheta: overlay escuro nas bordas simulando iluminação de estádio.
class VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.88,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.28),
      ],
      stops: const [0.5, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
