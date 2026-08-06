import 'package:futdraw/models/enums/tipo_evento.dart';
import 'package:futdraw/models/enums/tipo_resultado.dart';

class MatchResult {
  final String partidaId;
  final List<MatchScore> placares;
  final List<MatchEvent> eventos;

  const MatchResult({
    required this.partidaId,
    required this.placares,
    required this.eventos,
  });
}

class MatchScore {
  final int timeIndex;
  final int gols;
  final TipoResultado resultado;

  const MatchScore({
    required this.timeIndex,
    required this.gols,
    required this.resultado,
  });
}

class MatchEvent {
  final String id;
  final String jogadorId;
  final String nomeJogador;
  final TipoEvento tipo;
  final int quantidade;

  const MatchEvent({
    required this.id,
    required this.jogadorId,
    required this.nomeJogador,
    required this.tipo,
    required this.quantidade,
  });
}
