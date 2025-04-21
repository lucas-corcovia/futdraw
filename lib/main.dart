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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(79, 53, 155, 1.0),
        fontFamily: 'Kanit',
      ),
      home: const HomeView(),
    );
  }
}
