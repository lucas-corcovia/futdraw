class PlayerRequest {
  final String nome;
  final double nota;
  final String? urlFoto;
  final int posicao;
  final bool ehCapitao;
  final bool reserva;

  const PlayerRequest({
    required this.nome,
    required this.nota,
    this.urlFoto,
    required this.posicao,
    required this.ehCapitao,
    required this.reserva,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'nota': nota,
    'urlFoto': urlFoto,
    'posicao': posicao,
    'ehCapitao': ehCapitao,
    'reserva': reserva,
  };
}
