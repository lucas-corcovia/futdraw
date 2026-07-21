// Deprecated: substituído por _PositionChip em filters.player.list.dart
// ignore_for_file: unused_element
import 'package:flutter/material.dart';

class ChipItem extends StatelessWidget {
  const ChipItem({
    super.key,
    required this.isSelected,
    required this.name,
    required this.onSelected,
  });

  final void Function(bool) onSelected;
  final String name;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        checkmarkColor: Theme.of(context).iconTheme.color,
        label: Text(
          name,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        shape: StadiumBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimary,
            width: 1,
          ),
        ),
        onSelected: onSelected,
      ),
    );
  }
}
