import 'package:flutter/material.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart' as statemanagement;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper.initializeDataBase();

  runApp(
    statemanagement.MultiProvider(
      providers: [
        statemanagement.ChangeNotifierProvider(
          create: (_) => PlayerController(),
        ),
        statemanagement.ChangeNotifierProvider(
          create: (_) => GroupController(),
        ),
        // Adicione mais providers aqui, se necessário
      ],
      child: const FutDrawApp(),
    ),
  );
}

class FutDrawApp extends StatelessWidget {
  const FutDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutDraw',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(2, 0, 94, 0),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Kanit',
      ),
      home: const HomeView(),
    );
  }
}
