import 'package:flutter/material.dart';

class ListPlayersEmpty extends StatelessWidget {
  const ListPlayersEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.people_outline,
          size: 80,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Nenhum jogador neste grupo',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toque no botão + para adicionar jogadores',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
