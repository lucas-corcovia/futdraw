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
        themeColor: ThemeColor.green,
      );

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(_key);

    if (result != null) {
      prefs.remove(_key);
    }

    final json = configuration.toJson();
    final jsonString = jsonEncode(json);

    await prefs.setString(_key, jsonString);
  }

  Future<Configuration?> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        _configuration = Configuration(
          generationAlgorithm: GenerationAlgorithm.balanced,
          themeColor: ThemeColor.purple,
        );

        save();
        return _configuration;
      }

      final json = jsonDecode(jsonString);
      return Configuration.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  void setTheme(ThemeColor value) {
    _configuration!.themeColor = value;
    save();
    notifyListeners();
  }

  void setAlgorithm(GenerationAlgorithm value) {
    _configuration!.generationAlgorithm = value;
    save();
    notifyListeners();
  }
}

// import 'package:futdraw/models/configuration.dart';
// import 'package:futdraw/repositories/configurations_repository.dart';

// class ConfigurationsController {
//   final ConfigurationsRepository repository = ConfigurationsRepository();
//   Configuration? configuration;

//   static final ConfigurationsController _instance =
//       ConfigurationsController._internal();
//   factory ConfigurationsController() => _instance;
//   ConfigurationsController._internal();

//   Future<Configuration?> get() async {
//     configuration ??= await repository.get();
//     return configuration;
//   }

//   Future<void> update(Configuration config) async {
//     await repository.update(config);
//     configuration = config;
//   }

//   Future<void> initialize() async {
//     try {
//       await get();
//     } catch (e) {
//       await repository.insert();
//     }

//     await get();
//   }
// }
