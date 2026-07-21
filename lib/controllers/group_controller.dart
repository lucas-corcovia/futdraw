import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/repositories/group_repository.dart';

class GroupController extends ChangeNotifier {
  final GroupRepository repository;

  GroupController(this.repository);

  List<Group> groups = [];
  Group? selectedGroup;

  Future<List<Group>> getAll() async {
    final result = await repository.getAll();
    if (result is AppSuccess<List<Group>>) {
      groups = result.data;
      notifyListeners();
      return result.data;
    }
    return [];
  }

  Future<void> add(BuildContext context, Group group) async {
    final result = await repository.add(group);
    if (result.isSuccess) {
      await getAll();
    } else {
      Toast.show(context, result.errorMessage!, true);
    }
  }

  Future<void> delete(BuildContext context, String id) async {
    final result = await repository.delete(id);
    if (result.isSuccess) {
      await getAll();
    } else {
      Toast.show(context, result.errorMessage!, true);
    }
  }

  Future<void> update(BuildContext context, Group group) async {
    final result = await repository.update(group);
    if (result.isSuccess) {
      await getAll();
    } else {
      Toast.show(context, result.errorMessage!, true);
    }
  }
}
