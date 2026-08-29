import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:futdraw/controllers/attendance_controller.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/match_controller.dart';
import 'package:futdraw/controllers/member_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/controllers/ranking_controller.dart';
import 'package:futdraw/controllers/result_controller.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/utils/theme.selector.dart';
import 'package:futdraw/views/rsvp_handler_view.dart';
import 'package:futdraw/views/splash_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
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
        ChangeNotifierProvider(
          create: (_) => MatchController(sl.matchRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceController(sl.attendanceRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ResultController(sl.resultRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RankingController(sl.statsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MemberController(sl.memberRepository),
        ),
      ],
      child: FutDrawApp(isLoggedIn: sl.authService.isLoggedIn),
    ),
  );
}

class FutDrawApp extends StatefulWidget {
  final bool isLoggedIn;

  const FutDrawApp({super.key, required this.isLoggedIn});

  @override
  State<FutDrawApp> createState() => _FutDrawAppState();
}

class _FutDrawAppState extends State<FutDrawApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen(_handleLink);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  void _handleLink(Uri uri) {
    // futdraw://partidas/{id}
    if (uri.scheme == 'futdraw' && uri.host == 'partidas') {
      final partidaId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (partidaId != null && partidaId.isNotEmpty) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => RsvpHandlerView(partidaId: partidaId)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigurationsController>(
      builder: (context, controller, _) {
        return MaterialApp(
          title: 'FutDraw',
          navigatorKey: navigatorKey,
          theme: ThemeSelector.build(controller.configuration.themeColor, false),
          darkTheme: ThemeSelector.build(controller.configuration.themeColor, true),
          themeMode: controller.configuration.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: SplashScreen(isLoggedIn: widget.isLoggedIn),
        );
      },
    );
  }
}
