import 'package:futdraw/models/enums/tipo_evento.dart';
import 'package:futdraw/models/enums/tipo_resultado.dart';
import 'package:futdraw/models/match_result.dart';

class ResultResponse {
  final String partidaId;
  final List<MatchScoreResponse> placares;
  final List<MatchEventResponse> eventos;

  const ResultResponse({
    required this.partidaId,
    required this.placares,
    required this.eventos,
  });

  factory ResultResponse.fromJson(Map<String, dynamic> json) => ResultResponse(
    partidaId: json['partidaId'] as String,
    placares: (json['placares'] as List<dynamic>? ?? [])
        .map(
          (j) => MatchScoreResponse.fromJson(j as Map<String, dynamic>),
        )
        .toList(),
    eventos: (json['eventos'] as List<dynamic>? ?? [])
        .map(
          (j) => MatchEventResponse.fromJson(j as Map<String, dynamic>),
        )
        .toList(),
  );

  MatchResult toModel() => MatchResult(
    partidaId: partidaId,
    placares: placares.map((p) => p.toModel()).toList(),
    eventos: eventos.map((e) => e.toModel()).toList(),
  );
}

class MatchScoreResponse {
  final int timeIndex;
  final int gols;
  final int resultado;

  const MatchScoreResponse({
    required this.timeIndex,
    required this.gols,
    required this.resultado,
  });

  factory MatchScoreResponse.fromJson(Map<String, dynamic> json) =>
      MatchScoreResponse(
        timeIndex: json['timeIndex'] as int,
        gols: json['gols'] as int,
        resultado: json['resultado'] as int,
      );

  MatchScore toModel() => MatchScore(
    timeIndex: timeIndex,
    gols: gols,
    resultado: TipoResultado.fromIndex(resultado),
  );
}

class MatchEventResponse {
  final String eventoId;
  final String jogadorId;
  final String nomeJogador;
  final int tipo;
  final int quantidade;

  const MatchEventResponse({
    required this.eventoId,
    required this.jogadorId,
    required this.nomeJogador,
    required this.tipo,
    required this.quantidade,
  });

  factory MatchEventResponse.fromJson(Map<String, dynamic> json) =>
      MatchEventResponse(
        eventoId: json['eventoId'] as String,
        jogadorId: json['jogadorId'] as String,
        nomeJogador: json['nomeJogador'] as String,
        tipo: json['tipo'] as int,
        quantidade: json['quantidade'] as int,
      );

  MatchEvent toModel() => MatchEvent(
    id: eventoId,
    jogadorId: jogadorId,
    nomeJogador: nomeJogador,
    tipo: TipoEvento.fromIndex(tipo),
    quantidade: quantidade,
  );
}
