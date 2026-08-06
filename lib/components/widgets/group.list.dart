import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/group.item.dart';
import 'package:futdraw/components/widgets/groups.empty.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:provider/provider.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GroupController>().getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupController>(
      builder: (context, controller, child) {
        if (controller.groups.isEmpty) return Center(child: GroupsEmpty());

        return ListView.builder(
          padding: EdgeInsets.only(top: 10),
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];

            return GroupItem(group: group);
          },
        );
      },
    );
  }
}
