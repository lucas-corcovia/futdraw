import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/data/models/requests/sortear_ia_request.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/views/teams_display_view.dart';

class AITeamSortView extends StatefulWidget {
  final Group group;

  const AITeamSortView({super.key, required this.group});

  @override
  State<AITeamSortView> createState() => _AITeamSortViewState();
}

class _AITeamSortViewState extends State<AITeamSortView> {
  static const int _minTeams = 2;
  static const int _maxTeams = 10;

  int _numberOfTeams = 2;
  final TextEditingController _instrucoesController = TextEditingController();

  @override
  void dispose() {
    _instrucoesController.dispose();
    super.dispose();
  }

  Future<void> _generateTeams() async {
    final grupoId = widget.group.id;
    if (grupoId.isEmpty) return;

    final instrucoes = _instrucoesController.text.trim();

    _showLoadingDialog();

    final result = await ServiceLocator().sorteioIADataSource.sortearIA(
      grupoId,
      SortearIARequest(
        numeroTimes: _numberOfTeams,
        instrucoes: instrucoes.isEmpty ? null : instrucoes,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // fecha o dialog de loading (sempre)

    result.when(
      success: (teams) {
        if (teams.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A IA não conseguiu gerar times. Tente novamente.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => TeamsDisplayScreen(
                  teams: teams,
                  grupoId: grupoId,
                  instrucoes: instrucoes.isEmpty ? null : instrucoes,
                  usouIA: true,
                  fieldType: widget.group.tipoCampo.toFieldType(),
                ),
          ),
        );
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingIADialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            const Text('Sortear com IA'),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _generateTeams,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Gerar Times com IA'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(scheme),
            const SizedBox(height: 16),
            _buildInstrucoesCard(scheme),
            const SizedBox(height: 16),
            _buildTeamCountCard(scheme),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(ColorScheme scheme) {
    return Card(
      elevation: 0,
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: scheme.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Powered by AI',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sorteio Inteligente',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A IA analisa notas, posições e restrições personalizadas para criar times equilibrados e diferentes dos sorteios anteriores.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrucoesCard(ColorScheme scheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_rounded, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Instruções Personalizadas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'opcional',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instrucoesController,
              maxLines: 4,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'Ex: Não colocar João e Pedro no mesmo time. O time 1 deve ter pelo menos 2 goleiros...',
                hintMaxLines: 3,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                counterStyle: TextStyle(color: scheme.outline),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: scheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'A IA considera o histórico dos últimos sorteios para evitar repetições.',
                    style: TextStyle(fontSize: 12, color: scheme.outline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCountCard(ColorScheme scheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_rounded, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Número de Times: $_numberOfTeams',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                min: _minTeams.toDouble(),
                max: _maxTeams.toDouble(),
                divisions: _maxTeams - _minTeams,
                value: _numberOfTeams.toDouble(),
                onChanged: (v) => setState(() => _numberOfTeams = v.toInt()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_minTeams',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$_maxTeams',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_maxTeams - _minTeams + 1, (i) {
                final n = _minTeams + i;
                final selected = _numberOfTeams == n;
                return ChoiceChip(
                  label: Text('$n'),
                  selected: selected,
                  labelStyle: TextStyle(
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (s) {
                    if (s) setState(() => _numberOfTeams = n);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIADialog extends StatelessWidget {
  const _LoadingIADialog();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.auto_awesome, color: scheme.primary, size: 28),
            const SizedBox(height: 12),
            Text(
              'Gerando times...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A IA está analisando os jogadores e criando times equilibrados.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
