import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/player_avatar.dart';
import 'package:futdraw/components/widgets/position_chip.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/theme/app_typography.dart';

/// Um jogador numa linha.
///
/// Substitui o `PlayerCard`, que gastava ~156 dp e dois tiles rotulados para
/// mostrar dois campos -- cabiam quatro jogadores numa tela de elenco. A linha
/// mostra a mesma informacao em ~72 dp, e a posicao virou cor em vez de mais um
/// rotulo cinza.
///
/// Nao e um `Card`: itens homogeneos empilhados nao ganham nada com elevacao, e
/// a afordancia de toque quem da e o `InkWell`. A separacao entre linhas e um
/// hairline, desenhado pela lista.
class PlayerRow extends StatelessWidget {
  const PlayerRow({
    super.key,
    required this.player,
    required this.onEdit,
    required this.onDelete,
    this.onSwap,
    this.onTap,
    this.isSelected = false,
  });

  final Player player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Player)? onSwap;

  /// Toque na linha inteira. Sem isto, tocar abre a edicao -- que e o que a
  /// tela de elenco quer, mas nao o que a tela de substituicao quer.
  final VoidCallback? onTap;

  final bool isSelected;

  static const double _avatarSize = 44;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final texts = context.texts;

    return Material(
      color: isSelected ? scheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _Avatar(player: player, isSelected: isSelected),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: texts.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                        if (player.ehCapitao) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Tooltip(
                            message: 'Capitão',
                            child: Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: context.pitch.captainGold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Alinhado a esquerda e encolhido ao conteudo: um chip
                    // esticado ate a borda vira uma barra, e barra colorida por
                    // linha e ruido.
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PositionChip(position: player.position),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _Rating(nota: player.nota, isSelected: isSelected),
              const SizedBox(width: AppSpacing.xs),
              if (isSelected)
                Icon(Icons.check_circle, color: scheme.primary)
              else
                _RowMenu(
                  player: player,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onSwap: onSwap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player, required this.isSelected});

  final Player player;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ring = player.ehCapitao
        ? context.pitch.captainGold
        : isSelected
        ? context.scheme.primary
        : null;

    final avatar = PlayerAvatar(
      url: player.urlFoto,
      name: player.nome,
      size: PlayerRow._avatarSize,
    );

    return Hero(
      tag: 'player_avatar_${player.id}',
      child: ring == null
          ? avatar
          : Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 2),
              ),
              child: avatar,
            ),
    );
  }
}

/// A nota, sozinha.
///
/// Antes vinha colorida por faixa em `primary`/`secondary`/`tertiary`/`error`
/// -- quatro cores que agora disputariam atencao com as quatro cores de
/// posicao, na mesma linha. A hierarquia aqui e tamanho e peso, nao cor.
class _Rating extends StatelessWidget {
  const _Rating({required this.nota, required this.isSelected});

  final double nota;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return ConstrainedBox(
      // Largura minima, nao fixa: a Kanit nao tem algarismo tabular, entao sem
      // um piso o menu de tres pontos dancaria entre "9.5" e "10.0".
      constraints: const BoxConstraints(minWidth: 38),
      child: Text(
        nota.toStringAsFixed(1),
        textAlign: TextAlign.end,
        style: AppTypography.ratingValue.copyWith(
          color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
        ),
      ),
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({
    required this.player,
    required this.onEdit,
    required this.onDelete,
    required this.onSwap,
  });

  final Player player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Player)? onSwap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return PopupMenuButton<String>(
      tooltip: 'Opções de ${player.nome}',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'swap':
            onSwap?.call(player);
          case 'edit':
            onEdit();
          case 'delete':
            _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        // Substituir so existe entre os titulares: um reserva nao tem por quem
        // ser trocado.
        if (onSwap != null)
          const PopupMenuItem(
            value: 'swap',
            child: ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Substituir'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Editar'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text('Excluir', style: TextStyle(color: scheme.error)),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir jogador'),
        content: Text(
          '${player.nome} sai do grupo e perde o histórico de partidas. '
          'Não dá para desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDelete();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
