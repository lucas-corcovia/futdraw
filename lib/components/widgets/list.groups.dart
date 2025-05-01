import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/group.item.dart';
import 'package:futdraw/components/widgets/groups.empty.dart';
import 'package:futdraw/models/group.dart';

class GroupList extends StatelessWidget {
  const GroupList({super.key, required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return Center(child: GroupsEmpty());

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final groupPlayers = [];
        final captainCount = 0;

        return GroupItem(
          groupPlayers: groupPlayers,
          group: group,
          captainCount: captainCount,
        );
      },
    );
  }
}
