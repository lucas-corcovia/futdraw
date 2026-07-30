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

class ConfirmarEmailRequest {
  final String email;
  final String codigo;

  const ConfirmarEmailRequest({required this.email, required this.codigo});

  Map<String, dynamic> toJson() => {'email': email, 'codigo': codigo};
}

class ReenviarCodigoRequest {
  final String email;

  const ReenviarCodigoRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class GoogleLoginRequest {
  final String idToken;

  const GoogleLoginRequest({required this.idToken});

  Map<String, dynamic> toJson() => {'idToken': idToken};
}
