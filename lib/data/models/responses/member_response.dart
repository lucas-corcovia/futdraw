import 'package:futdraw/models/enums/papel_membro.dart';
import 'package:futdraw/models/group_member.dart';

class MemberResponse {
  final String grupoMembroId;
  final String usuarioId;
  final String nome;
  final String email;
  final int papel;
  final String? jogadorId;

  const MemberResponse({
    required this.grupoMembroId,
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.papel,
    this.jogadorId,
  });

  factory MemberResponse.fromJson(Map<String, dynamic> json) => MemberResponse(
    grupoMembroId: json['grupoMembroId'] as String,
    usuarioId: json['usuarioId'] as String,
    nome: json['nome'] as String,
    email: json['email'] as String,
    papel: json['papel'] as int,
    jogadorId: json['jogadorId'] as String?,
  );

  GroupMember toModel() => GroupMember(
    id: grupoMembroId,
    usuarioId: usuarioId,
    nome: nome,
    email: email,
    papel: PapelMembro.fromIndex(papel),
    jogadorId: jogadorId,
  );
}
