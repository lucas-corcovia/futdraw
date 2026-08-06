// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/member_controller.dart';
import 'package:futdraw/models/enums/papel_membro.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/group_member.dart';
import 'package:futdraw/views/claim_player_view.dart';
import 'package:futdraw/views/invite_member_view.dart';
import 'package:provider/provider.dart';

class MembrosView extends StatefulWidget {
  final Group group;

  const MembrosView({super.key, required this.group});

  @override
  State<MembrosView> createState() => _MembrosViewState();
}

class _MembrosViewState extends State<MembrosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberController>().loadMembers(context, widget.group.id);
    });
  }

  bool get _canManage {
    final members = context.read<MemberController>().members;
    return members.any(
      (m) => m.papel == PapelMembro.dono || m.papel == PapelMembro.admin,
    );
  }

  Future<void> _showMemberOptions(BuildContext context, GroupMember member) async {
    if (member.papel == PapelMembro.dono) return;

    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: const Text('Alterar Papel'),
            onTap: () async {
              Navigator.pop(ctx);
              await _changePapel(member);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.red),
            title: const Text(
              'Remover Membro',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(ctx);
              await context
                  .read<MemberController>()
                  .remove(context, member.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _changePapel(GroupMember member) async {
    final novoPapel = await showDialog<PapelMembro>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Escolher Papel'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, PapelMembro.admin),
            child: const Text('Admin'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, PapelMembro.membro),
            child: const Text('Membro'),
          ),
        ],
      ),
    );
    if (novoPapel != null && mounted) {
      await context
          .read<MemberController>()
          .changePapel(context, member.id, novoPapel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Membros — ${widget.group.nome}')),
      body: Consumer<MemberController>(
        builder: (context, controller, _) {
          final members = controller.members;
          if (members.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () =>
                controller.loadMembers(context, widget.group.id),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _MemberCard(
                  member: member,
                  canManage: _canManage,
                  onOptions: _canManage
                      ? () => _showMemberOptions(context, member)
                      : null,
                  onClaimPlayer: member.jogadorId == null
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClaimPlayerView(
                              group: widget.group,
                              memberId: member.id,
                            ),
                          ),
                        ).then(
                          (_) => controller.loadMembers(
                            context,
                            widget.group.id,
                          ),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _canManage
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InviteMemberView(group: widget.group),
                ),
              ).then(
                (_) => context
                    .read<MemberController>()
                    .loadMembers(context, widget.group.id),
              ),
              tooltip: 'Convidar Membro',
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}

class _MemberCard extends StatelessWidget {
  final GroupMember member;
  final bool canManage;
  final VoidCallback? onOptions;
  final VoidCallback? onClaimPlayer;

  const _MemberCard({
    required this.member,
    required this.canManage,
    this.onOptions,
    this.onClaimPlayer,
  });

  Color _papelColor(PapelMembro papel) => switch (papel) {
    PapelMembro.dono => Colors.amber,
    PapelMembro.admin => Colors.blue,
    PapelMembro.membro => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _papelColor(member.papel);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            member.nome.isNotEmpty ? member.nome[0].toUpperCase() : '?',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(member.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email, style: Theme.of(context).textTheme.bodySmall),
            if (member.jogadorId == null)
              TextButton.icon(
                onPressed: onClaimPlayer,
                icon: const Icon(Icons.link, size: 14),
                label: const Text('Vincular ficha'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color),
              ),
              child: Text(
                member.papel.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onOptions != null)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onOptions,
              ),
          ],
        ),
      ),
    );
  }
}
