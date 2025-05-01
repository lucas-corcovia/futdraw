import 'package:flutter/material.dart';
import 'package:futdraw/models/group.dart';

class GroupItem extends StatelessWidget {
  const GroupItem({
    super.key,
    required this.groupPlayers,
    required this.group,
    required this.captainCount,
  });

  final List groupPlayers;
  final Group group;
  final int captainCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                radius: 24,
                child: Text(
                  '${groupPlayers.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.nome ?? 'Grupo ${group.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${groupPlayers.length} jogadores • $captainCount capitães',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onSelected: (String value) {
                  if (value == 'generate') {
                  } else if (value == 'addPlayer') {
                  } else if (value == 'addMultiple') {}
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'generate',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.sports_soccer,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Gerar Times'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'addPlayer',

                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.person_add,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          title: const Text('Adicionar Jogador'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'addMultiple',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.group_add,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          title: const Text('Adicionar Vários'),
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
