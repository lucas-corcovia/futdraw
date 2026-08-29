// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/attendance_controller.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/data/models/responses/match_response.dart';
import 'package:futdraw/models/enums/status_presenca.dart';
import 'package:futdraw/views/auth/login_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RsvpHandlerView extends StatefulWidget {
  final String partidaId;

  const RsvpHandlerView({super.key, required this.partidaId});

  @override
  State<RsvpHandlerView> createState() => _RsvpHandlerViewState();
}

class _RsvpHandlerViewState extends State<RsvpHandlerView> {
  MatchResponse? _match;
  bool _loading = true;
  bool _submitting = false;
  StatusPresenca? _responded;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatch();
  }

  Future<void> _loadMatch() async {
    final result = await ServiceLocator().matchDataSource.getById(widget.partidaId);
    if (!mounted) return;
    result.when(
      success: (m) => setState(() {
        _match = m;
        _loading = false;
      }),
      error: (msg) => setState(() {
        _error = msg;
        _loading = false;
      }),
    );
  }

  Future<void> _respond(StatusPresenca status) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final success = await context
        .read<AttendanceController>()
        .respond(context, widget.partidaId, status);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      setState(() => _responded = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.read<AuthController>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Presença')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(isLoggedIn),
        ),
      ),
    );
  }

  Widget _buildBody(bool isLoggedIn) {
    if (!isLoggedIn) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            'Entre na sua conta para confirmar presença',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginView()),
              (_) => false,
            ),
            child: const Text('Fazer Login'),
          ),
        ],
      );
    }

    if (_loading) return const CircularProgressIndicator();

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _loadMatch, child: const Text('Tentar novamente')),
        ],
      );
    }

    if (_responded != null) {
      final labels = {
        StatusPresenca.confirmado: ('Presença confirmada!', Icons.check_circle, Colors.green),
        StatusPresenca.recusado: ('Presença recusada.', Icons.cancel, Colors.red),
        StatusPresenca.talvez: ('Marcado como talvez.', Icons.help, Colors.orange),
      };
      final (msg, icon, color) = labels[_responded]!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(msg, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            _formatDate(_match?.dataHora),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      );
    }

    final match = _match!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports_soccer, color: scheme.primary),
                    const SizedBox(width: 8),
                    const Text('Partida', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_formatDate(match.dataHora), style: Theme.of(context).textTheme.titleMedium),
                if (match.local != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(match.local!),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${match.totalConfirmados} confirmado(s)',
                  style: TextStyle(color: scheme.outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Você vai comparecer?',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_submitting)
          const Center(child: CircularProgressIndicator())
        else ...[
          FilledButton.icon(
            onPressed: () => _respond(StatusPresenca.confirmado),
            icon: const Icon(Icons.check_circle),
            label: const Text('Vou!'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _respond(StatusPresenca.talvez),
            icon: const Icon(Icons.help),
            label: const Text('Talvez'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _respond(StatusPresenca.recusado),
            icon: const Icon(Icons.cancel),
            label: const Text('Não vou'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat("EEEE, dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(dt.toLocal());
  }
}
