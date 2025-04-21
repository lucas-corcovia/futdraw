class Player {
  int? id;
  String? nome;
  double? nota;
  bool ehGoleiro;
  String? urlFoto;

  Player({
    required this.id,
    required this.nome,
    required this.nota,
    required this.ehGoleiro,
    required this.urlFoto,
  });

  factory Player.getInstance() {
    return Player(id: 0, nome: '', nota: 0, ehGoleiro: false, urlFoto: null);
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      nome: map['nome'],
      nota: map['nota'],
      ehGoleiro: map['ehGoleiro'] == 0 ? false : true,
      urlFoto: map['urlFoto'],
    );
  }
}
