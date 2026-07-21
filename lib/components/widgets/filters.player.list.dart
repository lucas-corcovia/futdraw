import 'package:flutter/material.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:provider/provider.dart';

class FiltersPlayerList extends StatefulWidget {
  final int tabIndex;

  const FiltersPlayerList({super.key, required this.tabIndex});

  @override
  State<FiltersPlayerList> createState() => _FiltersPlayerListState();
}

class _FiltersPlayerListState extends State<FiltersPlayerList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              context.read<PlayerController>().filter(value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar jogador...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Limpar busca',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        context.read<PlayerController>().filter('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Consumer<PlayerController>(
            builder: (context, controller, _) {
              final allPlayers = controller.players
                  .where((p) => widget.tabIndex == 0 ? !p.reserva : p.reserva)
                  .toList();

              final allSelected =
                  controller.showedPositions.length ==
                  PlayerPosition.values.length;

              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _PositionChip(
                    label: 'Todos (${allPlayers.length})',
                    isSelected: allSelected,
                    onSelected: controller.toggleAll,
                  ),
                  ...PlayerPosition.values.map((pos) {
                    final count = allPlayers
                        .where((p) => p.position == pos)
                        .length;
                    final isSelected =
                        controller.showedPositions.contains(pos);
                    return _PositionChip(
                      label: '${pos.label} ($count)',
                      isSelected: isSelected,
                      onSelected: (selected) =>
                          controller.toggleFilter(selected, pos),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PositionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _PositionChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      avatar: isSelected
          ? const Icon(Icons.check_rounded, size: 16)
          : null,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
