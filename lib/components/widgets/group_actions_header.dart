import 'package:flutter/material.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';

/// As tres acoes do grupo, com nome.
///
/// Antes eram tres icones sem rotulo espremidos na AppBar, entre outros dois:
/// uma bola, um calendario e um grafico de barras nao dizem "sortear times",
/// "partidas" e "ranking" para quem abre o app pela primeira vez. Icone sozinho
/// so se sustenta quando o glifo e universal, o que nao e o caso de nenhum dos
/// tres.
class GroupActionsHeader extends StatelessWidget {
  const GroupActionsHeader({
    super.key,
    required this.titulares,
    required this.reservas,
    required this.onSortear,
    required this.onPartidas,
    required this.onRanking,
  });

  final int titulares;
  final int reservas;
  final VoidCallback onSortear;
  final VoidCallback onPartidas;
  final VoidCallback onRanking;

  @override
  Widget build(BuildContext context) {
    final texts = context.texts;
    final scheme = context.scheme;

    final actions = <_Action>[
      _Action(Icons.sports_soccer, 'Sortear', onSortear),
      _Action(Icons.calendar_month_outlined, 'Partidas', onPartidas),
      _Action(Icons.leaderboard_outlined, 'Ranking', onRanking),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _summary,
            style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              // Tres rotulos lado a lado so cabem com largura e escala de texto
              // normais. Fora disso empilham, em vez de truncar "Partidas".
              final scaled = MediaQuery.textScalerOf(context).scale(14);
              final fits = constraints.maxWidth >= 330 && scaled <= 16.5;

              if (fits) {
                return Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _ActionButton(action: actions[i])),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: _ActionButton(action: actions[i]),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String get _summary {
    final jogadores = '$titulares ${titulares == 1 ? 'titular' : 'titulares'}';
    final banco = '$reservas ${reservas == 1 ? 'reserva' : 'reservas'}';
    return '$jogadores · $banco';
  }
}

class _Action {
  const _Action(this.icon, this.label, this.onPressed);
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: action.onPressed,
      icon: Icon(action.icon, size: 18),
      label: Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
