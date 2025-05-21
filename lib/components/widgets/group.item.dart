import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.group.dart';
import 'package:futdraw/components/widgets/add.many.players.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/views/player.list.view.dart';
import 'package:provider/provider.dart';

class GroupItem extends StatelessWidget {
  const GroupItem({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerListScreen(group: group),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  '${group.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.nome,
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
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.person_add),
                          title: const Text('Adicionar Jogador'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddPlayer(group: group),
                            ),
                          ).then(
                            (_) async =>
                                await context.read<GroupController>().getAll(),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.person_add),
                          title: const Text('Adicionar Vários Jogadores'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddManyPlayers(groupId: group.id),
                            ),
                          ).then(
                            (_) async =>
                                await context.read<GroupController>().getAll(),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit),
                          title: const Text('Editar Grupo'),
                        ),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddGroup(group: group),
                            ),
                          ).then(
                            (_) async =>
                                await context.read<GroupController>().getAll(),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.delete),
                          title: const Text('Excluir Grupo'),
                        ),
                        onTap: () async {
                          await context.read<GroupController>().delete(
                            group.id,
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.sports_soccer),
                          title: const Text('Gerar Times'),
                        ),
                        onTap: () {},
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
