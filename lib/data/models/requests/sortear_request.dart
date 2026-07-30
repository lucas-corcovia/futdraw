class SortearRequest {
  final int numeroTimes;
  final int algoritmo;
  final bool gerarIndependenteDaPosicao;

  const SortearRequest({
    required this.numeroTimes,
    required this.algoritmo,
    this.gerarIndependenteDaPosicao = false,
  });

  Map<String, dynamic> toJson() => {
    'numeroTimes': numeroTimes,
    'algoritmo': algoritmo,
    'gerarIndependenteDaPosicao': gerarIndependenteDaPosicao,
  };
}
