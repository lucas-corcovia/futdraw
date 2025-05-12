import 'package:futdraw/models/configuration.dart';
import 'package:futdraw/repositories/configurations_repository.dart';

class ConfigurationsController {
  final ConfigurationsRepository repository = ConfigurationsRepository();
  Configuration? configuration;

  static final ConfigurationsController _instance =
      ConfigurationsController._internal();
  factory ConfigurationsController() => _instance;
  ConfigurationsController._internal();

  Future<Configuration?> get() async {
    configuration ??= await repository.get();
    return configuration;
  }

  Future<void> update(Configuration config) async {
    await repository.update(config);
    configuration = config;
  }

  Future<void> initialize() async {
    try {
      await get();
    } catch (e) {
      await repository.insert();
    }

    await get();
  }
}
