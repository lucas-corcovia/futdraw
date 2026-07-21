abstract final class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5020';

  static const String login = '/api/auth/login';
  static const String registrar = '/api/auth/registrar';

  static const String grupos = '/api/grupos';
  static String grupoById(String id) => '/api/grupos/$id';
  static String grupoJogadores(String grupoId) =>
      '/api/grupos/$grupoId/jogadores';
  static String grupoImportar(String grupoId) =>
      '/api/grupos/$grupoId/jogadores/importar';
  static String grupoSortear(String grupoId) => '/api/grupos/$grupoId/sortear';

  static const String jogadores = '/api/jogadores';
  static String jogadorById(String id) => '/api/jogadores/$id';
}
