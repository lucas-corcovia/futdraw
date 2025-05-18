import 'package:flutter/material.dart';
import 'import_database_dialog.dart';
import 'export_database_dialog.dart';

class DatabaseActionsMenu extends StatelessWidget {
  const DatabaseActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Banco de Dados'),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => const ImportDatabaseDialog(),
            );
          },
          child: const Text('Importar Banco'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => const ExportDatabaseDialog(),
            );
          },
          child: const Text('Exportar Banco'),
        ),
      ],
    );
  }
}
