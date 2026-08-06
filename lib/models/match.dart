import 'package:futdraw/models/enums/status_partida.dart';

class Match {
  final String id;
  final String grupoId;
  final DateTime dataHora;
  final String? local;
  final StatusPartida status;
  final String? sorteioId;
  final int totalConfirmados;

  const Match({
    required this.id,
    required this.grupoId,
    required this.dataHora,
    this.local,
    required this.status,
    this.sorteioId,
    this.totalConfirmados = 0,
  });
}
