import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futdraw/models/configuration.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationsController extends ChangeNotifier {
  static const String _key = '_config';
  Configuration? _configuration;

  Configuration get configuration =>
      _configuration ??= Configuration(
        generationAlgorithm: GenerationAlgorithm.balanced,
        themeColor: ThemeColor.esmeralda,
        isDarkMode: true,
      );

  // Carrega a configuração salva. Deve ser chamado uma vez no startup com a
  // mesma instância que será registrada no Provider.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        _configuration = Configuration(
          generationAlgorithm: GenerationAlgorithm.balanced,
          themeColor: ThemeColor.esmeralda,
          isDarkMode: true,
        );
        await save();
      } else {
        _configuration = Configuration.fromJson(jsonDecode(jsonString));
      }
    } catch (_) {
      _configuration = Configuration(
        generationAlgorithm: GenerationAlgorithm.balanced,
        themeColor: ThemeColor.esmeralda,
        isDarkMode: true,
      );
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(configuration.toJson()));
  }

  void setTheme(ThemeColor value) {
    configuration.themeColor = value;
    save();
    notifyListeners();
  }

  void setAlgorithm(GenerationAlgorithm value) {
    configuration.generationAlgorithm = value;
    save();
    notifyListeners();
  }

  void toggleDarkMode() {
    configuration.isDarkMode = !configuration.isDarkMode;
    save();
    notifyListeners();
  }
}
