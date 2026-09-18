import 'package:futdraw/data/models/responses/player_response.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';

class GroupResponse {
  final String grupoId;
  final String nome;
  final int totalJogadores;
  final int totalCapitaes;
  final List<String> diasDeJogo;
  final String? horarioJogo;
  final String? localPadrao;
  final String tipoCampo;
  final int jogadoresPorTime;
  final int duracaoJogoMinutos;
  final int limiteTitulares;
  final bool goleirosFixos;
  final String? urlAvatar;

  /// Tatica padrao do grupo, escrita em add.group.dart e ate agora nunca lida
  /// de volta: nem este DTO nem Group.fromJson (codigo morto) traziam os
  /// campos, entao a tela de times sempre caia no fallback de formacao.
  final int? taticaGoleiros;
  final int? taticaDefensores;
  final int? taticaMeias;
  final int? taticaAtacantes;

  const GroupResponse({
    required this.grupoId,
    required this.nome,
    required this.totalJogadores,
    required this.totalCapitaes,
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

  factory GroupResponse.fromJson(Map<String, dynamic> json) => GroupResponse(
    grupoId: json['grupoId'] as String,
    nome: json['nome'] as String,
    totalJogadores: json['totalJogadores'] as int? ?? 0,
    totalCapitaes: json['totalCapitaes'] as int? ?? 0,
    diasDeJogo: (json['diasDeJogo'] as List<dynamic>?)?.cast<String>() ?? [],
    horarioJogo: json['horarioJogo'] as String?,
    localPadrao: json['localPadrao'] as String?,
    tipoCampo: json['tipoCampo'] as String? ?? 'campo',
    jogadoresPorTime: json['jogadoresPorTime'] as int? ?? 11,
    duracaoJogoMinutos: json['duracaoJogoMinutos'] as int? ?? 90,
    limiteTitulares: json['limiteTitulares'] as int? ?? 22,
    goleirosFixos: json['goleirosFixos'] as bool? ?? false,
    urlAvatar: json['urlAvatar'] as String?,
    taticaGoleiros: json['taticaGoleiros'] as int?,
    taticaDefensores: json['taticaDefensores'] as int?,
    taticaMeias: json['taticaMeias'] as int?,
    taticaAtacantes: json['taticaAtacantes'] as int?,
  );

  Group toModel() => Group(
    id: grupoId,
    nome: nome,
    playerCount: totalJogadores,
    captainCount: totalCapitaes,
    diasDeJogo: diasDeJogo,
    horarioJogo: horarioJogo,
    localPadrao: localPadrao,
    tipoCampo: tipoCampo,
    jogadoresPorTime: jogadoresPorTime,
    duracaoJogoMinutos: duracaoJogoMinutos,
    limiteTitulares: limiteTitulares,
    goleirosFixos: goleirosFixos,
    urlAvatar: urlAvatar,
    taticaGoleiros: taticaGoleiros,
    taticaDefensores: taticaDefensores,
    taticaMeias: taticaMeias,
    taticaAtacantes: taticaAtacantes,
  );
}

class GroupDetailedResponse extends GroupResponse {
  final List<PlayerResponse> jogadores;

  const GroupDetailedResponse({
    required super.grupoId,
    required super.nome,
    required super.totalJogadores,
    required super.totalCapitaes,
    super.diasDeJogo,
    super.horarioJogo,
    super.localPadrao,
    super.tipoCampo,
    super.jogadoresPorTime,
    super.duracaoJogoMinutos,
    super.limiteTitulares,
    super.goleirosFixos,
    super.urlAvatar,
    super.taticaGoleiros,
    super.taticaDefensores,
    super.taticaMeias,
    super.taticaAtacantes,
    required this.jogadores,
  });

  factory GroupDetailedResponse.fromJson(Map<String, dynamic> json) =>
      GroupDetailedResponse(
        grupoId: json['grupoId'] as String,
        nome: json['nome'] as String,
        totalJogadores: json['totalJogadores'] as int? ?? 0,
        totalCapitaes: json['totalCapitaes'] as int? ?? 0,
        diasDeJogo: (json['diasDeJogo'] as List<dynamic>?)?.cast<String>() ?? [],
        horarioJogo: json['horarioJogo'] as String?,
        localPadrao: json['localPadrao'] as String?,
        tipoCampo: json['tipoCampo'] as String? ?? 'campo',
        jogadoresPorTime: json['jogadoresPorTime'] as int? ?? 11,
        duracaoJogoMinutos: json['duracaoJogoMinutos'] as int? ?? 90,
        limiteTitulares: json['limiteTitulares'] as int? ?? 22,
        goleirosFixos: json['goleirosFixos'] as bool? ?? false,
        urlAvatar: json['urlAvatar'] as String?,
    taticaGoleiros: json['taticaGoleiros'] as int?,
    taticaDefensores: json['taticaDefensores'] as int?,
    taticaMeias: json['taticaMeias'] as int?,
    taticaAtacantes: json['taticaAtacantes'] as int?,
        jogadores: (json['jogadores'] as List<dynamic>? ?? [])
            .map((j) => PlayerResponse.fromJson(j as Map<String, dynamic>))
            .toList(),
      );

  @override
  Group toModel() => Group(
    id: grupoId,
    nome: nome,
    playerCount: totalJogadores,
    captainCount: totalCapitaes,
    diasDeJogo: diasDeJogo,
    horarioJogo: horarioJogo,
    localPadrao: localPadrao,
    tipoCampo: tipoCampo,
    jogadoresPorTime: jogadoresPorTime,
    duracaoJogoMinutos: duracaoJogoMinutos,
    limiteTitulares: limiteTitulares,
    goleirosFixos: goleirosFixos,
    urlAvatar: urlAvatar,
    taticaGoleiros: taticaGoleiros,
    taticaDefensores: taticaDefensores,
    taticaMeias: taticaMeias,
    taticaAtacantes: taticaAtacantes,
    players: jogadores.map((j) => j.toModel(grupoId)).toList(),
  );

  List<Player> get players => jogadores.map((j) => j.toModel(grupoId)).toList();
}
