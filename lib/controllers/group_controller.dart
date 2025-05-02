import 'package:flutter/material.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/repositories/group_repository.dart';

class GroupController extends ChangeNotifier {
  final repository = GroupRepository();
  List<Group> groups = [];
  Group? selectedGroup;

  Future<List<Group>> getAll() async {
    var result = await repository.getAll();
    groups = result;
    notifyListeners();
    return result;
  }

  add(Group group) async {
    await repository.add(group);
    await getAll();
  }

  delete(int id) async {
    await repository.delete(id);
    await getAll();
  }
}
