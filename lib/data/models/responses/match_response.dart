import 'package:futdraw/models/enums/status_partida.dart';
import 'package:futdraw/models/match.dart';

class MatchResponse {
  final String partidaId;
  final String grupoId;
  final DateTime dataHora;
  final String? local;
  final int status;
  final String? sorteioId;
  final int totalConfirmados;

  const MatchResponse({
    required this.partidaId,
    required this.grupoId,
    required this.dataHora,
    this.local,
    required this.status,
    this.sorteioId,
    this.totalConfirmados = 0,
  });

  factory MatchResponse.fromJson(Map<String, dynamic> json) => MatchResponse(
    partidaId: json['partidaId'] as String,
    grupoId: json['grupoId'] as String,
    dataHora: DateTime.parse(json['dataHora'] as String),
    local: json['local'] as String?,
    status: json['status'] as int,
    sorteioId: json['sorteioId'] as String?,
    totalConfirmados: json['totalConfirmados'] as int? ?? 0,
  );

  Match toModel() => Match(
    id: partidaId,
    grupoId: grupoId,
    dataHora: dataHora,
    local: local,
    status: StatusPartida.fromIndex(status),
    sorteioId: sorteioId,
    totalConfirmados: totalConfirmados,
  );
}
