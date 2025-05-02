import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/group.item.dart';
import 'package:futdraw/components/widgets/groups.empty.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:provider/provider.dart';

class GroupList extends StatelessWidget {
  const GroupList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupController>(
      builder: (context, controller, child) {
        if (controller.groups.isEmpty) return Center(child: GroupsEmpty());

        return ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            final groupPlayers = [];
            final captainCount = 0;

            return GroupItem(
              groupPlayers: groupPlayers,
              group: group,
              captainCount: captainCount,
            );
          },
        );
      },
    );
  }
}
