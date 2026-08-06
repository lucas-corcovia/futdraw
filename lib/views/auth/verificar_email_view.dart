// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart';

class VerificarEmailView extends StatefulWidget {
  final String email;

  const VerificarEmailView({super.key, required this.email});

  @override
  State<VerificarEmailView> createState() => _VerificarEmailViewState();
}

class _VerificarEmailViewState extends State<VerificarEmailView> {
  final _codigoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _segundos = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _segundos = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos == 0) {
        t.cancel();
        return;
      }
      setState(() => _segundos--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthController>().confirmarEmail(
          widget.email,
          _codigoController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeView()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar e-mail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.mark_email_unread_outlined,
                    size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'Enviamos um código de 6 dígitos para',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 8),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Código de verificação',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Digite o código de 6 dígitos'
                      : null,
                ),
                Consumer<AuthController>(
                  builder: (_, controller, __) {
                    if (controller.errorMessage != null &&
                        controller.status == AuthStatus.error) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 8),
                Consumer<AuthController>(
                  builder: (_, controller, __) => FilledButton(
                    onPressed:
                        controller.status == AuthStatus.loading ? null : _confirmar,
                    child: controller.status == AuthStatus.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirmar'),
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<AuthController>(
                  builder: (_, controller, __) => TextButton(
                    onPressed: _segundos > 0
                        ? null
                        : () {
                            context
                                .read<AuthController>()
                                .reenviarCodigo(widget.email);
                            _iniciarTimer();
                          },
                    child: Text(
                      _segundos > 0
                          ? 'Reenviar código em ${_segundos}s'
                          : 'Reenviar código',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
