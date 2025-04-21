extension StringToIntExtension on String {
  int toInt({int defaultValue = 0}) {
    return int.tryParse(this) ?? defaultValue;
  }
}

extension StringToDouble on String {
  double toDouble() {
    return double.tryParse(replaceAll(',', '.')) ?? 0.0;
  }
}
