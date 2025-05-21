// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/components/dialogs/import_database_dialog.dart';
import 'package:futdraw/components/dialogs/export_database_dialog.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    var isProduction = bool.fromEnvironment('dart.vm.product');

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
          if (!isProduction)
            ListTile(
              leading: Icon(Icons.reset_tv),
              title: Text('Resetar'),
              onTap: () async {
                await DBHelper.dropDatabase();
                await DBHelper.initializeDatabase();
                context.read<GroupController>().getAll();
              },
            ),
          if (!isProduction)
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Exportar Banco de dados'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ExportDatabaseDialog(),
                );
              },
            ),
          if (!isProduction)
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Importar Banco de dados'),
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => const ImportDatabaseDialog(),
                );
                if (result == true) {
                  context.read<GroupController>().getAll();
                }
              },
            ),
        ],
      ),
    );
  }
}
