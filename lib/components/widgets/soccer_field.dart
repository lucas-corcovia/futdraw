import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/models/consts/app.colors.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

// Configuração de layout por modalidade: posições Y e tamanho de avatar.
class _FieldLayout {
  final double gkY;
  final double defY;
  final double midY;
  final double fwdY;
  // null = calculado dinamicamente (usado para campo 11v11)
  final double? fixedAvatarSize;

  const _FieldLayout({
    required this.gkY,
    required this.defY,
    required this.midY,
    required this.fwdY,
    this.fixedAvatarSize,
  });
}

class SoccerField extends StatefulWidget {
  final List<Player> players;
  final Function(Player, Player) onPlayersSwapped;
  final FieldType fieldType;

  const SoccerField({
    super.key,
    required this.players,
    required this.onPlayersSwapped,
    this.fieldType = FieldType.campo,
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

  static const double _maxAvatarSize = 60.0;
  static const double _minAvatarSize = 34.0;
  static const double _feedbackScale = 1.25;

  // Layout por modalidade — posições Y e avatar fixo ou dinâmico.
  _FieldLayout _getLayout() {
    switch (widget.fieldType) {
      case FieldType.quadra:
        return const _FieldLayout(
          gkY: 0.88,
          defY: 0.62,
          midY: 0.36,
          fwdY: 0.13,
          fixedAvatarSize: 56,
        );
      case FieldType.society:
        return const _FieldLayout(
          gkY: 0.87,
          defY: 0.64,
          midY: 0.40,
          fwdY: 0.14,
          fixedAvatarSize: 52,
        );
      case FieldType.campo:
      case FieldType.livre:
        return const _FieldLayout(
          gkY: 0.86,
          defY: 0.65,
          midY: 0.40,
          fwdY: 0.15,
        );
    }
  }

  // Usado somente quando fixedAvatarSize == null (campo 11v11).
  double _computeDynamicAvatarSize(double fieldWidth) {
    final maxInRow = [
      _goalkeepers.length,
      _defenders.length,
      _midfielders.length,
      _forwards.length,
    ].reduce(math.max);

    if (maxInRow == 0) return _maxAvatarSize;
    final slotWidth = fieldWidth / (maxInRow + 1);
    return (slotWidth * 0.65).clamp(_minAvatarSize, _maxAvatarSize);
  }

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

        final layout = _getLayout();
        final avatarSize =
            layout.fixedAvatarSize ?? _computeDynamicAvatarSize(fieldWidth);
        final feedbackSize = avatarSize * _feedbackScale;

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
                    Color(0xFF2EC066),
                    Color(0xFF178A40),
                    Color(0xFF0A4F24),
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

            // Layer 3: Linhas do campo (variam por modalidade)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: switch (widget.fieldType) {
                  FieldType.quadra => QuadraFieldPainter(),
                  FieldType.society => SocietyFieldPainter(),
                  _ => CampoFieldPainter(),
                },
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
                      _initializeFreePositions(
                        fieldWidth,
                        fieldHeight,
                        avatarSize,
                        layout,
                      );
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
              ..._positionRow(
                _goalkeepers,
                fieldWidth,
                fieldHeight * layout.gkY,
                avatarSize,
              ),
            if (!isFreeEditMode)
              ..._positionRow(
                _defenders,
                fieldWidth,
                fieldHeight * layout.defY,
                avatarSize,
              ),
            if (!isFreeEditMode)
              ..._positionRow(
                _midfielders,
                fieldWidth,
                fieldHeight * layout.midY,
                avatarSize,
              ),
            if (!isFreeEditMode)
              ..._positionRow(
                _forwards,
                fieldWidth,
                fieldHeight * layout.fwdY,
                avatarSize,
              ),
            if (isFreeEditMode)
              ..._buildFreePlayers(fieldWidth, fieldHeight, avatarSize, feedbackSize),
          ],
        );
      },
    );
  }

  // Posiciona uma fileira de jogadores horizontalmente centrada.
  // Usa max(avatarSize, maxNameWidth)/2 como offset para evitar desalinhamento
  // quando o label do nome é mais largo que o avatar.
  List<Widget> _positionRow(
    List<Player> players,
    double fieldWidth,
    double yCenter,
    double avatarSize,
  ) {
    final int count = players.length;
    if (count == 0) return [];

    final double spacing = fieldWidth / (count + 1);
    final double maxNameWidth = spacing * 0.92;
    final double halfWidget = math.max(avatarSize, maxNameWidth) / 2;

    return List.generate(count, (i) {
      final double xCenter = spacing * (i + 1);
      return Positioned(
        left: xCenter - halfWidget,
        top: yCenter - avatarSize / 2,
        child: _buildSwappablePlayer(
          players[i],
          avatarSize,
          maxNameWidth: maxNameWidth,
        ),
      );
    });
  }

  Widget _buildSwappablePlayer(
    Player player,
    double avatarSize, {
    double? maxNameWidth,
  }) {
    return DragTarget<Player>(
      onWillAcceptWithDetails: (details) => details.data.id != player.id,
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
          feedback: _buildDragFeedback(player, avatarSize),
          childWhenDragging: _buildPlayerAvatar(
            player,
            avatarSize,
            opacity: 0.35,
            maxNameWidth: maxNameWidth,
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
              avatarSize,
              isHighlighted: isSelected || isTarget,
              maxNameWidth: maxNameWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragFeedback(Player player, double avatarSize) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: _feedbackScale,
        child: _buildPlayerAvatar(player, avatarSize, isHighlighted: true),
      ),
    );
  }

  void _initializeFreePositions(
    double width,
    double height,
    double avatarSize,
    _FieldLayout layout,
  ) {
    _freePositions.clear();

    void initRow(List<Player> players, double yFraction) {
      final spacing = width / (players.length + 1);
      for (int i = 0; i < players.length; i++) {
        _freePositions[players[i].id] = Offset(
          spacing * (i + 1),
          height * yFraction,
        );
      }
    }

    initRow(_goalkeepers, layout.gkY);
    initRow(_defenders, layout.defY);
    initRow(_midfielders, layout.midY);
    initRow(_forwards, layout.fwdY);
  }

  List<Widget> _buildFreePlayers(
    double width,
    double height,
    double avatarSize,
    double feedbackSize,
  ) {
    final half = avatarSize / 2;
    final feedbackHalf = feedbackSize / 2;

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
          feedback: _buildDragFeedback(player, avatarSize),
          childWhenDragging: _buildPlayerAvatar(
            player,
            avatarSize,
            opacity: 0.3,
          ),
          child: _buildPlayerAvatar(player, avatarSize),
          onDragEnd: (details) {
            final RenderBox? box =
                _fieldKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;

            final centerGlobal =
                details.offset + Offset(feedbackHalf, feedbackHalf);
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
    double? maxNameWidth,
  }) {
    final double containerWidth = math.max(size, maxNameWidth ?? size);

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: containerWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
// PAINTERS COMUNS
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

Paint _fieldLinePaint() =>
    Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

Paint _fieldDotPaint() =>
    Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

// ─────────────────────────────────────────────────────────────────────────────
// CAMPO (11v11) — marcações completas
// ─────────────────────────────────────────────────────────────────────────────
class CampoFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = _fieldLinePaint();
    final dotPaint = _fieldDotPaint();

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 8,
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.5, dotPaint);

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

    canvas.drawRect(
      Rect.fromLTWH(goalLeft, 0, goalWidth, goalHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(goalLeft, size.height - goalHeight, goalWidth, goalHeight),
      paint,
    );

    final penaltySpotTopY = penaltyHeight * 0.62;
    final penaltySpotBottomY = size.height - penaltySpotTopY;
    final penaltySpotX = size.width / 2;

    canvas.drawCircle(Offset(penaltySpotX, penaltySpotTopY), 4.0, dotPaint);
    canvas.drawCircle(Offset(penaltySpotX, penaltySpotBottomY), 4.0, dotPaint);

    final arcRadius = size.height * 0.12;

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, penaltyHeight, size.width, size.height - penaltyHeight),
    );
    canvas.drawCircle(Offset(penaltySpotX, penaltySpotTopY), arcRadius, paint);
    canvas.restore();

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    final cornerRadius = size.width * 0.05;
    const sweep = 1.5708;

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
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIETY (7v7) — áreas menores, sem arco "D", com cantos
// ─────────────────────────────────────────────────────────────────────────────
class SocietyFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = _fieldLinePaint();
    final dotPaint = _fieldDotPaint();

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 8,
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.5, dotPaint);

    final penaltyWidth = size.width * 0.40;
    final penaltyHeight = size.height * 0.18;
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

    final penaltySpotTopY = penaltyHeight * 0.65;
    final penaltySpotBottomY = size.height - penaltySpotTopY;
    final penaltySpotX = size.width / 2;

    canvas.drawCircle(Offset(penaltySpotX, penaltySpotTopY), 4.0, dotPaint);
    canvas.drawCircle(Offset(penaltySpotX, penaltySpotBottomY), 4.0, dotPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    final cornerRadius = size.width * 0.05;
    const sweep = 1.5708;

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
}

// ─────────────────────────────────────────────────────────────────────────────
// QUADRA / FUTSAL (5v5) — semicírculos de pênalti, sem arcos de canto,
//                          círculo central menor
// ─────────────────────────────────────────────────────────────────────────────
class QuadraFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = _fieldLinePaint();
    final dotPaint = _fieldDotPaint();

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 10,
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.5, dotPaint);

    final arcRadius = size.width * 0.22;
    final spotOffsetY = size.height * 0.08;
    final spotX = size.width / 2;

    canvas.drawCircle(Offset(spotX, spotOffsetY), 4.0, dotPaint);
    canvas.drawCircle(Offset(spotX, size.height - spotOffsetY), 4.0, dotPaint);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height / 2));
    canvas.drawCircle(Offset(spotX, 0), arcRadius, paint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
    );
    canvas.drawCircle(Offset(spotX, size.height), arcRadius, paint);
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
