import 'package:flutter/material.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/utils/theme.selector.dart';
import 'package:futdraw/views/auth/login_view.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.initialize();

  // Instância única: carrega config salva antes de montar o widget tree
  final configurationsController = ConfigurationsController();
  await configurationsController.init();

  final sl = ServiceLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerController(sl.playerRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupController(sl.groupRepository),
        ),
        // Reutiliza a instância já inicializada (não cria uma nova limpa)
        ChangeNotifierProvider.value(value: configurationsController),
        ChangeNotifierProvider(
          create: (_) => AuthController(sl.authDataSource, sl.authService),
        ),
      ],
      child: FutDrawApp(isLoggedIn: sl.authService.isLoggedIn),
    ),
  );
}

class FutDrawApp extends StatelessWidget {
  final bool isLoggedIn;

  const FutDrawApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigurationsController>(
      builder: (context, controller, _) {
        return MaterialApp(
          title: 'FutDraw',
          theme: ThemeSelector.build(controller.configuration.themeColor, false),
          darkTheme: ThemeSelector.build(controller.configuration.themeColor, true),
          themeMode: controller.configuration.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: isLoggedIn ? const HomeView() : const LoginView(),
        );
      },
    );
  }
}
