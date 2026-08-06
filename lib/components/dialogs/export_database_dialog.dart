import 'package:flutter/material.dart';
import 'package:futdraw/helpers/db_helper.dart';

class ExportDatabaseDialog extends StatefulWidget {
  const ExportDatabaseDialog({super.key});

  @override
  State<ExportDatabaseDialog> createState() => _ExportDatabaseDialogState();
}

class _ExportDatabaseDialogState extends State<ExportDatabaseDialog> {
  bool _isLoading = false;
  String? _message;

  Future<void> _exportDatabase() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final file = await DBHelper.exportDatabase();
      setState(() {
        if (file != null) {
          _message = 'Banco exportado para: ${file.path}';
        } else {
          _message = 'Falha ao exportar banco.';
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Erro ao exportar: $e';
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
      title: const Text('Exportar Banco de Dados'),
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
          child: const Text('Fechar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _exportDatabase,
          child: Text('Exportar', style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
