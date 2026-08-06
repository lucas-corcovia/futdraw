enum StatusPresenca {
  confirmado,
  recusado,
  talvez,
  pendente;

  static StatusPresenca fromIndex(int i) => StatusPresenca.values[i];

  String get label => switch (this) {
    StatusPresenca.confirmado => 'Confirmado',
    StatusPresenca.recusado => 'Recusado',
    StatusPresenca.talvez => 'Talvez',
    StatusPresenca.pendente => 'Pendente',
  };
}
