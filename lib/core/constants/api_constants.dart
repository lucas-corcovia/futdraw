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

  // Membros
  static String grupoMembros(String id) => '/api/grupos/$id/membros';
  static String grupoMembroPapel(String id) => '/api/grupos/membros/$id/papel';
  static String membroById(String id) => '/api/grupos/membros/$id';
  static String reivindicarJogador(String grupoId, String jogadorId) =>
      '/api/grupos/$grupoId/jogadores/$jogadorId/reivindicar';

  // Partidas
  static String grupoPartidas(String id) => '/api/grupos/$id/partidas';
  static String partidaById(String id) => '/api/partidas/$id';
  static String partidaPresencas(String id) => '/api/partidas/$id/presencas';
  static String partidaPresenca(String id) => '/api/partidas/$id/presenca';
  static String partidaResultado(String id) => '/api/partidas/$id/resultado';

  // Ranking / Estatísticas
  static String grupoRanking(String id) => '/api/grupos/$id/ranking';
  static String jogadorEstatisticas(String id) =>
      '/api/jogadores/$id/estatisticas';
}
