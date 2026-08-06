import 'package:futdraw/models/attendance.dart';

class AttendancePanel {
  final int totalConfirmados;
  final int totalRecusados;
  final int totalTalvez;
  final int totalPendentes;
  final List<Attendance> confirmados;
  final List<Attendance> recusados;
  final List<Attendance> talvez;
  final List<Attendance> pendentes;

  const AttendancePanel({
    required this.totalConfirmados,
    required this.totalRecusados,
    required this.totalTalvez,
    required this.totalPendentes,
    required this.confirmados,
    required this.recusados,
    required this.talvez,
    required this.pendentes,
  });

  int get total =>
      totalConfirmados + totalRecusados + totalTalvez + totalPendentes;
}
