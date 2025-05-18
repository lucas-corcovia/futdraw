import 'package:flutter/material.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:provider/provider.dart';

class AddManyPlayers extends StatefulWidget {
  final int groupId;
  const AddManyPlayers({super.key, required this.groupId});

  @override
  State<AddManyPlayers> createState() => _AddManyPlayersState();
}

class _AddManyPlayersState extends State<AddManyPlayers> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namesController = TextEditingController();
  PlayerPosition _position = PlayerPosition.midfielder;
  double _skillRating = 5.0;
  bool _addAsReserve = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Vários Jogadores'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Digite um nome por linha:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: namesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nomes dos jogadores',
                  ),
                  minLines: 5,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite pelo menos um nome.';
                    }
                    final names =
                        value
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                    if (names.isEmpty) {
                      return 'Digite pelo menos um nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PlayerPosition>(
                  value: _position,
                  decoration: const InputDecoration(
                    labelText: 'Posição',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PlayerPosition.goalkeeper,
                      child: Text('Goleiro'),
                    ),
                    DropdownMenuItem(
                      value: PlayerPosition.defender,
                      child: Text('Defensor'),
                    ),
                    DropdownMenuItem(
                      value: PlayerPosition.midfielder,
                      child: Text('Meio-Campo'),
                    ),
                    DropdownMenuItem(
                      value: PlayerPosition.striker,
                      child: Text('Atacante'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _position = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habilidade: ${_skillRating.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        thumbColor: Theme.of(context).colorScheme.secondary,
                        trackHeight: 8.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20.0,
                        ),
                      ),
                      child: Slider(
                        min: 1.0,
                        max: 10.0,
                        divisions: 18,
                        value: _skillRating,
                        label: _skillRating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _skillRating = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '10.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Reserva'),
                  subtitle: const Text(
                    'Estes jogadores ficarão no banco de reservas',
                  ),
                  activeColor: Theme.of(context).colorScheme.tertiary,
                  value: _addAsReserve,
                  onChanged: (value) {
                    setState(() {
                      _addAsReserve = value;
                    });
                  },
                  secondary: Icon(
                    Icons.chair_rounded,
                    color:
                        _addAsReserve
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveManyPlayers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Adicionar Todos',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveManyPlayers() async {
    if (!_formKey.currentState!.validate()) return;
    final names =
        namesController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    if (names.isEmpty) return;
    final players =
        names
            .map(
              (name) => Player(
                id: 0,
                grupoId: widget.groupId,
                nome: name,
                nota: _skillRating,
                ehCapitao: false,
                reserva: _addAsReserve,
                urlFoto: null,
                position: _position,
              ),
            )
            .toList();
    await context.read<PlayerController>().addMany(
      context,
      players,
      widget.groupId,
    );
    Navigator.pop(context);
  }
}
