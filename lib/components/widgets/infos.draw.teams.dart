import 'package:flutter/material.dart';

class InfoDrawTeams extends StatelessWidget {
  const InfoDrawTeams({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            context,
            'Separação de Goleiros',
            'Os goleiros são distribuídos primeiro para garantir que cada time tenha um goleiro, se possível.',
            Icons.sports_handball,
          ),
          const Divider(),
          _buildInfoSection(
            context,
            'Distribuição de Capitães',
            'Capitães são distribuídos em times diferentes. Nunca haverá dois capitães no mesmo time, a menos que haja mais capitães que times.',
            Icons.stars,
          ),
          const Divider(),
          _buildInfoSection(
            context,
            'Método Snake Draft',
            'Os jogadores são ordenados por habilidade e distribuídos em formato zigzag (1->2->3->3->2->1) para garantir equilíbrio.',
            Icons.shuffle,
          ),
          const Divider(),
          _buildInfoSection(
            context,
            'Balanceamento Final',
            'Ao final, o algoritmo tenta trocar jogadores entre times para minimizar a diferença de habilidade média.',
            Icons.balance,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendi',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
