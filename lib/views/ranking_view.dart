// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/components/widgets/pro_paywall_sheet.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/controllers/ranking_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/ranking_item.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

enum _PeriodoFiltro { mes, temporada, tudo }

class RankingView extends StatefulWidget {
  final Group group;

  const RankingView({super.key, required this.group});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  _PeriodoFiltro _filtro = _PeriodoFiltro.tudo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _exportCsv() async {
    final isPro = context.read<AuthController>().isPro;
    if (!isPro) {
      ProPaywallSheet.show(context);
      return;
    }

    final ranking = context.read<RankingController>().ranking;
    if (ranking.isEmpty) {
      Toast.show(context, 'Nenhum dado para exportar', true);
      return;
    }

    final buf = StringBuffer();
    buf.writeln('Posição,Nome,Jogos,Vitórias,Empates,Derrotas,Aproveitamento,Gols,Assistências,Saldo de Gols');
    for (var i = 0; i < ranking.length; i++) {
      final r = ranking[i];
      final aprov = (r.aproveitamento * 100).toStringAsFixed(1);
      buf.writeln('${i + 1},${r.nome},${r.jogos},${r.vitorias},${r.empates},${r.derrotas},$aprov%,${r.gols},${r.assistencias},${r.saldoGols}');
    }

    final dir = await getTemporaryDirectory();
    final periodo = _filtro == _PeriodoFiltro.temporada ? 'temporada' : _filtro == _PeriodoFiltro.mes ? 'mes' : 'tudo';
    final file = File('${dir.path}/ranking_${widget.group.nome}_$periodo.csv');
    await file.writeAsString(buf.toString());
    await OpenFile.open(file.path);
  }

  Future<void> _load() async {
    final now = DateTime.now();
    DateTime? desde;
    switch (_filtro) {
      case _PeriodoFiltro.mes:
        desde = DateTime(now.year, now.month, 1);
      case _PeriodoFiltro.temporada:
        desde = DateTime(now.year, 1, 1);
      case _PeriodoFiltro.tudo:
        desde = null;
    }
    await context
        .read<RankingController>()
        .loadRanking(context, widget.group.id, desde: desde);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking — ${widget.group.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Exportar CSV (Pro)',
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<_PeriodoFiltro>(
              segments: const [
                ButtonSegment(value: _PeriodoFiltro.mes, label: Text('Mês')),
                ButtonSegment(
                  value: _PeriodoFiltro.temporada,
                  label: Text('Temporada'),
                ),
                ButtonSegment(
                  value: _PeriodoFiltro.tudo,
                  label: Text('Tudo'),
                ),
              ],
              selected: {_filtro},
              onSelectionChanged: (selected) {
                setState(() => _filtro = selected.first);
                _load();
              },
            ),
          ),
          Expanded(
            child: Consumer<RankingController>(
              builder: (context, controller, _) {
                final ranking = controller.ranking;
                if (ranking.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma estatística disponível.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      final item = ranking[index];
                      return _RankingCard(
                        item: item,
                        position: index + 1,
                        onTap: () => _showPlayerStats(context, item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerStats(BuildContext context, RankingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PlayerStatsSheet(item: item),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final RankingItem item;
  final int position;
  final VoidCallback onTap;

  const _RankingCard({
    required this.item,
    required this.position,
    required this.onTap,
  });

  Widget _medalIcon(int pos) {
    if (pos == 1) return const Text('🥇', style: TextStyle(fontSize: 20));
    if (pos == 2) return const Text('🥈', style: TextStyle(fontSize: 20));
    if (pos == 3) return const Text('🥉', style: TextStyle(fontSize: 20));
    return Text(
      '$pos',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aprov = (item.aproveitamento * 100).toStringAsFixed(0);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(width: 32, child: Center(child: _medalIcon(position))),
        title: Text(item.nome),
        subtitle: Text(
          '${item.jogos} jogos  •  ${item.vitorias}V ${item.empates}E ${item.derrotas}D',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$aprov%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${item.gols}G ${item.assistencias}A',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerStatsSheet extends StatelessWidget {
  final RankingItem item;

  const _PlayerStatsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final aprov = (item.aproveitamento * 100).toStringAsFixed(1);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Text(
              item.nome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 20),
          _StatRow(label: 'Jogos', value: '${item.jogos}'),
          _StatRow(label: 'Vitórias', value: '${item.vitorias}'),
          _StatRow(label: 'Empates', value: '${item.empates}'),
          _StatRow(label: 'Derrotas', value: '${item.derrotas}'),
          _StatRow(label: 'Aproveitamento', value: '$aprov%'),
          _StatRow(label: 'Saldo de Gols', value: '${item.saldoGols}'),
          _StatRow(label: 'Gols', value: '${item.gols}'),
          _StatRow(label: 'Assistências', value: '${item.assistencias}'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
