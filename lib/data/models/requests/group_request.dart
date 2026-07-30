class GroupRequest {
  final String nome;
  final List<String> diasDeJogo;
  final String? horarioJogo;
  final String? localPadrao;
  final String tipoCampo;
  final int jogadoresPorTime;
  final int duracaoJogoMinutos;
  final int limiteTitulares;
  final bool goleirosFixos;
  final String? urlAvatar;
  final int? taticaGoleiros;
  final int? taticaDefensores;
  final int? taticaMeias;
  final int? taticaAtacantes;

  const GroupRequest({
    required this.nome,
    this.diasDeJogo = const [],
    this.horarioJogo,
    this.localPadrao,
    this.tipoCampo = 'campo',
    this.jogadoresPorTime = 11,
    this.duracaoJogoMinutos = 90,
    this.limiteTitulares = 22,
    this.goleirosFixos = false,
    this.urlAvatar,
    this.taticaGoleiros,
    this.taticaDefensores,
    this.taticaMeias,
    this.taticaAtacantes,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'diasDeJogo': diasDeJogo,
    if (horarioJogo != null) 'horarioJogo': horarioJogo,
    if (localPadrao != null) 'localPadrao': localPadrao,
    'tipoCampo': tipoCampo,
    'jogadoresPorTime': jogadoresPorTime,
    'duracaoJogoMinutos': duracaoJogoMinutos,
    'limiteTitulares': limiteTitulares,
    'goleirosFixos': goleirosFixos,
    if (urlAvatar != null) 'urlAvatar': urlAvatar,
    if (taticaGoleiros != null) 'taticaGoleiros': taticaGoleiros,
    if (taticaDefensores != null) 'taticaDefensores': taticaDefensores,
    if (taticaMeias != null) 'taticaMeias': taticaMeias,
    if (taticaAtacantes != null) 'taticaAtacantes': taticaAtacantes,
  };
}
