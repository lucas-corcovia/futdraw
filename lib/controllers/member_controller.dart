import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/data/models/requests/member_request.dart';
import 'package:futdraw/models/enums/papel_membro.dart';
import 'package:futdraw/models/group_member.dart';
import 'package:futdraw/repositories/member_repository.dart';

class MemberController extends ChangeNotifier {
  final MemberRepository repository;

  MemberController(this.repository);

  List<GroupMember> members = [];

  Future<void> loadMembers(BuildContext context, String grupoId) async {
    final result = await repository.getAll(grupoId);
    result.when(
      success: (data) {
        members = data;
        notifyListeners();
      },
      error: (message) => Toast.show(context, message, true),
    );
  }

  Future<bool> invite(
    BuildContext context,
    String grupoId,
    String email,
    PapelMembro papel,
  ) async {
    final result = await repository.invite(
      grupoId,
      InviteMemberRequest(email: email, papel: papel.index),
    );
    return result.when(
      success: (data) {
        members = [...members, data];
        notifyListeners();
        Toast.show(context, 'Membro convidado com sucesso!', false);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }

  Future<bool> changePapel(
    BuildContext context,
    String membroId,
    PapelMembro papel,
  ) async {
    final result = await repository.changePapel(
      membroId,
      ChangePapelRequest(papel: papel.index),
    );
    return result.when(
      success: (data) {
        members = members.map((m) => m.id == membroId ? data : m).toList();
        notifyListeners();
        Toast.show(context, 'Papel alterado com sucesso!', false);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }

  Future<void> remove(BuildContext context, String membroId) async {
    final result = await repository.remove(membroId);
    result.when(
      success: (_) {
        members = members.where((m) => m.id != membroId).toList();
        notifyListeners();
        Toast.show(context, 'Membro removido com sucesso!', false);
      },
      error: (message) => Toast.show(context, message, true),
    );
  }

  Future<bool> claimPlayer(
    BuildContext context,
    String grupoId,
    String jogadorId,
  ) async {
    final result = await repository.claimPlayer(grupoId, jogadorId);
    return result.when(
      success: (_) {
        Toast.show(context, 'Ficha vinculada com sucesso!', false);
        loadMembers(context, grupoId);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }
}
