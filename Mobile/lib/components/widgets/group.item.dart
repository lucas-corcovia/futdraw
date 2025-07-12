import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futdraw/components/modal.dart';
import 'package:futdraw/components/widgets/add.group.dart';
import 'package:futdraw/components/widgets/add.many.players.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/consts/app.colors.dart' show CommonsColors;
import 'package:futdraw/models/enums/player.position.dart';
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
    var isProduction = bool.fromEnvironment('dart.vm.product');
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
              Row(
                children: [
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
                    child:
                        group.avatarPath != null
                            ? ClipOval(
                              child: Image.memory(
                                base64Decode(group.avatarPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.group,
                                    size: 30,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  );
                                },
                              ),
                            )
                            : Icon(
                              Icons.group,
                              size: 30,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.nome,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              group.fieldType.icon,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              group.fieldType.displayName,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.sports_soccer,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Gerar Times'),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TeamGenerationScreen(
                                        preselectedGroup: group,
                                      ),
                                ),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.person_add,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Adicionar Jogador'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPlayer(group: group),
                                  ),
                                ).then(
                                  (_) async =>
                                      await context
                                          .read<GroupController>()
                                          .getAll(),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.group_add,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Adicionar Vários'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            AddManyPlayers(groupId: group.id),
                                  ),
                                ).then(
                                  (_) async =>
                                      await context
                                          .read<GroupController>()
                                          .getAll(),
                                );
                              },
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.edit),
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
                                    await context
                                        .read<GroupController>()
                                        .getAll(),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.delete,
                                color: CommonsColors.deleteColor,
                              ),
                              title: Text('Excluir Grupo'),
                            ),
                            onTap: () async {
                              await context.read<GroupController>().delete(
                                group.id,
                              );
                            },
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.copy_all),
                              title: const Text(
                                'Copiar jogadores para área de transferência',
                              ),
                            ),
                            onTap: () async {
                              await context
                                  .read<PlayerController>()
                                  .copyPlayersToClipboard(context);
                            },
                          ),
                          if (!isProduction)
                            PopupMenuItem(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.data_object),
                                title: const Text(
                                  'Exportar JSON dos jogadores',
                                ),
                              ),
                              onTap: () async {
                                await context
                                    .read<PlayerController>()
                                    .exportPlayersToJson(context, group.id);
                              },
                            ),
                          if (!isProduction)
                            PopupMenuItem(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.data_object),
                                title: const Text(
                                  'Importar JSON dos jogadores',
                                ),
                              ),
                              onTap: () async {
                                await _showImportModal(context);
                              },
                            ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                runSpacing: 10,
                children: [
                  _buildStatChip(
                    context,
                    Icons.people,
                    '${group.totalPlayersCount}',
                    'Total',
                    Colors.blue,
                  ),
                  if (group.playersCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      context,
                      Icons.shield,
                      '${group.playersCount}',
                      'Titulares',
                      Colors.green,
                    ),
                  ],
                  if (group.substituteCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      context,
                      Icons.person_outline,
                      '${group.substituteCount}',
                      'Reservas',
                      Colors.orange,
                    ),
                  ],
                  if (group.goalkeppersCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      context,
                      PlayerPosition.goalkeeper.icon,
                      '${group.goalkeppersCount}',
                      'Goleiros',
                      Colors.purple,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
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
                      proximoJogo(
                        gameTime: group.gameTime,
                        gameDays: group.gameDays,
                      ),
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
              if (group.defaultLocation != null) ...[
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
                        group.defaultLocation!,
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
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${group.gameTimeMinutes}",
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
                    '${group.playersPerTeam} por time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  if (group.fixedGoalkeepers) ...[
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

  _showImportModal(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) =>
              CustomModal(titulo: 'JSON', content: _modalImport(context)),
    );
  }

  Widget _modalImport(BuildContext context) {
    var jsonString = '';
    return Column(
      children: [
        TextFormField(
          controller: TextEditingController(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          minLines: 5,
          maxLines: 10,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Insira o JSON dos jogadores.';
            }

            return null;
          },
          onChanged: (value) => jsonString = value,
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<PlayerController>().importPlayersToJson(
                    context,
                    jsonString,
                    group.id,
                  );

                  context.read<GroupController>().getAll().then((_) {
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  'Importar Jogadores',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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

  String proximoJogo({
    required TimeOfDay gameTime,
    required List<int> gameDays,
    DateTime? now,
  }) {
    now ??= DateTime.now();

    for (int i = 0; i < 7; i++) {
      final dia = now.add(Duration(days: i));

      if (!gameDays.contains(dia.weekday)) continue;

      final horaDoJogo = DateTime(
        dia.year,
        dia.month,
        dia.day,
        gameTime.hour,
        gameTime.minute,
      );

      final hoje =
          now.year == dia.year && now.month == dia.month && now.day == dia.day;

      final horaFormatada = formatTimeOfDay(gameTime);

      if (hoje && horaDoJogo.isAfter(now)) {
        return 'Hoje às $horaFormatada';
      }

      if (!hoje) {
        final nomeDiaSemana = nomeDoDia(dia.weekday);
        final dataFormatada =
            '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}';

        return '$nomeDiaSemana, $dataFormatada às $horaFormatada';
      }
    }

    return 'Sem jogo marcado';
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String nomeDoDia(int weekday) {
    const dias = [
      'Domingo',
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
    ];
    return dias[weekday % 7];
  }
}
