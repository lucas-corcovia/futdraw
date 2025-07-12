import 'package:flutter/material.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:provider/provider.dart';

class InfoDrawTeams extends StatelessWidget {
  const InfoDrawTeams({super.key});

  @override
  Widget build(BuildContext context) {
    var algo =
        context
            .read<ConfigurationsController>()
            .configuration
            .generationAlgorithm;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            context,
            'Jogadores de linha',
            'Os jogadores de linha são distribuídos primeiro para garantir que cada time tenha a mesma quantidade de jogadores.',
            Icons.social_distance_sharp,
          ),
          const Divider(),
          _buildInfoSection(
            context,
            'Distribuição de Capitães',
            'Nunca haverá dois capitães no mesmo time, a menos que haja mais capitães que times.',
            Icons.stars,
          ),
          const Divider(),
          _getAlgorithmInfo(context, algo),
          const Divider(),
          _buildInfoSection(
            context,
            'Separação de Goleiros',
            'Ao final, os goleiros são distribuídos para que cada time tenha um goleiro, se possível.',
            Icons.sports_handball,
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

  _getAlgorithmInfo(BuildContext context, GenerationAlgorithm algorithm) {
    switch (algorithm) {
      case GenerationAlgorithm.snakeDraft:
        return _buildInfoSection(
          context,
          'Método Snake Draft',
          'Os jogadores são ordenados por habilidade e distribuídos em formato zigzag (1->2->3->3->2->1) para garantir equilíbrio.',
          Icons.shuffle,
        );
      case GenerationAlgorithm.balanced:
        return _buildInfoSection(
          context,
          'Balanceamento',
          'O algoritmo tenta trocar jogadores entre times para minimizar a diferença de habilidade média.',
          Icons.balance,
        );
    }
  }
}
