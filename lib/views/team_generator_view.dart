import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/data/models/requests/sortear_request.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/views/ai_team_sort_view.dart';
import 'package:futdraw/views/teams_display_view.dart';
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

  void _generateTeams() async {
    if (_isLoading) return;

    final grupoId = widget.preselectedGroup?.id;
    if (grupoId == null || grupoId.isEmpty) return;

    setState(() => _isLoading = true);

    final config = context.read<ConfigurationsController>().configuration;

    final result = await ServiceLocator().sorteioDataSource.sortear(
      grupoId,
      SortearRequest(
        numeroTimes: _numberOfTeams,
        algoritmo: config.generationAlgorithm.index,
        gerarIndependenteDaPosicao: config.gerarIndependenteDaPosicao,
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
                fieldType: widget.preselectedGroup?.tipoCampo.toFieldType() ?? FieldType.campo,
              ),
            ),
          );
        }
      },
      error: (message) => Toast.show(context, message, true, duration: 5),
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

                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: _generateTeams,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Sortear Times'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          final group = widget.preselectedGroup;
                          if (group == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AITeamSortView(group: group),
                            ),
                          );
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
