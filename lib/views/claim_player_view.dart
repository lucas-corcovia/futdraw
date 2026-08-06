// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/member_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:provider/provider.dart';

class ClaimPlayerView extends StatefulWidget {
  final Group group;
  final String memberId;

  const ClaimPlayerView({
    super.key,
    required this.group,
    required this.memberId,
  });

  @override
  State<ClaimPlayerView> createState() => _ClaimPlayerViewState();
}

class _ClaimPlayerViewState extends State<ClaimPlayerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PlayerController>()
          .getAllByGroupId(context, widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular Ficha')),
      body: Consumer<PlayerController>(
        builder: (context, playerController, _) {
          final available = playerController.players
              .where((p) => !p.reserva)
              .toList();

          if (available.isEmpty) {
            return const Center(
              child: Text('Nenhum jogador disponível para vinculação.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: available.length,
            itemBuilder: (context, index) {
              final player = available[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(player.nome),
                  subtitle: Text('Nota: ${player.nota}'),
                  trailing: const Icon(Icons.link),
                  onTap: () async {
                    final success =
                        await context.read<MemberController>().claimPlayer(
                          context,
                          widget.group.id,
                          player.id,
                        );
                    if (success && context.mounted) Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
