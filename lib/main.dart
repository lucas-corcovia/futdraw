import 'package:flutter/material.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/utils/theme.selector.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart' as statemanagement;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initializeDatabase();
  await ConfigurationsController().get();

  runApp(
    statemanagement.MultiProvider(
      providers: [
        statemanagement.ChangeNotifierProvider(
          create: (_) => PlayerController(),
        ),
        statemanagement.ChangeNotifierProvider(
          create: (_) => GroupController(),
        ),
        statemanagement.ChangeNotifierProvider(
          create: (_) => ConfigurationsController(),
        ),
        // Adicione mais providers aqui, se necessário
      ],
      child: FutDrawApp(),
    ),
  );
}

class FutDrawApp extends StatelessWidget {
  const FutDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigurationsController>(
      builder: (context, controller, _) {
        return MaterialApp(
          title: 'FutDraw',
          theme: ThemeSelector.get(controller.configuration.themeColor),
          home: const HomeView(),
        );
      },
    );
  }
}
