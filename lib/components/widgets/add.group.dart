import 'package:flutter/material.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_isEditing ? 'Editar' : 'Adicionar'} Grupo"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: Container()),
    );
  }
}
