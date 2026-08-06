enum TipoResultado {
  vitoria,
  empate,
  derrota;

  static TipoResultado fromIndex(int i) => TipoResultado.values[i];

  String get label => switch (this) {
    TipoResultado.vitoria => 'V',
    TipoResultado.empate => 'E',
    TipoResultado.derrota => 'D',
  };
}
