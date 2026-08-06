import 'package:futdraw/models/attendance.dart';
import 'package:futdraw/models/enums/status_presenca.dart';

class AttendanceResponse {
  final String presencaId;
  final String jogadorId;
  final String nomeJogador;
  final int status;
  final String? respondidoEm;

  const AttendanceResponse({
    required this.presencaId,
    required this.jogadorId,
    required this.nomeJogador,
    required this.status,
    this.respondidoEm,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) =>
      AttendanceResponse(
        presencaId: json['presencaId'] as String,
        jogadorId: json['jogadorId'] as String,
        nomeJogador: json['nomeJogador'] as String,
        status: json['status'] as int,
        respondidoEm: json['respondidoEm'] as String?,
      );

  Attendance toModel() => Attendance(
    id: presencaId,
    jogadorId: jogadorId,
    nomeJogador: nomeJogador,
    status: StatusPresenca.fromIndex(status),
    respondidoEm:
        respondidoEm != null ? DateTime.parse(respondidoEm!) : null,
  );
}
