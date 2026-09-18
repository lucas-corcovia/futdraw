import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/player_row.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';

/// Ordem de leitura do elenco: do gol para o ataque, e alfabetica dentro de
/// cada setor.
///
/// O comparador anterior tentava so flutuar os goleiros para cima e devolvia
/// `1` para todo par que nao comecasse com goleiro -- nao era uma ordem total,
/// entao o resultado dependia do algoritmo de sort e nao agrupava nada.
int comparePlayersForRoster(Player a, Player b) {
  final byPosition = a.position.index.compareTo(b.position.index);
  if (byPosition != 0) return byPosition;
  return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
}

/// Altura livre no fim da lista para o FAB nao cobrir a ultima linha.
const double _fabClearance = 88;

abstract class PlayerList extends StatelessWidget {
  final Group group;
  final List<Player> players;
  final Future<void> Function(BuildContext) onRefresh;
  final void Function(Player) onEdit;
  final void Function(Player) onDelete;
  final void Function(Player)? onSwap;

  /// Bloco que abre a aba: contagem do elenco e as acoes do grupo. Rola junto
  /// com a lista em vez de ocupar a tela inteira o tempo todo.
  final Widget? header;

  /// Acao do estado vazio. Uma tela vazia sem proximo passo e um beco sem
  /// saida.
  final VoidCallback? onAdd;

  const PlayerList({
    super.key,
    required this.group,
    required this.players,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    this.onSwap,
    this.header,
    this.onAdd,
  });

  String get emptyTitle;
  String get emptyMessage;
  String? get emptyActionLabel => null;

  @override
  Widget build(BuildContext context) {
    final sorted = List<Player>.from(players)..sort(comparePlayersForRoster);

    return RefreshIndicator(
      onRefresh: () => onRefresh(context),
      child: CustomScrollView(
        slivers: [
          // Devolve ao corpo o espaco que a AppBar fixa absorveu; sem isto a
          // primeira linha nasce por baixo da barra.
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          if (header != null) SliverToBoxAdapter(child: header),
          if (sorted.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                title: emptyTitle,
                message: emptyMessage,
                actionLabel: emptyActionLabel,
                onAction: onAdd,
              ),
            )
          else
            SliverList.separated(
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final player = sorted[index];
                return PlayerRow(
                  player: player,
                  onEdit: () => onEdit(player),
                  onDelete: () => onDelete(player),
                  onSwap: onSwap,
                );
              },
              separatorBuilder: (context, _) => Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: context.scheme.outlineVariant,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: _fabClearance)),
        ],
      ),
    );
  }
}

class ReservasList extends PlayerList {
  const ReservasList({
    super.key,
    required super.group,
    required super.players,
    required super.onRefresh,
    required super.onEdit,
    required super.onDelete,
    super.onSwap,
    super.header,
    super.onAdd,
  });

  @override
  String get emptyTitle => 'Nenhum reserva';

  @override
  String get emptyMessage =>
      'Quem entra no banco aparece aqui. Marque um jogador como reserva na '
      'edição dele, ou substitua um titular.';
}

class TitularesList extends PlayerList {
  const TitularesList({
    super.key,
    required super.group,
    required super.players,
    required super.onRefresh,
    required super.onEdit,
    required super.onDelete,
    super.onSwap,
    super.header,
    super.onAdd,
  });

  @override
  String get emptyTitle => 'Nenhum titular ainda';

  @override
  String get emptyMessage =>
      'Adicione os jogadores do grupo para poder sortear os times.';

  @override
  String get emptyActionLabel => 'Adicionar jogador';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final texts = context.texts;

    // Acima do centro: centralizado de verdade, o bloco afunda longe demais do
    // cabecalho e a tela parece quebrada em vez de vazia.
    return Align(
      alignment: const Alignment(0, -0.35),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: texts.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: texts.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Esqueleto da lista enquanto o elenco chega da API.
///
/// Tem a forma da linha final de proposito: um spinner centralizado nao diz
/// nada sobre o que vem, e a troca dele pela lista e um salto.
class PlayerListSkeleton extends StatelessWidget {
  const PlayerListSkeleton({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    // Column, nao ListView: este widget vive dentro de um sliver, onde uma
    // lista rolavel nao tem altura definida.
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < rows; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacing.lg,
              endIndent: AppSpacing.lg,
              color: scheme.outlineVariant,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _Bone(width: 44, height: 44, radius: AppRadii.pill),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(width: 140, height: 14, radius: AppRadii.small),
                      SizedBox(height: AppSpacing.sm),
                      _Bone(width: 84, height: 18, radius: AppRadii.chip),
                    ],
                  ),
                ),
                _Bone(width: 34, height: 18, radius: AppRadii.small),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.scheme.surfaceContainerHighest,
      borderRadius: radius,
    ),
  );
}
