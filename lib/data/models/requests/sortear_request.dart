class SortearRequest {
  final int numeroTimes;
  final int algoritmo;

  const SortearRequest({required this.numeroTimes, required this.algoritmo});

  Map<String, dynamic> toJson() => {
    'numeroTimes': numeroTimes,
    'algoritmo': algoritmo,
  };
}
