// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/match_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/match.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class ScheduleMatchView extends StatefulWidget {
  final Group group;
  final Match? match;

  const ScheduleMatchView({super.key, required this.group, this.match});

  @override
  State<ScheduleMatchView> createState() => _ScheduleMatchViewState();
}

class _ScheduleMatchViewState extends State<ScheduleMatchView> {
  final _formKey = GlobalKey<FormState>();
  final _localController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool get _isEditing => widget.match != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedDate = widget.match!.dataHora;
      _selectedTime = TimeOfDay.fromDateTime(widget.match!.dataHora);
      _localController.text = widget.match!.local ?? '';
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = _defaultTime();
      _localController.text = widget.group.localPadrao ?? '';
    }
  }

  TimeOfDay _defaultTime() {
    final horario = widget.group.horarioJogo;
    if (horario == null) return const TimeOfDay(hour: 20, minute: 0);
    final parts = horario.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 20, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    context.loaderOverlay.show();

    final dataHora = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final local =
        _localController.text.trim().isEmpty
            ? null
            : _localController.text.trim();

    final controller = context.read<MatchController>();
    final success = _isEditing
        ? await controller.update(context, widget.match!.id, dataHora, local)
        : await controller.schedule(
            context,
            widget.group.id,
            dataHora,
            local,
          );

    context.loaderOverlay.hide();
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final timeLabel = _selectedTime.format(context);

    return LoaderOverlay(
      overlayColor: const Color.fromRGBO(0, 0, 0, 0.6),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Partida' : 'Agendar Partida'),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Salvar' : 'Agendar'),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Data e Horário',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dateLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(timeLabel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(
                  labelText: 'Local (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
