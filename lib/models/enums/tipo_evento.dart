enum TipoEvento {
  gol,
  assistencia,
  cartaoAmarelo,
  cartaoVermelho;

  static TipoEvento fromIndex(int i) => TipoEvento.values[i];

  String get label => switch (this) {
    TipoEvento.gol => 'Gol',
    TipoEvento.assistencia => 'Assistência',
    TipoEvento.cartaoAmarelo => 'Cartão Amarelo',
    TipoEvento.cartaoVermelho => 'Cartão Vermelho',
  };
}
