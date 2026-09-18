import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/player_row.dart';
import 'package:futdraw/components/widgets/position_chip.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/theme/app_typography.dart';
import 'package:futdraw/theme/pitch_theme.dart';
import 'package:futdraw/utils/extensions.dart';

/// Uma tela sintetica com um exemplar de cada atomo tematizado do app.
///
/// Existe para que a varredura de 8 seeds x 2 brilhancias rode contra **um**
/// widget em vez de contra cada tela real: pega toda regressao de contraste e
/// de estouro da matriz por uma fracao do custo. As telas reais entao precisam
/// de goldens em um seed so, porque o seed ja foi provado seguro aqui.
class ThemeProbeScreen extends StatelessWidget {
  const ThemeProbeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final texts = context.texts;
    final pitch = context.pitch;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonda de tema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Mais opcoes',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: [
            Text('Escala tipografica', style: texts.headlineSmall),
            Text('Titulo de secao', style: texts.titleMedium),
            Text('Corpo de texto comum do app.', style: texts.bodyMedium),
            Text(
              'Texto secundario, o papel que mais falha contraste.',
              style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),

            const _Section('Botoes'),
            FilledButton(onPressed: () {}, child: const Text('Salvar sorteio')),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Compartilhar'),
            ),
            TextButton(onPressed: () {}, child: const Text('Cancelar')),
            const FilledButton(
              onPressed: null,
              child: Text('Desabilitado'),
            ),

            const _Section('Superficies'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card', style: texts.titleSmall),
                    Text(
                      'Legenda dentro de um card.',
                      style: texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const ListTile(
              title: Text('Item de lista'),
              subtitle: Text('Subtitulo do item'),
              trailing: Icon(Icons.chevron_right),
            ),
            const Divider(),

            const _Section('Entrada'),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nome do jogador',
                helperText: 'Como aparece na escalacao',
              ),
            ),

            const _Section('Selecao'),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                const Chip(label: Text('4-3-3')),
                Chip(
                  label: const Text('4-4-2'),
                  backgroundColor: scheme.primaryContainer,
                ),
              ],
            ),

            const _Section('Posicoes'),
            // As quatro posicoes entram na varredura de 8 seeds x 2 brilhancias
            // pelo mesmo motivo que os demais atomos: e aqui que um par
            // ink/container fora de contraste aparece antes de chegar na tela.
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final position in PlayerPosition.values)
                  PositionChip(position: position),
              ],
            ),
            PlayerRow(
              player: _probePlayer,
              onEdit: () {},
              onDelete: () {},
              onSwap: (_) {},
            ),

            const _Section('Cena do campo'),
            _PitchAtoms(pitch: pitch, texts: texts),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: context.texts.labelMedium?.copyWith(
      color: context.scheme.onSurfaceVariant,
    ),
  );
}

/// Os atomos que vivem sobre a turfa. Renderizados sobre a cor real do gramado
/// para que a checagem de contraste avalie o par verdadeiro, e nao o par
/// contra a superficie do app.
class _PitchAtoms extends StatelessWidget {
  const _PitchAtoms({required this.pitch, required this.texts});

  final PitchTheme pitch;
  final TextTheme texts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: pitch.turfMid,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (final position in PlayerPosition.values)
                _PositionDot(
                  color: pitch.colorFor(position),
                  label: position.shortLabel,
                  name: position.displayName,
                  texts: texts,
                  onTurf: pitch.chipOnSurface,
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: pitch.scoreboardGlass,
              borderRadius: AppRadii.chip,
              border: Border.all(color: pitch.scoreboardBorder),
            ),
            child: Text(
              'MEDIA 7.4',
              style: AppTypography.scoreboardLabel.copyWith(
                color: pitch.chipOnSurface,
              ),
            ),
          ),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(Icons.star_rounded, color: pitch.captainGold, size: 20),
              Text(
                'Capitao',
                style: texts.labelMedium?.copyWith(color: pitch.chipOnSurface),
              ),
            ],
          ),
          Row(
            spacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: pitch.accentForTeam(i),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionDot extends StatelessWidget {
  const _PositionDot({
    required this.color,
    required this.label,
    required this.name,
    required this.texts,
    required this.onTurf,
  });

  final Color color;
  final String label;
  final String name;
  final TextTheme texts;
  final Color onTurf;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            label,
            style: texts.labelSmall?.copyWith(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Text(name, style: texts.labelSmall?.copyWith(color: onTurf)),
      ],
    );
  }
}

/// Jogador sintetico da sonda. Nome comprido de proposito: e o caso que estoura
/// a linha, nao o nome curto.
final Player _probePlayer = Player(
  id: 'probe-1',
  grupoId: 'probe',
  nome: 'Joao Marcos de Alcantara',
  nota: 7.5,
  ehCapitao: true,
  urlFoto: null,
  position: PlayerPosition.midfielder,
  reserva: false,
);
