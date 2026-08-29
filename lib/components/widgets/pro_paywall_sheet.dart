import 'package:flutter/material.dart';

class ProPaywallSheet extends StatelessWidget {
  const ProPaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const ProPaywallSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium, color: scheme.primary, size: 32),
                const SizedBox(width: 10),
                Text(
                  'FutDraw Pro',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PervitinaDex',
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Você atingiu o limite de 3 sorteios com IA por mês.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...[
              _ProFeature(
                icon: Icons.auto_awesome_rounded,
                title: 'Sorteios com IA ilimitados',
                description: 'Sem limite mensal — use quantas vezes quiser.',
              ),
              _ProFeature(
                icon: Icons.download,
                title: 'Export de temporada',
                description: 'Baixe ranking e estatísticas em CSV.',
              ),
              _ProFeature(
                icon: Icons.insights,
                title: 'Histórico avançado',
                description: 'Relatórios detalhados por período.',
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.lock_clock),
              label: const Text('Assinar Pro — Em breve'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar com o plano gratuito'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ProFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
