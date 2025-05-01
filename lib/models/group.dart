class Group {
  int? id;
  String? nome;

  Group({this.id, this.nome});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(id: json['id'] as int?, nome: json['nome'] as String?);
  }
}
