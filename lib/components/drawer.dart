// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/views/draw_view.dart';
import 'package:futdraw/views/player_registration_view.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_sharp),
            title: Text('Cadastro de jogadores'),
            onTap: () async {
              await Provider.of<PlayerController>(
                context,
                listen: false,
              ).getAll();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerRegistrationView(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Sorteio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DrawView()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.reset_tv),
            title: Text('Resetar'),
            onTap: () async {
              await DBHelper.dropDataBase();
            },
          ),
        ],
      ),
    );
  }
}
