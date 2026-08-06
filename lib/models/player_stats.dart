class PlayerStats {
  final String jogadorId;
  final String nome;
  final int jogos;
  final int vitorias;
  final int empates;
  final int derrotas;
  final double aproveitamento;
  final int gols;
  final int assistencias;
  final int sequenciaAtual;

  const PlayerStats({
    required this.jogadorId,
    required this.nome,
    required this.jogos,
    required this.vitorias,
    required this.empates,
    required this.derrotas,
    required this.aproveitamento,
    required this.gols,
    required this.assistencias,
    required this.sequenciaAtual,
  });
}
