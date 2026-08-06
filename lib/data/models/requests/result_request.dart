class ResultRequest {
  final List<ScoreDto> placares;
  final List<EventoDto>? eventos;

  const ResultRequest({required this.placares, this.eventos});

  Map<String, dynamic> toJson() => {
    'placares': placares.map((p) => p.toJson()).toList(),
    if (eventos != null)
      'eventos': eventos!.map((e) => e.toJson()).toList(),
  };
}

class ScoreDto {
  final int timeIndex;
  final int gols;

  const ScoreDto({required this.timeIndex, required this.gols});

  Map<String, dynamic> toJson() => {'timeIndex': timeIndex, 'gols': gols};
}

class EventoDto {
  final String jogadorId;
  final int tipo;
  final int quantidade;

  const EventoDto({
    required this.jogadorId,
    required this.tipo,
    required this.quantidade,
  });

  Map<String, dynamic> toJson() => {
    'jogadorId': jogadorId,
    'tipo': tipo,
    'quantidade': quantidade,
  };
}
