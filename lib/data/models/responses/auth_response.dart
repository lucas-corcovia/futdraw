class AuthResponse {
  final String token;
  final DateTime expiracao;
  final String nome;
  final String email;

  const AuthResponse({
    required this.token,
    required this.expiracao,
    required this.nome,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] as String,
    expiracao: DateTime.parse(json['expiracao'] as String),
    nome: json['nome'] as String,
    email: json['email'] as String,
  );
}
