// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/attendance_controller.dart';
import 'package:futdraw/controllers/match_controller.dart';
import 'package:futdraw/controllers/member_controller.dart';
import 'package:futdraw/controllers/result_controller.dart';
import 'package:futdraw/models/enums/papel_membro.dart';
import 'package:futdraw/models/enums/status_partida.dart';
import 'package:futdraw/models/enums/status_presenca.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/match.dart';
import 'package:futdraw/views/register_result_view.dart';
import 'package:futdraw/views/schedule_match_view.dart';
import 'package:futdraw/views/team_generator_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MatchDetailView extends StatefulWidget {
  final Match match;
  final Group group;

  const MatchDetailView({super.key, required this.match, required this.group});

  @override
  State<MatchDetailView> createState() => _MatchDetailViewState();
}

class _MatchDetailViewState extends State<MatchDetailView> {
  late Match _match;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<AttendanceController>()
          .loadPanel(context, _match.id);
      await context
          .read<ResultController>()
          .loadByPartida(context, _match.id);
    });
  }

  bool get _isOrganizer {
    final members = context.read<MemberController>().members;
    final myMember = members.where((m) => m.jogadorId != null).firstOrNull;
    if (myMember == null) {
      return members.any(
        (m) =>
            m.papel == PapelMembro.dono || m.papel == PapelMembro.admin,
      );
    }
    return myMember.papel == PapelMembro.dono ||
        myMember.papel == PapelMembro.admin;
  }

  Future<void> _showAttendanceSheet() async {
    final status = await showModalBottomSheet<StatusPresenca>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sua presença',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _AttendanceOption(
              icon: Icons.check_circle,
              color: Colors.green,
              label: 'Vou!',
              onTap: () => Navigator.pop(ctx, StatusPresenca.confirmado),
            ),
            const SizedBox(height: 8),
            _AttendanceOption(
              icon: Icons.cancel,
              color: Colors.red,
              label: 'Não vou',
              onTap: () => Navigator.pop(ctx, StatusPresenca.recusado),
            ),
            const SizedBox(height: 8),
            _AttendanceOption(
              icon: Icons.help,
              color: Colors.orange,
              label: 'Talvez',
              onTap: () => Navigator.pop(ctx, StatusPresenca.talvez),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (status != null && mounted) {
      final success = await context
          .read<AttendanceController>()
          .respond(context, _match.id, status);
      if (success) {
        await context
            .read<AttendanceController>()
            .loadPanel(context, _match.id);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir partida?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<MatchController>().delete(context, _match.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy • HH:mm', 'pt_BR');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(dateFormat.format(_match.dataHora)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleMatchView(
                  group: widget.group,
                  match: _match,
                ),
              ),
            ).then((_) async {
              final updated = await context
                  .read<MatchController>()
                  .repository
                  .getById(_match.id);
              if (updated.isSuccess && mounted) {
                setState(() => _match = updated.data!);
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(match: _match),
          const SizedBox(height: 16),
          _AttendanceSection(
            matchId: _match.id,
            onRespond: _showAttendanceSheet,
          ),
          const SizedBox(height: 16),
          Consumer<ResultController>(
            builder: (context, resultController, _) {
              final result = resultController.result;

              if (_match.status == StatusPartida.finalizada && result != null) {
                return _ResultSection(result: result);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isOrganizer &&
                      (_match.status == StatusPartida.agendada ||
                          _match.status == StatusPartida.confirmada))
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamGenerationScreen(
                            preselectedGroup: widget.group,
                            partidaId: _match.id,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Sortear Confirmados'),
                    ),
                  if (_isOrganizer &&
                      _match.status == StatusPartida.finalizada &&
                      result == null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterResultView(
                            match: _match,
                            grupoId: widget.group.id,
                          ),
                        ),
                      ).then((_) => resultController.loadByPartida(
                            context,
                            _match.id,
                          )),
                      icon: const Icon(Icons.scoreboard),
                      label: const Text('Registrar Resultado'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.primary,
                      ),
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
}

class _InfoCard extends StatelessWidget {
  final Match match;

  const _InfoCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(match.local ?? 'Local não definido'),
                const Spacer(),
                _StatusChip(status: match.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final StatusPartida status;

  const _StatusChip({required this.status});

  Color _color(BuildContext context) => switch (status) {
    StatusPartida.agendada => Colors.blue,
    StatusPartida.confirmada => Colors.lightGreen,
    StatusPartida.emAndamento => Colors.orange,
    StatusPartida.finalizada => Theme.of(context).colorScheme.primary,
    StatusPartida.cancelada => Theme.of(context).colorScheme.outline,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  final String matchId;
  final VoidCallback onRespond;

  const _AttendanceSection({required this.matchId, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceController>(
      builder: (context, controller, _) {
        final panel = controller.panel;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Presença',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onRespond,
                      child: const Text('Responder'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (panel == null)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Counter(
                        label: 'Sim',
                        count: panel.totalConfirmados,
                        color: Colors.green,
                      ),
                      _Counter(
                        label: 'Não',
                        count: panel.totalRecusados,
                        color: Colors.red,
                      ),
                      _Counter(
                        label: 'Talvez',
                        count: panel.totalTalvez,
                        color: Colors.orange,
                      ),
                      _Counter(
                        label: 'Pendente',
                        count: panel.totalPendentes,
                        color: Colors.grey,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _Counter({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final dynamic result;

  const _ResultSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...result.placares.map<Widget>(
              (placar) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('Time ${placar.timeIndex + 1}'),
                    const Spacer(),
                    Text(
                      '${placar.gols} gols',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(placar.resultado.label),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AttendanceOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
    );
  }
}
