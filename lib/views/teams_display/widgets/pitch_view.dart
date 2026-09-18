import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/formation/formation.dart';
import 'package:futdraw/models/formation/formation_assignment.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/theme/app_typography.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_painters.dart';
import 'package:futdraw/views/teams_display/widgets/pitch_surface.dart';
import 'package:futdraw/views/teams_display/widgets/player_chip.dart';

/// O gramado com os jogadores nos slots da formacao.
///
/// Substitui o `SoccerField` anterior, que posicionava por aritmetica de
/// fileira (`fieldWidth / (count + 1)`) e portanto nao tinha formacao nenhuma:
/// o desenho saia de quantos jogadores calhavam de ter cada posicao.
class PitchView extends StatelessWidget {
  const PitchView({
    super.key,
    required this.formation,
    required this.assignment,
    required this.fieldType,
    required this.teamAccent,
    this.linesProgress = 1.0,
    this.chipsProgress = 1.0,
    this.selectedPlayerId,
    this.onPlayerTap,
    this.onPlayersSwapped,
    this.pitchKey,
    this.shaderEnabled = true,
    this.freePositioning = false,
    this.onSlotMoved,
  });

  final Formation formation;
  final SlotAssignment assignment;
  final FieldType fieldType;
  final Color teamAccent;

  /// Progresso do desenho das linhas, da coreografia de entrada.
  final double linesProgress;

  /// Progresso da chegada dos jogadores. Os chips ja sao tocaveis desde o
  /// primeiro frame: a coreografia realca um padrao ja visivel, nunca funciona
  /// como portao para o conteudo aparecer.
  final double chipsProgress;

  final String? selectedPlayerId;
  final void Function(Player player)? onPlayerTap;
  final void Function(Player a, Player b)? onPlayersSwapped;

  /// Campo destravado: o chip segue o dedo e fica onde soltar.
  ///
  /// Os dois modos existem porque **um gesto nao pode significar duas coisas**.
  /// Travado, segurar e arrastar troca dois jogadores -- que e a operacao do
  /// dia a dia. Destravado, arrastar move livre e a troca sai de cena. Sem
  /// essa separacao, soltar um chip perto de outro seria ambiguo justamente
  /// onde o alvo e menor: no meio de um campo cheio.
  final bool freePositioning;

  /// Chamado ao soltar o chip, com a posicao ja normalizada em `[0,1]`.
  ///
  /// So dispara no fim do arrasto. Durante o gesto o chip se move sozinho, sem
  /// avisar o pai: reconstruir o campo inteiro a cada frame do dedo derrubaria
  /// a taxa de quadros no unico lugar do app que tem shader ligado.
  final void Function(String slotId, Offset normalized)? onSlotMoved;

  /// Liga o shader da turfa. Desligado durante a captura do PNG, onde ele sai
  /// espelhado em parte dos Android (flutter/flutter#163521) e a imagem
  /// compartilhada precisa sair certa em todo aparelho.
  final bool shaderEnabled;

  /// Chave no `Stack` interno. Fica aqui para que a conversao de coordenadas
  /// do arrasto ande junto com qualquer transformacao aplicada por fora.
  final GlobalKey? pitchKey;

  @override
  Widget build(BuildContext context) {
    final pitch = context.pitch;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final metrics = _ChipMetrics.forFormation(formation, size);

        return Stack(
          key: pitchKey,
          clipBehavior: Clip.none,
          children: [
            // A superficie so repinta quando tema ou tamanho mudam. Sem este
            // RepaintBoundary, cada frame do escalonamento dos chips repintaria
            // a turfa inteira -- e a linha mais importante de performance
            // desta tela.
            Positioned.fill(
              child: RepaintBoundary(
                child: PitchSurface(theme: pitch, enabled: shaderEnabled),
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: PitchLinesPainter(
                    theme: pitch,
                    fieldType: fieldType,
                    progress: linesProgress,
                  ),
                ),
              ),
            ),
            ..._buildSlots(context, size, metrics),
          ],
        );
      },
    );
  }

  List<Widget> _buildSlots(
    BuildContext context,
    Size size,
    _ChipMetrics metrics,
  ) {
    final widgets = <Widget>[];
    final rows = formation.rows;

    for (final slot in formation.slots) {
      final position = formation.positionOf(slot);
      final player = assignment.playerAt(slot.id);

      final offset = metrics.topLeftFor(position, size);
      // Escalonamento por linha da formacao, da mais recuada para a frente.
      final rowIndex = rows.indexOf(slot.row);
      final reveal = _revealFor(rowIndex, rows.length);

      widgets.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: player == null
              ? _GhostSlot(
                  slot: slot,
                  metrics: metrics,
                  reveal: reveal,
                )
              : freePositioning
                  ? _FreeChip(
                      key: ValueKey('free-${slot.id}'),
                      player: player,
                      metrics: metrics,
                      teamAccent: teamAccent,
                      reveal: reveal,
                      isSelected: selectedPlayerId == player.id,
                      isOutOfPosition: assignment.isOutOfPosition(player),
                      origin: offset,
                      pitchSize: size,
                      onTap: onPlayerTap,
                      onMoved: onSlotMoved == null
                          ? null
                          : (normalized) => onSlotMoved!(slot.id, normalized),
                    )
                  : _SwappableChip(
                      player: player,
                      metrics: metrics,
                      teamAccent: teamAccent,
                      reveal: reveal,
                      isSelected: selectedPlayerId == player.id,
                      isOutOfPosition: assignment.isOutOfPosition(player),
                      onTap: onPlayerTap,
                      onSwap: onPlayersSwapped,
                    ),
        ),
      );
    }

    return widgets;
  }

  /// Cada linha entra 55 ms depois da anterior, dentro do progresso global.
  double _revealFor(int rowIndex, int rowCount) {
    if (chipsProgress >= 1) return 1;
    if (rowCount <= 1) return chipsProgress;

    const window = 0.55;
    final step = (1 - window) / (rowCount - 1);
    final start = rowIndex * step;
    return ((chipsProgress - start) / window).clamp(0.0, 1.0);
  }
}

/// Tamanhos derivados das restricoes, nunca do modelo do aparelho.
class _ChipMetrics {
  const _ChipMetrics({
    required this.avatarSize,
    required this.labelWidth,
    required this.chipWidth,
    required this.chipHeight,
    required this.avatarZone,
  });

  final double avatarSize;
  final double labelWidth;
  final double chipWidth;
  final double chipHeight;

  /// Altura reservada ao avatar, que nunca e menor que o alvo de toque.
  final double avatarZone;

  static const double _minAvatar = 30;
  static const double _maxAvatar = 60;
  static const double _labelHeight = 20;

  static _ChipMetrics forFormation(Formation formation, Size size) {
    var busiest = 1;
    for (final row in formation.rows) {
      busiest = math.max(busiest, formation.slotsInRow(row).length);
    }

    final slotWidth = size.width / (busiest + 1);
    final avatar = (slotWidth * 0.62).clamp(_minAvatar, _maxAvatar);
    final avatarZone = math.max(avatar, kChipMinTapTarget);
    final label = math.max(slotWidth * 0.95, avatarZone);

    return _ChipMetrics(
      avatarSize: avatar,
      labelWidth: label,
      chipWidth: math.max(label, kChipMinTapTarget),
      chipHeight: avatarZone + AppSpacing.xxs + _labelHeight,
      avatarZone: avatarZone,
    );
  }

  /// Converte a posicao normalizada do slot (que e o **centro do avatar**) no
  /// canto superior esquerdo do chip, com clamp para a caixa inteira ficar
  /// dentro do gramado.
  ///
  /// O recuo mora aqui, e nao nas coordenadas do catalogo: e isso que mantem o
  /// mesmo catalogo valido em qualquer tamanho de tela.
  Offset topLeftFor(Offset normalized, Size size) {
    final left = normalized.dx * size.width - chipWidth / 2;
    final top = normalized.dy * size.height - avatarZone / 2;

    return Offset(
      left.clamp(0.0, math.max(0.0, size.width - chipWidth)),
      top.clamp(0.0, math.max(0.0, size.height - chipHeight)),
    );
  }
}

class _SwappableChip extends StatelessWidget {
  const _SwappableChip({
    required this.player,
    required this.metrics,
    required this.teamAccent,
    required this.reveal,
    required this.isSelected,
    required this.isOutOfPosition,
    this.onTap,
    this.onSwap,
  });

  final Player player;
  final _ChipMetrics metrics;
  final Color teamAccent;
  final double reveal;
  final bool isSelected;
  final bool isOutOfPosition;
  final void Function(Player player)? onTap;
  final void Function(Player a, Player b)? onSwap;

  @override
  Widget build(BuildContext context) {
    return _Reveal(
      progress: reveal,
      child: DragTarget<Player>(
        onWillAcceptWithDetails: (details) => details.data.id != player.id,
        onAcceptWithDetails: (details) {
          HapticFeedback.lightImpact();
          onSwap?.call(player, details.data);
        },
        builder: (context, candidates, rejected) {
          final chip = PlayerChip(
            player: player,
            avatarSize: metrics.avatarSize,
            labelWidth: metrics.labelWidth,
            teamAccent: teamAccent,
            isSelected: isSelected,
            isDropTarget: candidates.isNotEmpty,
            isOutOfPosition: isOutOfPosition,
          );

          return LongPressDraggable<Player>(
            data: player,
            delay: const Duration(milliseconds: 250),
            onDragStarted: HapticFeedback.mediumImpact,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.15,
                child: PlayerChip(
                  player: player,
                  avatarSize: metrics.avatarSize,
                  labelWidth: metrics.labelWidth,
                  teamAccent: teamAccent,
                  isSelected: true,
                ),
              ),
            ),
            childWhenDragging: PlayerChip(
              player: player,
              avatarSize: metrics.avatarSize,
              labelWidth: metrics.labelWidth,
              teamAccent: teamAccent,
              opacity: 0.3,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap!(player),
              child: chip,
            ),
          );
        },
      ),
    );
  }
}

/// Chip do campo destravado: segue o dedo e fica onde soltar.
///
/// E `Stateful` por um motivo de performance, nao de arquitetura. O
/// deslocamento do dedo vive aqui dentro, entao arrastar repinta **um chip**.
/// Se a posicao morasse no `State` da tela, cada frame do gesto reconstruiria
/// a formacao inteira e repintaria a turfa com shader junto.
class _FreeChip extends StatefulWidget {
  const _FreeChip({
    super.key,
    required this.player,
    required this.metrics,
    required this.teamAccent,
    required this.reveal,
    required this.isSelected,
    required this.isOutOfPosition,
    required this.origin,
    required this.pitchSize,
    this.onTap,
    this.onMoved,
  });

  final Player player;
  final _ChipMetrics metrics;
  final Color teamAccent;
  final double reveal;
  final bool isSelected;
  final bool isOutOfPosition;

  /// Canto superior esquerdo do chip, em pixels, antes do arrasto.
  final Offset origin;
  final Size pitchSize;
  final void Function(Player player)? onTap;
  final void Function(Offset normalized)? onMoved;

  @override
  State<_FreeChip> createState() => _FreeChipState();
}

class _FreeChipState extends State<_FreeChip> {
  Offset _drag = Offset.zero;
  bool _dragging = false;

  @override
  void didUpdateWidget(_FreeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // O pai ja gravou o override e recalculou `origin`; segurar o
    // deslocamento antigo aqui somaria o mesmo arrasto duas vezes.
    if (!_dragging && widget.origin != oldWidget.origin) {
      _drag = Offset.zero;
    }
  }

  void _onEnd() {
    final m = widget.metrics;
    final size = widget.pitchSize;
    final moved = widget.origin + _drag;

    // De volta ao contrato do catalogo: a coordenada guardada e o **centro do
    // avatar**, nao o canto do chip. O clamp mantem o chip inteiro dentro do
    // gramado em qualquer tela, que e a mesma regra de `topLeftFor`.
    final left = moved.dx.clamp(0.0, math.max(0.0, size.width - m.chipWidth));
    final top = moved.dy.clamp(0.0, math.max(0.0, size.height - m.chipHeight));

    final normalized = Offset(
      size.width == 0 ? 0.5 : (left + m.chipWidth / 2) / size.width,
      size.height == 0 ? 0.5 : (top + m.avatarZone / 2) / size.height,
    );

    setState(() => _dragging = false);
    HapticFeedback.selectionClick();
    widget.onMoved?.call(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final chip = PlayerChip(
      player: widget.player,
      avatarSize: widget.metrics.avatarSize,
      labelWidth: widget.metrics.labelWidth,
      teamAccent: widget.teamAccent,
      isSelected: widget.isSelected || _dragging,
      isOutOfPosition: widget.isOutOfPosition,
    );

    return Transform.translate(
      offset: _drag,
      child: _Reveal(
        progress: widget.reveal,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap == null
              ? null
              : () => widget.onTap!(widget.player),
          onPanStart: (_) {
            setState(() => _dragging = true);
            HapticFeedback.selectionClick();
          },
          onPanUpdate: (details) => setState(() => _drag += details.delta),
          onPanEnd: (_) => _onEnd(),
          onPanCancel: () => setState(() {
            _dragging = false;
            _drag = Offset.zero;
          }),
          // Cresce de leve enquanto viaja: o chip que o dedo carrega precisa
          // ler como "acima" do campo, nao como parte dele.
          child: AnimatedScale(
            scale: _dragging ? 1.12 : 1.0,
            duration: AppMotion.fast,
            curve: Curves.easeOutCubic,
            child: chip,
          ),
        ),
      ),
    );
  }
}

/// Slot que o elenco nao preencheu.
///
/// Fica visivel de proposito: e mais honesto mostrar que a formacao nao coube
/// do que promover alguem em silencio para tapar o buraco.
class _GhostSlot extends StatelessWidget {
  const _GhostSlot({
    required this.slot,
    required this.metrics,
    required this.reveal,
  });

  final FormationSlot slot;
  final _ChipMetrics metrics;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    final pitch = context.pitch;

    return _Reveal(
      progress: reveal,
      child: SizedBox(
        width: metrics.chipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: metrics.avatarZone,
              height: metrics.avatarZone,
              child: Center(
                child: Container(
                  width: metrics.avatarSize,
                  height: metrics.avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: pitch.chipGhost,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: metrics.avatarSize * 0.5,
                    color: pitch.chipGhost,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              _label(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.pitchChipName.copyWith(
                color: pitch.chipGhost,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label() => slot.role == PlayerPosition.goalkeeper
      ? 'SEM GOLEIRO'
      : 'VAGO';
}

/// Entrada do chip: sobe alguns px e cresce de 0,92 para 1.
///
/// Nunca parte do nada -- nada no mundo real aparece de escala zero.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress >= 1) return child;

    final eased = AppMotion.entering.transform(progress.clamp(0.0, 1.0));
    return Opacity(
      opacity: eased,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - eased)),
        child: Transform.scale(scale: 0.92 + 0.08 * eased, child: child),
      ),
    );
  }
}
