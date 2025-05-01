import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/player.position.dart';

class AddManyPlayers extends StatefulWidget {
  const AddManyPlayers({super.key});

  @override
  State<AddManyPlayers> createState() => _AddManyPlayersState();
}

class _AddManyPlayersState extends State<AddManyPlayers> {
  final TextEditingController namesController = TextEditingController();
  final TextEditingController groupController = TextEditingController();

  PlayerPosition position = PlayerPosition.midfielder;
  double skillRating = 5.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Digite um nome por linha:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namesController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              minLines: 5,
              maxLines: 10,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: groupController,
              decoration: const InputDecoration(
                labelText: 'Grupo/Turma',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<PlayerPosition>(
              value: position,
              decoration: const InputDecoration(
                labelText: 'Posição',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: PlayerPosition.goalkeeper,
                  child: Text('Goleiro'),
                ),
                DropdownMenuItem(
                  value: PlayerPosition.defender,
                  child: Text('Defensor'),
                ),
                const DropdownMenuItem(
                  value: PlayerPosition.midfielder,
                  child: Text('Meio-Campo'),
                ),
                const DropdownMenuItem(
                  value: PlayerPosition.striker,
                  child: Text('Atacante'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    position = value;
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            Text(
              'Habilidade: ${skillRating.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              min: 1.0,
              max: 10.0,
              divisions: 18,
              value: skillRating,
              label: skillRating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  skillRating = value;
                });
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {},
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
