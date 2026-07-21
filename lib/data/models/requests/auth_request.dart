class LoginRequest {
  final String email;
  final String senha;

  const LoginRequest({required this.email, required this.senha});

  Map<String, dynamic> toJson() => {'email': email, 'senha': senha};
}

class RegisterRequest {
  final String nome;
  final String email;
  final String senha;

  const RegisterRequest({
    required this.nome,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'email': email,
    'senha': senha,
  };
}
