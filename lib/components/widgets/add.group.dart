// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/enums/field_type.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class _TaticaSection extends StatelessWidget {
  final int playersPerTeam;
  final int goleiros;
  final int defensores;
  final int meias;
  final int atacantes;
  final void Function(int gol, int def, int mei, int ata) onChanged;

  const _TaticaSection({
    required this.playersPerTeam,
    required this.goleiros,
    required this.defensores,
    required this.meias,
    required this.atacantes,
    required this.onChanged,
  });

  int get _total => goleiros + defensores + meias + atacantes;

  @override
  Widget build(BuildContext context) {
    final isValid = _total == playersPerTeam;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Tática Padrão',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isValid
                        ? scheme.primaryContainer
                        : scheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_total / $playersPerTeam',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isValid
                          ? scheme.onPrimaryContainer
                          : scheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (!isValid) ...[
              const SizedBox(height: 6),
              Text(
                'A soma deve ser igual a $playersPerTeam jogadores por time',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Counter(
                  label: 'GOL',
                  value: goleiros,
                  onDecrement: () => onChanged(goleiros - 1, defensores, meias, atacantes),
                  onIncrement: () => onChanged(goleiros + 1, defensores, meias, atacantes),
                )),
                Expanded(child: _Counter(
                  label: 'DEF',
                  value: defensores,
                  onDecrement: () => onChanged(goleiros, defensores - 1, meias, atacantes),
                  onIncrement: () => onChanged(goleiros, defensores + 1, meias, atacantes),
                )),
                Expanded(child: _Counter(
                  label: 'MEI',
                  value: meias,
                  onDecrement: () => onChanged(goleiros, defensores, meias - 1, atacantes),
                  onIncrement: () => onChanged(goleiros, defensores, meias + 1, atacantes),
                )),
                Expanded(child: _Counter(
                  label: 'ATA',
                  value: atacantes,
                  onDecrement: () => onChanged(goleiros, defensores, meias, atacantes - 1),
                  onIncrement: () => onChanged(goleiros, defensores, meias, atacantes + 1),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = onTap != null
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _Counter({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CounterButton(
              icon: Icons.remove_circle_outline,
              onTap: value > 0 ? onDecrement : null,
            ),
            const SizedBox(width: 6),
            Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            _CounterButton(
              icon: Icons.add_circle_outline,
              onTap: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

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
  late int _taticaGoleiros;
  late int _taticaDefensores;
  late int _taticaMeias;
  late int _taticaAtacantes;
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
      final defaults = _defaultTatica(_fieldType);
      _taticaGoleiros = group.taticaGoleiros ?? defaults[0];
      _taticaDefensores = group.taticaDefensores ?? defaults[1];
      _taticaMeias = group.taticaMeias ?? defaults[2];
      _taticaAtacantes = group.taticaAtacantes ?? defaults[3];
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
      final defaults = _defaultTatica(FieldType.campo);
      _taticaGoleiros = defaults[0];
      _taticaDefensores = defaults[1];
      _taticaMeias = defaults[2];
      _taticaAtacantes = defaults[3];
    }
  }

  List<int> _defaultTatica(FieldType type) {
    switch (type) {
      case FieldType.quadra:   return [1, 1, 2, 1];
      case FieldType.society:  return [1, 2, 3, 1];
      case FieldType.campo:    return [1, 4, 4, 2];
      case FieldType.livre:    return [0, 0, 0, 0];
    }
  }

  void _aplicarTaticaPadrao(FieldType tipo) {
    final defaults = _defaultTatica(tipo);
    _taticaGoleiros = defaults[0];
    _taticaDefensores = defaults[1];
    _taticaMeias = defaults[2];
    _taticaAtacantes = defaults[3];
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: const Color.fromRGBO(0, 0, 0, 0.6),
      child: Scaffold(
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
                        _aplicarTaticaPadrao(value);
                      });
                    }
                  },
                ),

                if (_fieldType != FieldType.livre) ...[
                  const SizedBox(height: 16),
                  _TaticaSection(
                    playersPerTeam: _playersPerTeam,
                    goleiros: _taticaGoleiros,
                    defensores: _taticaDefensores,
                    meias: _taticaMeias,
                    atacantes: _taticaAtacantes,
                    onChanged: (gol, def, mei, ata) => setState(() {
                      _taticaGoleiros = gol;
                      _taticaDefensores = def;
                      _taticaMeias = mei;
                      _taticaAtacantes = ata;
                    }),
                  ),
                ],

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
      ),
    );
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    context.loaderOverlay.show();

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
      taticaGoleiros: _fieldType != FieldType.livre ? _taticaGoleiros : null,
      taticaDefensores: _fieldType != FieldType.livre ? _taticaDefensores : null,
      taticaMeias: _fieldType != FieldType.livre ? _taticaMeias : null,
      taticaAtacantes: _fieldType != FieldType.livre ? _taticaAtacantes : null,
    );

    if (_isEditing) {
      await groupController.update(context, group);
    } else {
      await groupController.add(context, group);
    }
    context.loaderOverlay.hide();
    Navigator.pop(context);
  }
}
