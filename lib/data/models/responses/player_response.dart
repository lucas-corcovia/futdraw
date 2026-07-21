import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

class PlayerResponse {
  final String jogadorId;
  final String nome;
  final double nota;
  final String? urlFoto;
  final int posicao;
  final bool ehCapitao;
  final bool reserva;

  const PlayerResponse({
    required this.jogadorId,
    required this.nome,
    required this.nota,
    this.urlFoto,
    required this.posicao,
    required this.ehCapitao,
    required this.reserva,
  });

  factory PlayerResponse.fromJson(Map<String, dynamic> json) => PlayerResponse(
    jogadorId: json['jogadorId'] as String,
    nome: json['nome'] as String,
    nota: (json['nota'] as num).toDouble(),
    urlFoto: json['urlFoto'] as String?,
    posicao: json['posicao'] as int? ?? 2,
    ehCapitao: json['ehCapitao'] as bool? ?? false,
    reserva: json['reserva'] as bool? ?? false,
  );

  Player toModel(String grupoId) => Player(
    id: jogadorId,
    grupoId: grupoId,
    nome: nome,
    nota: nota,
    urlFoto: urlFoto,
    ehCapitao: ehCapitao,
    reserva: reserva,
    position: PlayerPosition.values.elementAtOrNull(posicao) ??
        PlayerPosition.midfielder,
  );
}
