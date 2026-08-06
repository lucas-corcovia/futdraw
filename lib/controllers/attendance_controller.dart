import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/data/models/requests/attendance_request.dart';
import 'package:futdraw/models/attendance_panel.dart';
import 'package:futdraw/models/enums/status_presenca.dart';
import 'package:futdraw/repositories/attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceRepository repository;

  AttendanceController(this.repository);

  AttendancePanel? panel;

  Future<void> loadPanel(BuildContext context, String partidaId) async {
    final result = await repository.getPanel(partidaId);
    result.when(
      success: (data) {
        panel = data;
        notifyListeners();
      },
      error: (message) => Toast.show(context, message, true),
    );
  }

  Future<bool> respond(
    BuildContext context,
    String partidaId,
    StatusPresenca status,
  ) async {
    final result = await repository.respond(
      partidaId,
      AttendanceRequest(status: status.index),
    );
    return result.when(
      success: (_) {
        Toast.show(context, 'Presença registrada!', false);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }
}
