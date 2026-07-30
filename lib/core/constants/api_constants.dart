abstract final class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5020';

  static const String login = '/api/auth/login';
  static const String registrar = '/api/auth/registrar';
  static const String confirmarEmail = '/api/auth/confirmar-email';
  static const String reenviarCodigo = '/api/auth/reenviar-codigo';
  static const String googleLogin = '/api/auth/google';

  static const String grupos = '/api/grupos';
  static String grupoById(String id) => '/api/grupos/$id';
  static String grupoJogadores(String grupoId) =>
      '/api/grupos/$grupoId/jogadores';
  static String grupoImportar(String grupoId) =>
      '/api/grupos/$grupoId/jogadores/importar';
  static String grupoSortear(String grupoId) => '/api/grupos/$grupoId/sortear';
  static String grupoSortearIA(String grupoId) =>
      '/api/grupos/$grupoId/sorteios/sortear/ia';
  static String grupoSorteios(String grupoId) =>
      '/api/grupos/$grupoId/sorteios';

  static const String jogadores = '/api/jogadores';
  static String jogadorById(String id) => '/api/jogadores/$id';
}
