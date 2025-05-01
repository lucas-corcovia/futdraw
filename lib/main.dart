import 'package:flutter/material.dart';
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
        primaryColor: Color.fromRGBO(79, 53, 155, 1.0),
        fontFamily: 'Kanit',
        brightness: Brightness.dark,
      ),
      home: const HomeView(),
    );
  }
}
