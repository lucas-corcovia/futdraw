import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/data/models/requests/sortear_request.dart';
import 'package:futdraw/data/models/responses/match_response.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/components/widgets/pro_paywall_sheet.dart';
import 'package:futdraw/views/ai_team_sort_view.dart';
import 'package:futdraw/views/teams_display_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeamGenerationScreen extends StatefulWidget {
  final Group? preselectedGroup;
  final String? partidaId;

  const TeamGenerationScreen({
    super.key,
    this.preselectedGroup,
    this.partidaId,
  });

  @override
  State<TeamGenerationScreen> createState() => _TeamGenerationScreenState();
}

class _TeamGenerationScreenState extends State<TeamGenerationScreen> {
  final int _minTeams = 2;
  final int _maxTeams = 10;

  bool _isLoading = false;
  int _numberOfTeams = 2;

  // Confirmados filter
  bool _useOnlyConfirmados = false;
  bool _loadingPartidas = false;
  List<MatchResponse> _partidas = [];
  MatchResponse? _selectedPartida;
  List<String> _confirmadosIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.partidaId != null) {
      _useOnlyConfirmados = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadConfirmadosForPartida(widget.partidaId!));
    }
  }

  Future<void> _onConfirmadosToggled(bool value) async {
    setState(() {
      _useOnlyConfirmados = value;
      _selectedPartida = null;
      _confirmadosIds = [];
    });
    if (value) await _loadPartidas();
  }

  Future<void> _loadPartidas() async {
    final grupoId = widget.preselectedGroup?.id;
    if (grupoId == null) return;
    setState(() => _loadingPartidas = true);
    final result = await ServiceLocator().matchDataSource.getAll(grupoId);
    setState(() => _loadingPartidas = false);
    result.when(
      success: (list) {
        final upcoming = list
            .where((m) => m.status <= 1)
            .toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
        setState(() => _partidas = upcoming);
      },
      error: (_) {},
    );
  }

  Future<void> _loadConfirmadosForPartida(String partidaId) async {
    final result = await ServiceLocator().attendanceDataSource.getPanel(partidaId);
    result.when(
      success: (panel) {
        setState(() => _confirmadosIds = panel.confirmados.map((a) => a.jogadorId).toList());
      },
      error: (_) {},
    );
  }

  void _generateTeams() async {
    if (_isLoading) return;

    final grupoId = widget.preselectedGroup?.id;
    if (grupoId == null || grupoId.isEmpty) return;

    if (_useOnlyConfirmados && _selectedPartida == null && widget.partidaId == null) {
      Toast.show(context, 'Selecione uma partida para filtrar os confirmados', true);
      return;
    }

    setState(() => _isLoading = true);

    final config = context.read<ConfigurationsController>().configuration;

    final result = await ServiceLocator().sorteioDataSource.sortear(
      grupoId,
      SortearRequest(
        numeroTimes: _numberOfTeams,
        algoritmo: config.generationAlgorithm.index,
        gerarIndependenteDaPosicao: config.gerarIndependenteDaPosicao,
        jogadorIds: (_useOnlyConfirmados && _confirmadosIds.isNotEmpty) ? _confirmadosIds : null,
      ),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.when(
      success: (teams) {
        if (teams.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamsDisplayScreen(
                teams: teams,
                grupoId: grupoId,
                fieldType: widget.preselectedGroup?.tipoCampo.toFieldType() ?? FieldType.campo,
              ),
            ),
          );
        }
      },
      error: (message) => Toast.show(context, message, true, duration: 5),
    );
  }

  Widget _buildConfirmadosCard() {
    final fmt = DateFormat('dd/MM HH:mm');
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Usar apenas confirmados'),
              subtitle: const Text('Sortear só com quem confirmou presença'),
              value: _useOnlyConfirmados,
              onChanged: widget.preselectedGroup != null ? _onConfirmadosToggled : null,
            ),
            if (_useOnlyConfirmados && widget.partidaId == null) ...[
              const Divider(height: 1),
              const SizedBox(height: 8),
              if (_loadingPartidas)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_partidas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nenhuma partida agendada encontrada.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              else
                DropdownButtonFormField<MatchResponse>(
                  value: _selectedPartida,
                  decoration: const InputDecoration(
                    labelText: 'Partida',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: _partidas.map((m) {
                    final label = fmt.format(m.dataHora.toLocal()) +
                        (m.local != null ? ' · ${m.local}' : '') +
                        ' (${m.totalConfirmados} conf.)';
                    return DropdownMenuItem(value: m, child: Text(label, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: (m) {
                    setState(() {
                      _selectedPartida = m;
                      _confirmadosIds = [];
                    });
                    if (m != null) _loadConfirmadosForPartida(m.partidaId);
                  },
                ),
              if (_selectedPartida != null && _confirmadosIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_confirmadosIds.length} jogador(es) confirmado(s)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
            if (_useOnlyConfirmados && widget.partidaId != null && _confirmadosIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_confirmadosIds.length} confirmado(s) nesta partida',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerar Times')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sports_soccer,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Configure o Sorteio',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'O algoritmo irá criar times equilibrados baseados nas habilidades dos jogadores',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Número de Times: $_numberOfTeams',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 8.0,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 12.0,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20.0,
                                  ),
                                ),
                                child: Slider(
                                  min: _minTeams.toDouble(),
                                  max: _maxTeams.toDouble(),
                                  divisions: _maxTeams - _minTeams,
                                  value: _numberOfTeams.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      _numberOfTeams = value.toInt();
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$_minTeams',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '$_maxTeams',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  _maxTeams - _minTeams + 1,
                                  (index) {
                                    final number = _minTeams + index;
                                    final isSelected = _numberOfTeams == number;
                                    return ChoiceChip(
                                      label: Text('$number'),
                                      selected: isSelected,
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      checkmarkColor:
                                          Theme.of(context).colorScheme.onPrimary,
                                      labelStyle: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _numberOfTeams = number);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildConfirmadosCard(),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: _generateTeams,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Sortear Times'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final group = widget.preselectedGroup;
                          if (group == null) return;
                          final result = await Navigator.push<String?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AITeamSortView(group: group),
                            ),
                          );
                          // AITeamSortView returns an error string when limit is reached
                          if (result != null && result.contains('Limite') && mounted) {
                            ProPaywallSheet.show(context);
                          }
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                          'Sortear com IA',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
