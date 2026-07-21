import 'package:futdraw/models/enums/player.position.dart';

class Player {
  String id;
  String grupoId;
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
      id: '',
      grupoId: '',
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
      id: map['id']?.toString() ?? map['jogadorId']?.toString() ?? '',
      grupoId: map['grupoId']?.toString() ?? '',
      nome: map['nome'] as String? ?? '',
      nota: (map['nota'] as num?)?.toDouble() ?? 0.0,
      ehCapitao: map['ehCapitao'] as bool? ?? (map['capitao'] == 1),
      reserva: map['reserva'] is bool
          ? map['reserva'] as bool
          : map['reserva'] == 1,
      urlFoto: map['urlFoto'] as String?,
      position: PlayerPosition.values.firstWhere(
        (e) => e.index == (map['posicao'] as int? ?? 2),
        orElse: () => PlayerPosition.midfielder,
      ),
    );
  }

  bool get isGoalkeeper => position == PlayerPosition.goalkeeper;

  bool filterByName(String searched) {
    return nome.toLowerCase().startsWith(searched.toLowerCase());
  }

  Player copyWith({
    String? id,
    String? grupoId,
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
      'ehCapitao': ehCapitao,
      'reserva': reserva,
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
