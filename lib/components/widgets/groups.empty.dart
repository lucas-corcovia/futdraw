import 'package:flutter/material.dart';

class GroupsEmpty extends StatelessWidget {
  const GroupsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.group_work_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Nenhum grupo cadastrado',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Grupos são criados ao cadastrar jogadores',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
