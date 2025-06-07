// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/configurations_controller.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/components/dialogs/import_database_dialog.dart';
import 'package:futdraw/components/dialogs/export_database_dialog.dart';
import 'package:futdraw/models/enums/generation_algorithm.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatefulWidget {
  const DrawerComponent({super.key});

  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  @override
  Widget build(BuildContext context) {
    var isProduction = bool.fromEnvironment('dart.vm.product');

    return Drawer(
      elevation: 8,
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
          ListTile(
            leading: Icon(Icons.shuffle),
            title: Row(
              children: [
                Expanded(
                  child: Consumer<ConfigurationsController>(
                    builder: (context, controller, _) {
                      return DropdownButton<GenerationAlgorithm>(
                        isExpanded: true,
                        value: controller.configuration.generationAlgorithm,
                        items:
                            GenerationAlgorithm.values.map((alg) {
                              return DropdownMenuItem(
                                value: alg,
                                child: Text(alg.label),
                              );
                            }).toList(),
                        onChanged: (value) async {
                          if (value == null) return;

                          controller.setAlgorithm(value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Row(
              children: [
                Expanded(
                  child: Consumer<ConfigurationsController>(
                    builder: (context, controller, _) {
                      return DropdownButton<ThemeColor>(
                        isExpanded: true,
                        value: controller.configuration.themeColor,
                        items:
                            ThemeColor.values.map((color) {
                              return DropdownMenuItem(
                                value: color,
                                child: Text(color.label),
                              );
                            }).toList(),
                        onChanged: (value) async {
                          if (value == null) return;

                          controller.setTheme(value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
