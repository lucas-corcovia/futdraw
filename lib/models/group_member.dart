import 'package:futdraw/models/enums/papel_membro.dart';

class GroupMember {
  final String id;
  final String usuarioId;
  final String nome;
  final String email;
  final PapelMembro papel;
  final String? jogadorId;

  const GroupMember({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.papel,
    this.jogadorId,
  });
}
