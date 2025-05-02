import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/models/enums/group.item.options.dart';
import 'package:futdraw/models/group.dart';
import 'package:provider/provider.dart';

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
                      '${group.playerCount} jogadores • ${group.captainCount} capitães',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<GroupItemOptions>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.primary,
                ),
                itemBuilder:
                    (BuildContext context) =>
                        <PopupMenuEntry<GroupItemOptions>>[
                          PopupMenuItem(
                            value: GroupItemOptions.generateTeam,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.sports_soccer,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Gerar Times'),
                            ),
                            onTap: () {},
                          ),
                          PopupMenuItem<GroupItemOptions>(
                            value: GroupItemOptions.addPlayer,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.person_add,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              title: const Text('Adicionar Jogador'),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPlayer(group: group),
                                ),
                              );
                            },
                          ),
                          PopupMenuItem(
                            value: GroupItemOptions.addMultiplePlayers,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.group_add,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              title: const Text('Adicionar Vários'),
                            ),
                          ),
                          PopupMenuItem(
                            value: GroupItemOptions.deleteGroup,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Excluir Grupo'),
                            ),
                            onTap: () async {
                              await context.read<GroupController>().delete(
                                group.id,
                              );
                            },
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
