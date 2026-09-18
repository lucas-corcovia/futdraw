import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/utils/extensions.dart';

/// A posicao do jogador, com tres sinais redundantes: cor, icone e nome.
///
/// Os tres existem porque nenhum sozinho serve a todo mundo. A cor e o unico
/// que funciona no canto do olho, varrendo uma lista de vinte linhas; o icone
/// sobrevive ao daltonismo; e o nome e o unico que nao precisa ser aprendido.
class PositionChip extends StatelessWidget {
  const PositionChip({super.key, required this.position, this.dense = false});

  final PlayerPosition position;

  /// Sem texto, so cor e icone. Para onde a largura e o limite de verdade,
  /// como dentro de um chip de jogador no campo.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tone = context.positions.toneFor(position);
    final texts = context.texts;

    return Semantics(
      label: 'Posição: ${position.displayName}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: tone.container,
          borderRadius: AppRadii.chip,
          border: Border.all(color: tone.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(position.icon, size: 13, color: tone.ink),
            if (!dense) ...[
              const SizedBox(width: AppSpacing.xs),
              // Flexible, nao Expanded: o chip encolhe para o texto e so cede
              // quando a linha aperta de verdade.
              Flexible(
                child: Text(
                  position.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.labelSmall?.copyWith(
                    color: tone.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
