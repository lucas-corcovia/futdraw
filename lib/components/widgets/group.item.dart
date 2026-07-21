// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.group.dart';
import 'package:futdraw/components/widgets/add.many.players.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/views/player.list.view.dart';
import 'package:futdraw/views/team_generator_view.dart';
import 'package:provider/provider.dart';

class GroupItem extends StatelessWidget {
  const GroupItem({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final fieldType = group.tipoCampo.toFieldType();
    final scheduleText = _buildScheduleText();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com avatar e info básica
              Row(
                children: [
                  // Avatar do grupo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: group.urlAvatar != null && group.urlAvatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              group.urlAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.group,
                                size: 30,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.group,
                            size: 30,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Nome e tipo de campo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.nome,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getFieldTypeIcon(fieldType),
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fieldType.displayName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu de opções
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddGroup(group: group)),
                          );
                        case 'delete':
                          _confirmDelete(context);
                        case 'generate':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeamGenerationScreen(preselectedGroup: group),
                            ),
                          );
                        case 'addPlayer':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddPlayer(group: group)),
                          );
                        case 'addMultiple':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddManyPlayers(groupId: group.id),
                            ),
                          );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
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
                      PopupMenuItem(
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
                      PopupMenuItem(
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
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.edit),
                          title: const Text('Editar Grupo'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            'Excluir Grupo',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Chips de estatísticas
              Wrap(
                runSpacing: 10,
                children: [
                  _buildStatChip(
                    context,
                    Icons.people,
                    '${group.playerCount}',
                    'Total',
                    Theme.of(context).colorScheme.primary,
                  ),
                  if (group.captainCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      context,
                      Icons.star,
                      '${group.captainCount}',
                      'Capitães',
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.sports,
                    '${group.limiteTitulares}',
                    'Lim. Tit.',
                    Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Próximo jogo (dias + horário)
              if (scheduleText.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scheduleText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Local padrão
              if (group.localPadrao != null && group.localPadrao!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        group.localPadrao!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Configurações do jogo
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.duracaoJogoMinutos} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.people_alt,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.jogadoresPorTime} por time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  if (group.goleirosFixos) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Goleiros fixos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildScheduleText() {
    final days = group.diasDeJogo.isEmpty ? '' : group.diasDeJogo.join(', ');
    final time = group.horarioJogo ?? '';
    if (days.isEmpty && time.isEmpty) return '';
    if (days.isEmpty) return time;
    if (time.isEmpty) return days;
    return '$days ás $time';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: Text('Deseja excluir o grupo "${group.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<GroupController>().delete(context, group.id);
    }
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  IconData _getFieldTypeIcon(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.quadra:
        return Icons.crop_square;
      case FieldType.campo:
        return Icons.grass;
      case FieldType.society:
        return Icons.sports_soccer;
      case FieldType.livre:
        return Icons.settings;
    }
  }
}
