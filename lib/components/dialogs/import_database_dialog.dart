import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:futdraw/helpers/db_helper.dart';

class ImportDatabaseDialog extends StatefulWidget {
  const ImportDatabaseDialog({super.key});

  @override
  State<ImportDatabaseDialog> createState() => _ImportDatabaseDialogState();
}

class _ImportDatabaseDialogState extends State<ImportDatabaseDialog> {
  bool _isLoading = false;
  String? _message;

  Future<void> _importDatabase() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final directory = await DBHelper.getDefaultDatabaseStorage();
        final success = await DBHelper.importDatabaseFromFile(directory.path);
        setState(() {
          _message =
              success
                  ? 'Banco importado com sucesso!'
                  : 'Falha ao importar banco.';
        });
      } else {
        setState(() {
          _message = 'Nenhum arquivo selecionado.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erro ao importar: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar Banco de Dados'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading) const CircularProgressIndicator(),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Fechar', style: Theme.of(context).textTheme.bodyLarge),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _importDatabase,
          child: Text(
            'Selecionar Arquivo',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
