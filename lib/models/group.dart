import 'package:futdraw/models/player.dart';

class Group {
  int id;
  String nome;
  int playerCount;
  int captainCount;
  List<Player> players;

  Group({
    required this.id,
    required this.nome,
    this.playerCount = 0,
    this.captainCount = 0,
    this.players = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      nome: json['nome'] as String,
      playerCount: json['playersCount'],
      captainCount: json['captainCount'],
    );
  }

  factory Group.add(String nome) {
    return Group(id: 0, nome: nome);
  }
}
