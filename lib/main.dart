import 'package:flutter/material.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart' as statemanagement;

void main() {
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
          seedColor: Colors.blue,
          // ···
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeView(),
    );
  }
}
