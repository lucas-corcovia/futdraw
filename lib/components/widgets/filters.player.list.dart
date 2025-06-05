import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/chip.item.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:provider/provider.dart';

class FiltersPlayerList extends StatelessWidget {
  final int tabIndex;
  const FiltersPlayerList({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar jogador...',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
              ),
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onChanged: (value) {
                context.read<PlayerController>().filter(value);
              },
            ),
            SizedBox(height: 10),
            Consumer<PlayerController>(
              builder: (context, controller, child) {
                // O filtro correto deve ser feito sobre todos os jogadores, não só os filtrados
                final allPlayers =
                    controller.players
                        .where((p) => tabIndex == 0 ? !p.reserva : p.reserva)
                        .toList();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChipItem(
                        name: "Todos (${allPlayers.length})",
                        onSelected: controller.toggleAll,
                        isSelected:
                            controller.showedPositions.length ==
                            PlayerPosition.values.length,
                      ),
                      ...PlayerPosition.values.toList().map((option) {
                        var itemCount =
                            allPlayers
                                .where((player) => player.position == option)
                                .length;
                        var selected = controller.showedPositions.contains(
                          option,
                        );
                        return ChipItem(
                          isSelected: selected,
                          name:
                              selected
                                  ? "${option.label} ($itemCount)"
                                  : option.label,
                          onSelected: (selected) {
                            controller.toggleFilter(selected, option);
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
