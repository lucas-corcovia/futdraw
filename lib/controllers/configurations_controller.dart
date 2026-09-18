import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:futdraw/models/configuration.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationsController extends ChangeNotifier {
  static const String _key = '_config';
  Configuration? _configuration;

  Configuration get configuration =>
      _configuration ??= _defaults();

  static Configuration _defaults() => Configuration(
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
        _configuration = _defaults();
        await save();
      } else {
        _configuration = Configuration.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      // Registro ilegível: volta ao padrão e **regrava**. Sem essa regravação o
      // mesmo lixo seria relido em toda abertura, e o app pareceria esquecer a
      // cor escolhida para sempre.
      debugPrint('ConfigurationsController.init falhou, usando padrão: $e');
      _configuration = _defaults();
      await save();
    }
  }

  Future<void> save() async {
    // Uma escrita que falha em silêncio é indistinguível de uma preferência que
    // não persiste. O catch aqui existe para que o motivo apareça no log.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(configuration.toJson()));
    } catch (e) {
      debugPrint('ConfigurationsController.save falhou: $e');
    }
  }

  Future<void> setTheme(ThemeColor value) async {
    configuration.themeColor = value;
    notifyListeners();
    await save();
  }

  Future<void> setAlgorithm(GenerationAlgorithm value) async {
    configuration.generationAlgorithm = value;
    notifyListeners();
    await save();
  }

  Future<void> toggleDarkMode() async {
    configuration.isDarkMode = !configuration.isDarkMode;
    notifyListeners();
    await save();
  }

  Future<void> setGerarIndependenteDaPosicao(bool value) async {
    configuration.gerarIndependenteDaPosicao = value;
    notifyListeners();
    await save();
  }
}
