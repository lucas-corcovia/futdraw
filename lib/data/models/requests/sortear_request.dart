class SortearRequest {
  final int numeroTimes;
  final int algoritmo;
  final bool gerarIndependenteDaPosicao;
  final List<String>? jogadorIds;

  const SortearRequest({
    required this.numeroTimes,
    required this.algoritmo,
    this.gerarIndependenteDaPosicao = false,
    this.jogadorIds,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'numeroTimes': numeroTimes,
      'algoritmo': algoritmo,
      'gerarIndependenteDaPosicao': gerarIndependenteDaPosicao,
    };
    if (jogadorIds != null && jogadorIds!.isNotEmpty) {
      map['jogadorIds'] = jogadorIds;
    }
    return map;
  }
}
