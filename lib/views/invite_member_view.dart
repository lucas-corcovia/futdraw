// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/member_controller.dart';
import 'package:futdraw/models/enums/papel_membro.dart';
import 'package:futdraw/models/group.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class InviteMemberView extends StatefulWidget {
  final Group group;

  const InviteMemberView({super.key, required this.group});

  @override
  State<InviteMemberView> createState() => _InviteMemberViewState();
}

class _InviteMemberViewState extends State<InviteMemberView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  PapelMembro _papel = PapelMembro.membro;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    context.loaderOverlay.show();

    final success = await context.read<MemberController>().invite(
      context,
      widget.group.id,
      _emailController.text.trim(),
      _papel,
    );

    context.loaderOverlay.hide();
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: const Color.fromRGBO(0, 0, 0, 0.6),
      child: Scaffold(
        appBar: AppBar(title: const Text('Convidar Membro')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.person_add),
              label: const Text('Convidar'),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<PapelMembro>(
                value: _papel,
                decoration: const InputDecoration(
                  labelText: 'Papel',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PapelMembro.admin,
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: PapelMembro.membro,
                    child: Text('Membro'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _papel = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
