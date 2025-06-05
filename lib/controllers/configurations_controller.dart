import 'dart:convert';

import 'package:futdraw/models/configuration.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationsController {
  static const String _key = '_config';
  Configuration? configuration;
  static final ConfigurationsController _instance =
      ConfigurationsController._internal();
  factory ConfigurationsController() => _instance;
  ConfigurationsController._internal();

  save(Configuration config) async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(_key);

    if (result != null) {
      prefs.remove(_key);
    }

    final json = config.toJson();
    final jsonString = jsonEncode(json);

    await prefs.setString(_key, jsonString);
  }

  Future<void> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        configuration = Configuration(
          generationAlgorithm: GenerationAlgorithm.balanced,
          themeColor: ThemeColor.green,
        );
        await save(configuration!);

        return;
      }

      final json = jsonDecode(jsonString);
      configuration = Configuration.fromJson(json);
    } catch (e) {
      return;
    }
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
