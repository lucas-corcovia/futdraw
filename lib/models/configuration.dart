class Configuration {
  bool isOnlySociety;

  Configuration({required this.isOnlySociety});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(isOnlySociety: json['isOnlySociety'] == 1);
  }
}
