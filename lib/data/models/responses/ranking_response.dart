import 'package:futdraw/models/ranking_item.dart';

class RankingItemResponse {
  final String jogadorId;
  final String nome;
  final int jogos;
  final int vitorias;
  final int empates;
  final int derrotas;
  final double aproveitamento;
  final int saldoGols;
  final int gols;
  final int assistencias;

  const RankingItemResponse({
    required this.jogadorId,
    required this.nome,
    required this.jogos,
    required this.vitorias,
    required this.empates,
    required this.derrotas,
    required this.aproveitamento,
    required this.saldoGols,
    required this.gols,
    required this.assistencias,
  });

  factory RankingItemResponse.fromJson(Map<String, dynamic> json) =>
      RankingItemResponse(
        jogadorId: json['jogadorId'] as String,
        nome: json['nome'] as String,
        jogos: json['jogos'] as int? ?? 0,
        vitorias: json['vitorias'] as int? ?? 0,
        empates: json['empates'] as int? ?? 0,
        derrotas: json['derrotas'] as int? ?? 0,
        aproveitamento: (json['aproveitamento'] as num?)?.toDouble() ?? 0.0,
        saldoGols: json['saldoGols'] as int? ?? 0,
        gols: json['gols'] as int? ?? 0,
        assistencias: json['assistencias'] as int? ?? 0,
      );

  RankingItem toModel() => RankingItem(
    jogadorId: jogadorId,
    nome: nome,
    jogos: jogos,
    vitorias: vitorias,
    empates: empates,
    derrotas: derrotas,
    aproveitamento: aproveitamento,
    saldoGols: saldoGols,
    gols: gols,
    assistencias: assistencias,
  );
}
