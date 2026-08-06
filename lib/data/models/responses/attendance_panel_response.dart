import 'package:futdraw/data/models/responses/attendance_response.dart';
import 'package:futdraw/models/attendance_panel.dart';

class AttendancePanelResponse {
  final int totalConfirmados;
  final int totalRecusados;
  final int totalTalvez;
  final int totalPendentes;
  final List<AttendanceResponse> confirmados;
  final List<AttendanceResponse> recusados;
  final List<AttendanceResponse> talvez;
  final List<AttendanceResponse> pendentes;

  const AttendancePanelResponse({
    required this.totalConfirmados,
    required this.totalRecusados,
    required this.totalTalvez,
    required this.totalPendentes,
    required this.confirmados,
    required this.recusados,
    required this.talvez,
    required this.pendentes,
  });

  factory AttendancePanelResponse.fromJson(Map<String, dynamic> json) =>
      AttendancePanelResponse(
        totalConfirmados: json['totalConfirmados'] as int? ?? 0,
        totalRecusados: json['totalRecusados'] as int? ?? 0,
        totalTalvez: json['totalTalvez'] as int? ?? 0,
        totalPendentes: json['totalPendentes'] as int? ?? 0,
        confirmados: _parseList(json['confirmados']),
        recusados: _parseList(json['recusados']),
        talvez: _parseList(json['talvez']),
        pendentes: _parseList(json['pendentes']),
      );

  static List<AttendanceResponse> _parseList(dynamic list) =>
      (list as List<dynamic>? ?? [])
          .map((j) => AttendanceResponse.fromJson(j as Map<String, dynamic>))
          .toList();

  AttendancePanel toModel() => AttendancePanel(
    totalConfirmados: totalConfirmados,
    totalRecusados: totalRecusados,
    totalTalvez: totalTalvez,
    totalPendentes: totalPendentes,
    confirmados: confirmados.map((r) => r.toModel()).toList(),
    recusados: recusados.map((r) => r.toModel()).toList(),
    talvez: talvez.map((r) => r.toModel()).toList(),
    pendentes: pendentes.map((r) => r.toModel()).toList(),
  );
}
