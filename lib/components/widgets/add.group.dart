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
  late bool _isEditing;
  late String _name;
  late List<String> _gameDays;
  late String _gameTime;
  String? _avatarPath;
  late bool _fixedGoalkeepers;
  late int _maxStarters;
  late String _defaultLocation;
  late FieldType _fieldType;
  late int _gameTimeMinutes;
  late int _playersPerTeam;
  final _formKey = GlobalKey<FormState>();

  final List<String> _weekDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.group != null;

    if (_isEditing) {
      final group = widget.group!;
      _name = group.nome;
      _gameDays = List<String>.from(group.diasDeJogo);
      _gameTime = group.horarioJogo ?? '';
      _avatarPath = group.urlAvatar;
      _fixedGoalkeepers = group.goleirosFixos;
      _maxStarters = group.limiteTitulares;
      _defaultLocation = group.localPadrao ?? '';
      _fieldType = group.tipoCampo.toFieldType();
      _gameTimeMinutes = group.duracaoJogoMinutos;
      _playersPerTeam = group.jogadoresPorTime;
    } else {
      _name = '';
      _gameDays = [];
      _gameTime = '';
      _avatarPath = null;
      _fixedGoalkeepers = false;
      _maxStarters = 22;
      _defaultLocation = '';
      _fieldType = FieldType.campo;
      _gameTimeMinutes = 90;
      _playersPerTeam = FieldType.campo.defaultPlayersPerTeam;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Grupo' : 'Adicionar Grupo'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _saveGroup,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Grupo'),
          ),
        ),
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
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _weekDays.map((day) {
                        final isSelected = _gameDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _gameDays.add(day);
                              } else {
                                _gameDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _gameTime,
                  decoration: const InputDecoration(
                    labelText: 'Horário do Jogo',
                    hintText: 'Ex: 19:00 às 21:00',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  onChanged: (value) => _gameTime = value.trim(),
                ),

                const SizedBox(height: 16),

                // Default Location
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

                // Field Type
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
                    if (value != null) {
                      setState(() {
                        _fieldType = value;
                        if (value != FieldType.livre) {
                          _playersPerTeam = value.defaultPlayersPerTeam;
                          _maxStarters = _playersPerTeam * 2;
                        }
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Players per Team (only for 'Livre' field type)
                if (_fieldType == FieldType.livre)
                  TextFormField(
                    initialValue: _playersPerTeam.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Jogadores por Time',
                      hintText: 'Inclui o goleiro',
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

                const SizedBox(height: 16),

                // Game Duration
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

                // Max Starters
                TextFormField(
                  initialValue: _maxStarters.toString(),
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
                    if (limit == null || limit < _playersPerTeam * 2) {
                      return 'Mínimo ${_playersPerTeam * 2} (2 teams completos)';
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

                // Fixed Goalkeepers Switch
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final groupController = context.read<GroupController>();

    final jogadoresPorTime = _fieldType == FieldType.livre
        ? _playersPerTeam
        : _fieldType.defaultPlayersPerTeam;

    final group = Group(
      id: _isEditing ? widget.group!.id : '',
      nome: _name,
      diasDeJogo: _gameDays,
      horarioJogo: _gameTime.trim().isEmpty ? null : _gameTime.trim(),
      localPadrao: _defaultLocation.trim().isEmpty ? null : _defaultLocation.trim(),
      tipoCampo: _fieldType.name,
      jogadoresPorTime: jogadoresPorTime,
      duracaoJogoMinutos: _gameTimeMinutes,
      limiteTitulares: _maxStarters,
      goleirosFixos: _fixedGoalkeepers,
      urlAvatar: _avatarPath,
    );

    if (_isEditing) {
      await groupController.update(context, group);
    } else {
      await groupController.add(context, group);
    }
    Navigator.pop(context);
  }
}
