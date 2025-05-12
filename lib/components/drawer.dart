// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatelessWidget {
  DrawerComponent({super.key});
  final ConfigurationsController _configController = ConfigurationsController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.reset_tv),
            title: Text('Resetar'),
            onTap: () async {
              await DBHelper.dropDataBase();
              await DBHelper.createDataBase();
              context.read<GroupController>().getAll();
            },
          ),
          ListTile(
            leading: Icon(Icons.sports_soccer),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Modo Society'),
                Switch(
                  value:
                      _configController.configuration?.isOnlySociety == null
                          ? false
                          : _configController.configuration!.isOnlySociety,
                  onChanged: (value) async {
                    _configController.configuration?.isOnlySociety = value;
                    await _configController.update(
                      _configController.configuration!,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
