class InviteMemberRequest {
  final String email;
  final int papel;

  const InviteMemberRequest({required this.email, required this.papel});

  Map<String, dynamic> toJson() => {'email': email, 'papel': papel};
}

class ChangePapelRequest {
  final int papel;

  const ChangePapelRequest({required this.papel});

  Map<String, dynamic> toJson() => {'papel': papel};
}
