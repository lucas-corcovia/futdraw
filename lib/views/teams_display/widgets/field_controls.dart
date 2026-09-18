import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/theme/app_typography.dart';

/// Cadeado do campo e a dica do gesto que vale agora.
///
/// **O cadeado nunca aparece sozinho.** Um glifo de cadeado nao diz se o que
/// se ve e o estado atual ou o que acontece ao tocar -- e a razao de DESIGN.md
/// exigir rotulo em icone que nao seja universal. Aqui o botao diz o estado
/// ("Travado" / "Livre") e a linha de baixo diz o gesto que ele habilita.
///
/// A dica muda junto porque os dois modos tem gestos diferentes: travado
/// troca jogadores, destravado move. Deixar a dica antiga de pe seria pior do
/// que nao ter dica.
class FieldControls extends StatelessWidget {
  const FieldControls({
    super.key,
    required this.freePositioning,
    required this.hasOverrides,
    required this.onToggleLock,
    required this.onReset,
  });

  final bool freePositioning;

  /// Ha posicao movida a mao neste time: so entao "Restaurar" faz sentido.
  final bool hasOverrides;
  final VoidCallback onToggleLock;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final pitch = context.pitch;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          freePositioning
              ? 'Arraste para posicionar livremente'
              : 'Arraste jogadores da mesma posição para trocar',
          textAlign: TextAlign.center,
          style: AppTypography.pitchHint.copyWith(
            color: pitch.chipOnSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GlassButton(
              icon: freePositioning
                  ? Icons.lock_open_rounded
                  : Icons.lock_rounded,
              label: freePositioning ? 'Livre' : 'Travado',
              emphasised: freePositioning,
              onPressed: () {
                HapticFeedback.selectionClick();
                onToggleLock();
              },
            ),
            if (hasOverrides) ...[
              const SizedBox(width: AppSpacing.xs),
              _GlassButton(
                icon: Icons.restart_alt_rounded,
                label: 'Restaurar',
                onPressed: onReset,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Destravado e um estado que precisa se anunciar: o campo aceita arrasto
  /// destrutivo e o usuario tem que saber disso sem reler o rotulo.
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final pitch = context.pitch;
    final accent = Theme.of(context).colorScheme.primary;

    return Material(
      color: emphasised
          ? accent.withValues(alpha: 0.92)
          : pitch.scoreboardGlass,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.pill,
        side: BorderSide(
          color: emphasised ? accent : pitch.scoreboardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          // 48 dp de alvo, cravado e nao deduzido do padding: este botao fica
          // sobre o campo, onde errar o toque arrasta um jogador.
          constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: emphasised
                    ? Theme.of(context).colorScheme.onPrimary
                    : pitch.chipOnSurface,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: AppTypography.pitchHint.copyWith(
                  color: emphasised
                      ? Theme.of(context).colorScheme.onPrimary
                      : pitch.chipOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
