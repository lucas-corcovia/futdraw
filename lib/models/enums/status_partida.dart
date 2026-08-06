enum StatusPartida {
  agendada,
  confirmada,
  emAndamento,
  finalizada,
  cancelada;

  static StatusPartida fromIndex(int i) => StatusPartida.values[i];

  String get label => switch (this) {
    StatusPartida.agendada => 'Agendada',
    StatusPartida.confirmada => 'Confirmada',
    StatusPartida.emAndamento => 'Em Andamento',
    StatusPartida.finalizada => 'Finalizada',
    StatusPartida.cancelada => 'Cancelada',
  };
}
