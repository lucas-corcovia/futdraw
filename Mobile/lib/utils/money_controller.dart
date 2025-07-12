import 'package:flutter/material.dart';

class DecimalRangeController extends TextEditingController {
  double get value1 => double.tryParse(text.replaceAll(',', '.')) ?? 0.0;

  bool isValid() {
    return value1 >= 1.0 && value1 <= 10.0;
  }
}
