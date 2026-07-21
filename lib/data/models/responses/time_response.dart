import 'package:futdraw/data/models/responses/player_response.dart';
import 'package:futdraw/helpers/team_generator.dart';

class TimeResponse {
  final String nome;
  final List<PlayerResponse> jogadores;
  final double mediaNota;

  const TimeResponse({
    required this.nome,
    required this.jogadores,
    required this.mediaNota,
  });

  factory TimeResponse.fromJson(Map<String, dynamic> json) => TimeResponse(
    nome: json['nome'] as String,
    jogadores: (json['jogadores'] as List<dynamic>? ?? [])
        .map((j) => PlayerResponse.fromJson(j as Map<String, dynamic>))
        .toList(),
    mediaNota: (json['mediaNota'] as num?)?.toDouble() ?? 0.0,
  );

  Team toModel() => Team(
    name: nome,
    players: jogadores.map((j) => j.toModel('')).toList(),
    averageSkill: mediaNota,
  );
}
