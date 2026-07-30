class SortearIARequest {
  final int numeroTimes;
  final String? instrucoes;

  const SortearIARequest({required this.numeroTimes, this.instrucoes});

  Map<String, dynamic> toJson() => {
    'numeroTimes': numeroTimes,
    if (instrucoes != null && instrucoes!.isNotEmpty) 'instrucoes': instrucoes,
  };
}
