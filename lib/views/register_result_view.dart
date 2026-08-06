// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/result_controller.dart';
import 'package:futdraw/data/models/requests/result_request.dart';
import 'package:futdraw/models/match.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class RegisterResultView extends StatefulWidget {
  final Match match;
  final String grupoId;
  final int numberOfTeams;

  const RegisterResultView({
    super.key,
    required this.match,
    required this.grupoId,
    this.numberOfTeams = 2,
  });

  @override
  State<RegisterResultView> createState() => _RegisterResultViewState();
}

class _RegisterResultViewState extends State<RegisterResultView> {
  late List<TextEditingController> _golsControllers;

  @override
  void initState() {
    super.initState();
    _golsControllers = List.generate(
      widget.numberOfTeams,
      (_) => TextEditingController(text: '0'),
    );
  }

  @override
  void dispose() {
    for (final c in _golsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final placares = _golsControllers.asMap().entries.map((entry) {
      return ScoreDto(
        timeIndex: entry.key,
        gols: int.tryParse(entry.value.text) ?? 0,
      );
    }).toList();

    context.loaderOverlay.show();
    final success = await context.read<ResultController>().register(
      context,
      widget.match.id,
      ResultRequest(placares: placares),
    );
    context.loaderOverlay.hide();
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: const Color.fromRGBO(0, 0, 0, 0.6),
      child: Scaffold(
        appBar: AppBar(title: const Text('Registrar Resultado')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Salvar Resultado'),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Placar por Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.numberOfTeams, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Time ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _golsControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('gols'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
