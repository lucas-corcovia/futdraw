import 'package:futdraw/models/enums/player.position.dart';

class Player {
  int id;
  int grupoId;
  String nome;
  double nota;
  String? urlFoto;
  bool ehCapitao;
  bool reserva;
  PlayerPosition position;

  Player({
    required this.id,
    required this.grupoId,
    required this.nome,
    required this.nota,
    required this.ehCapitao,
    required this.urlFoto,
    required this.position,
    required this.reserva,
  });

  factory Player.getInstance() {
    return Player(
      id: 0,
      grupoId: 0,
      nome: '',
      nota: 0,
      ehCapitao: false,
      reserva: false,
      urlFoto: null,
      position: PlayerPosition.midfielder,
    );
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      grupoId: map['grupoId'],
      nome: map['nome'],
      nota: map['nota'],
      ehCapitao: map['capitao'] == 1 ? true : false,
      reserva: map['reserva'] == 1 ? true : false,
      urlFoto: map['urlFoto'],
      position: PlayerPosition.values.firstWhere(
        (e) => e.index == map['posicao'] as int?,
        orElse: () => PlayerPosition.midfielder,
      ),
    );
  }

  bool get isGoalkeeper => position == PlayerPosition.goalkeeper;

  bool filterByName(String searched) {
    return nome.toLowerCase().startsWith(searched.toLowerCase());
  }

  Player copyWith({
    int? id,
    int? grupoId,
    String? nome,
    double? nota,
    String? urlFoto,
    bool? ehCapitao,
    bool? reserva,
    PlayerPosition? position,
  }) {
    return Player(
      id: id ?? this.id,
      grupoId: grupoId ?? this.grupoId,
      nome: nome ?? this.nome,
      nota: nota ?? this.nota,
      urlFoto: urlFoto ?? this.urlFoto,
      ehCapitao: ehCapitao ?? this.ehCapitao,
      reserva: reserva ?? this.reserva,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grupoId': grupoId,
      'nome': nome,
      'nota': nota,
      'urlFoto': urlFoto,
      'capitao': ehCapitao ? 1 : 0,
      'reserva': reserva ? 1 : 0,
      'posicao': position.index,
    };
  }

  static List<Map<String, dynamic>> fromListToJson(List<Player> players) {
    return players.map((player) => player.toJson()).toList();
  }

  static List<Player> fromJsonToList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => Player.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
