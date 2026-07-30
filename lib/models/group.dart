import 'package:futdraw/models/player.dart';

class Group {
  String id;
  String nome;
  int playerCount;
  int captainCount;
  List<Player> players;
  List<String> diasDeJogo;
  String? horarioJogo;
  String? localPadrao;
  String tipoCampo;
  int jogadoresPorTime;
  int duracaoJogoMinutos;
  int limiteTitulares;
  bool goleirosFixos;
  String? urlAvatar;
  int? taticaGoleiros;
  int? taticaDefensores;
  int? taticaMeias;
  int? taticaAtacantes;

  Group({
    required this.id,
    required this.nome,
    this.playerCount = 0,
    this.captainCount = 0,
    this.players = const [],
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

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['grupoId']?.toString() ?? json['id']?.toString() ?? '',
      nome: json['nome'] as String,
      playerCount: json['totalJogadores'] as int? ?? json['playersCount'] as int? ?? 0,
      captainCount: json['totalCapitaes'] as int? ?? json['captainCount'] as int? ?? 0,
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
  }
}
