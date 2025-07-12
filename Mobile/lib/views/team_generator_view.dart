import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/helpers/team_generator.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/views/teams_display_view.dart';
import 'package:provider/provider.dart';

class TeamGenerationScreen extends StatefulWidget {
  final Group? preselectedGroup;

  const TeamGenerationScreen({super.key, this.preselectedGroup});

  @override
  State<TeamGenerationScreen> createState() => _TeamGenerationScreenState();
}

class _TeamGenerationScreenState extends State<TeamGenerationScreen> {
  final int _minTeams = 2;
  final int _maxTeams = 10;

  bool _isLoading = false;
  int _numberOfTeams = 2;

  late Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.preselectedGroup;
  }

  void _generateTeams() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    var players = await context.read<PlayerController>().getAllByGroupId(
      context,
      widget.preselectedGroup!.id,
    );

    players = players.where((p) => !p.reserva).toList();

    if (players.length < _numberOfTeams) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há jogadores suficientes para gerar os times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var captainsCount = players.where((p) => p.ehCapitao).toList().length;

    if (captainsCount > 0 && captainsCount != _numberOfTeams) {
      Toast.show(
        context,
        'O número de capitães deve ser o mesmo do número de times!',
        true,
        duration: 5,
      );

      setState(() {
        _isLoading = false;
      });
      return;
    }

    var teamsGenerator = TeamGenerator(
      algorithm:
          context
              .read<ConfigurationsController>()
              .configuration
              .generationAlgorithm,
      players: players,
      group: _selectedGroup,
      numberOfTeams: _numberOfTeams,
    );

    var teams = teamsGenerator.generate();

    setState(() {
      _isLoading = false;
    });

    if (teams.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamsDisplayScreen(teams: teams),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao gerar times'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                      // Header
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

                      // Number of Teams
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

                              // Team number selection chips
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  _maxTeams - _minTeams + 1,
                                  (index) {
                                    final number = _minTeams + index;
                                    return ChoiceChip(
                                      label: Text('$number'),
                                      selected: _numberOfTeams == number,
                                      labelStyle: TextStyle(
                                        color:
                                            _numberOfTeams == number
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _numberOfTeams = number;
                                          });
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
                      // Generate Button
                      ElevatedButton.icon(
                        onPressed: _generateTeams,
                        icon: const Icon(Icons.shuffle),
                        label: Text(
                          'Sortear Times',
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
