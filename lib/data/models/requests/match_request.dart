class MatchRequest {
  final DateTime dataHora;
  final String? local;

  const MatchRequest({required this.dataHora, this.local});

  Map<String, dynamic> toJson() => {
    'dataHora': dataHora.toIso8601String(),
    if (local != null) 'local': local,
  };
}
