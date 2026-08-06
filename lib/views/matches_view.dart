// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/match_controller.dart';
import 'package:futdraw/models/enums/status_partida.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/match.dart';
import 'package:futdraw/views/match_detail_view.dart';
import 'package:futdraw/views/schedule_match_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MatchesView extends StatefulWidget {
  final Group group;

  const MatchesView({super.key, required this.group});

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchController>().loadByGroup(context, widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Partidas — ${widget.group.nome}')),
      body: Consumer<MatchController>(
        builder: (context, controller, _) {
          final matches = controller.matches;
          if (matches.isEmpty) {
            return const Center(
              child: Text('Nenhuma partida agendada.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                controller.loadByGroup(context, widget.group.id),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return _MatchCard(
                  match: match,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchDetailView(
                        match: match,
                        group: widget.group,
                      ),
                    ),
                  ).then(
                    (_) => controller.loadByGroup(context, widget.group.id),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleMatchView(group: widget.group),
          ),
        ).then(
          (_) => context
              .read<MatchController>()
              .loadByGroup(context, widget.group.id),
        ),
        tooltip: 'Agendar Partida',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const _MatchCard({required this.match, required this.onTap});

  Color _statusColor(BuildContext context, StatusPartida status) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      StatusPartida.agendada => Colors.blue,
      StatusPartida.confirmada => Colors.lightGreen,
      StatusPartida.emAndamento => Colors.orange,
      StatusPartida.finalizada => scheme.primary,
      StatusPartida.cancelada => scheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd/MM/yyyy • HH:mm', 'pt_BR');
    final color = _statusColor(context, match.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          dateFormat.format(match.dataHora),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(match.local ?? 'Local não definido'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                match.status.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${match.totalConfirmados} confirmados',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
