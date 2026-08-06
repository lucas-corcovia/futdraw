import 'package:futdraw/models/enums/status_presenca.dart';

class Attendance {
  final String id;
  final String jogadorId;
  final String nomeJogador;
  final StatusPresenca status;
  final DateTime? respondidoEm;

  const Attendance({
    required this.id,
    required this.jogadorId,
    required this.nomeJogador,
    required this.status,
    this.respondidoEm,
  });
}
