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
}
