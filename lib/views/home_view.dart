import 'package:flutter/material.dart';
import 'package:futdraw/components/drawer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'FutDraw - Sorteador de times',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: DrawerComponent(),
      body: Image.asset('assets/images/home.png'),
    );
  }
}
