class SalvarSorteioRequest {
  final List<TimeSalvarItem> times;
  final String? instrucoes;
  final bool usouIA;

  const SalvarSorteioRequest({
    required this.times,
    this.instrucoes,
    required this.usouIA,
  });

  Map<String, dynamic> toJson() => {
    'times': times.map((t) => t.toJson()).toList(),
    if (instrucoes != null && instrucoes!.isNotEmpty) 'instrucoes': instrucoes,
    'usouIA': usouIA,
  };
}

class TimeSalvarItem {
  final String nome;
  final List<JogadorSalvarItem> jogadores;

  const TimeSalvarItem({required this.nome, required this.jogadores});

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'jogadores': jogadores.map((j) => j.toJson()).toList(),
  };
}

class JogadorSalvarItem {
  final String jogadorId;
  final String nome;
  final double nota;
  final int posicao;
  final bool ehCapitao;

  const JogadorSalvarItem({
    required this.jogadorId,
    required this.nome,
    required this.nota,
    required this.posicao,
    required this.ehCapitao,
  });

  Map<String, dynamic> toJson() => {
    'jogadorId': jogadorId,
    'nome': nome,
    'nota': nota,
    'posicao': posicao,
    'ehCapitao': ehCapitao,
  };
}
