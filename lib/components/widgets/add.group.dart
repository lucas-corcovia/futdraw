import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:provider/provider.dart';

enum FieldType { quadra, campo, society, livre }

class AddGroup extends StatefulWidget {
  const AddGroup({super.key, this.group});
  final Group? group;

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final _formKey = GlobalKey<FormState>();

  late bool _isEditing;
  late String _name;
  late List<int> _gameDays;
  late String? _avatarPath;
  late bool _fixedGoalkeepers;
  late int _maxStarters;
  late String? _defaultLocation;
  late FieldType _fieldType;
  late int _gameTimeMinutes;
  late int _playersPerTeam;
  late TimeOfDay? _selectedTime;
  late TimeOfDay _gameTime;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.group != null;

    if (_isEditing) {
      final group = widget.group!;
      _name = group.nome;
      _gameDays = List<int>.from(group.gameDays);
      _gameTime = group.gameTime;
      _selectedTime = group.gameTime;
      _avatarPath = group.avatarPath;
      _fixedGoalkeepers = group.fixedGoalkeepers;
      _maxStarters = group.maxStarters;
      _defaultLocation = group.defaultLocation;
      _fieldType = group.fieldType;
      _gameTimeMinutes = group.gameTimeMinutes;
      _playersPerTeam = group.playersPerTeam;
    } else {
      _fieldType = FieldType.campo;
      var hoje = DateTime.now();
      _name = '';
      _gameDays = [hoje.day];
      _gameTime = TimeOfDay(hour: hoje.hour, minute: hoje.minute);
      _selectedTime = TimeOfDay(hour: hoje.hour, minute: hoje.minute);
      _avatarPath = null;
      _fixedGoalkeepers = false;
      _maxStarters = _fieldType.defaultPlayersPerTeam * 2;
      _defaultLocation = '';
      _gameTimeMinutes = 15;
      _playersPerTeam = _fieldType.defaultPlayersPerTeam;
    }
  }

  bool get teamsCompleted {
    final requiredPlayers = _playersPerTeam * 2;

    if (_fieldType == FieldType.livre) {
      return _maxStarters >= requiredPlayers;
    }

    return _playersPerTeam >= _fieldType.defaultPlayersPerTeam;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Grupo' : 'Adicionar Grupo'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.group),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o nome do grupo';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!.trim();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Dias de Jogo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children:
                      List.generate(DateTime.daysPerWeek, (index) {
                        var dayConverted = index + 1;
                        var selected = _gameDays.contains(dayConverted);
                        return ChoiceChip(
                          label: Text(dayConverted.daysInString),
                          selected: selected,
                          labelStyle: TextStyle(
                            color:
                                selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _gameDays.add(dayConverted);
                              } else {
                                _gameDays.remove(dayConverted);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectTime,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _formatTimeOfDay(_selectedTime ?? _gameTime),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Horário do Jogo',
                        hintText: 'Toque para selecionar',
                        prefixIcon: const Icon(Icons.access_time),
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _defaultLocation,
                  decoration: const InputDecoration(
                    labelText: 'Local Padrão',
                    hintText: 'Ex: Campo do Clube Central',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (value) => _defaultLocation = value.trim(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FieldType>(
                  value: _fieldType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Campo',
                    prefixIcon: Icon(Icons.sports_soccer),
                  ),
                  items:
                      FieldType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            '${type.displayName} ${type != FieldType.livre ? "(${type.defaultPlayersPerTeam} jogadores)" : ""}',
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _fieldType = value;
                      var playersPerTeam =
                          _fieldType == FieldType.livre
                              ? _playersPerTeam
                              : _fieldType.defaultPlayersPerTeam;

                      _maxStarters = playersPerTeam * 2;
                    });
                  },
                ),
                if (_fieldType == FieldType.livre) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _playersPerTeam.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Jogadores por Time',
                      hintText: 'Incluindo o goleiro',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantidade é obrigatória';
                      }
                      final players = int.tryParse(value);
                      if (players == null || players < 2) {
                        return 'Mínimo 2 jogadores por time';
                      }
                      if (players > 20) {
                        return 'Máximo 20 jogadores por time';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final players = int.tryParse(value);
                      if (players != null) {
                        _playersPerTeam = players;
                        setState(() {
                          _maxStarters = _playersPerTeam * 2;
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _gameTimeMinutes.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Duração do Jogo (minutos)',
                    hintText: 'Ex: 90',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Duração é obrigatória';
                    }
                    final minutes = int.tryParse(value);
                    if (minutes == null || minutes < 1) {
                      return 'Duração deve ser maior que 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final minutes = int.tryParse(value);
                    if (minutes != null) {
                      _gameTimeMinutes = minutes;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: TextEditingController(
                    text: _maxStarters.toString(),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Limite de Titulares',
                    hintText: 'Jogadores acima deste número viram reservas',
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Limite é obrigatório';
                    }
                    final limit = int.tryParse(value);
                    if (limit == null || !teamsCompleted) {
                      return 'Mínimo ${_playersPerTeam * 2} (2 times completos)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final limit = int.tryParse(value);
                    if (limit != null) {
                      _maxStarters = limit;
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Goleiros Fixos'),
                  subtitle: const Text(
                    'Goleiros não participam do sorteio de times',
                  ),
                  value: _fixedGoalkeepers,
                  onChanged: (value) {
                    setState(() {
                      _fixedGoalkeepers = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveGroup,
                  icon: Icon(
                    Icons.save,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    _isEditing ? 'Salvar alterações' : 'Adicionar',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _gameTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final groupController = context.read<GroupController>();

    final updatedGroup = Group(
      id: widget.group?.id ?? 0,
      nome: _name,
      defaultLocation: _defaultLocation,
      fieldType: _fieldType,
      fixedGoalkeepers: _fixedGoalkeepers,
      gameDays: _gameDays,
      gameTime: _gameTime,
      gameTimeMinutes: _gameTimeMinutes,
      maxStarters: _maxStarters,
      playersPerTeam: _playersPerTeam,
      avatarPath: _avatarPath,
    );

    if (_isEditing && widget.group != null) {
      await groupController.update(updatedGroup);
    } else {
      await groupController.add(updatedGroup);
    }

    Navigator.pop(context);
  }
}
