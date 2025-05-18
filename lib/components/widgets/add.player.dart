// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futdraw/controllers/imgbb_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddPlayer extends StatefulWidget {
  final Player? player;
  final Group group;

  const AddPlayer({super.key, this.player, required this.group});

  @override
  State<AddPlayer> createState() => _AddPlayerState();
}

class _AddPlayerState extends State<AddPlayer> {
  final _formKey = GlobalKey<FormState>();
  final _imgController = ImgBBController();

  late int _id;
  late int _groupId;
  late String _name;
  late double _skillRating;
  PlayerPosition _position = PlayerPosition.midfielder;
  late bool _isCaptain;
  late bool _isSubstitute;
  String? _photoPath;
  bool _isEditing = false;
  final bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.player != null;
    _initPlayer();
  }

  _initPlayer() {
    if (_isEditing) {
      _id = widget.player!.id;
      _groupId = widget.player!.grupoId;
      _name = widget.player!.nome;
      _skillRating = widget.player!.nota;
      _position = widget.player!.position;
      _isCaptain = widget.player!.ehCapitao;
      _photoPath = widget.player!.urlFoto;
      _isSubstitute = widget.player!.reserva;
      return;
    }

    _id = 0;
    _groupId = widget.group.id;
    _name = "";
    _skillRating = 5.0;
    _isCaptain = false;
    _isSubstitute = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Jogador' : 'Novo Jogador'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _formContent(context)),
    );
  }

  Padding _formContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player Photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: getProfilePicture(),
                    child:
                        _photoPath == null && _imageFile == null
                            ? Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<ImageSource>(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        onSelected: (ImageSource value) async {
                          var imageFile = await _imgController.selectImage(
                            context,
                            value,
                            _id,
                          );
                          setState(() {
                            _imageFile = imageFile;
                          });
                        },
                        itemBuilder:
                            (BuildContext context) =>
                                <PopupMenuEntry<ImageSource>>[
                                  const PopupMenuItem<ImageSource>(
                                    value: ImageSource.camera,
                                    child: ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text('Câmera'),
                                    ),
                                  ),
                                  const PopupMenuItem<ImageSource>(
                                    value: ImageSource.gallery,
                                    child: ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text('Galeria'),
                                    ),
                                  ),
                                ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Player Name
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(
                labelText: 'Nome do Jogador',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o nome do jogador';
                }
                return null;
              },
              onSaved: (value) {
                _name = value!;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.group.nome,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Turma/Grupo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe a turma ou grupo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Position Selection
            DropdownButtonFormField<PlayerPosition>(
              value: _position,
              decoration: const InputDecoration(
                labelText: 'Posição',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: PlayerPosition.goalkeeper,
                  child: Text('Goleiro'),
                ),
                DropdownMenuItem(
                  value: PlayerPosition.defender,
                  child: Text('Defensor'),
                ),
                const DropdownMenuItem(
                  value: PlayerPosition.midfielder,
                  child: Text('Meio-Campo'),
                ),
                const DropdownMenuItem(
                  value: PlayerPosition.striker,
                  child: Text('Atacante'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _position = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habilidade: ${_skillRating.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    thumbColor: Theme.of(context).colorScheme.secondary,
                    trackHeight: 8.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20.0,
                    ),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 10.0,
                    divisions: 100,
                    value: _skillRating,
                    onChanged: (value) {
                      setState(() {
                        _skillRating = value;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1.0', style: Theme.of(context).textTheme.bodySmall),
                    Text('10.0', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Capitão de Time'),
              subtitle: const Text('Designar este jogador como capitão'),
              activeColor: Theme.of(context).colorScheme.tertiary,
              value: _isCaptain,
              onChanged: (value) {
                setState(() {
                  _isCaptain = value;
                });
              },
              secondary: Icon(
                Icons.stars,
                color:
                    _isCaptain
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.outline,
              ),
            ),
            SwitchListTile(
              title: const Text('Reserva'),
              subtitle: const Text('Este jogador ficará no banco de reservas'),
              activeColor: Theme.of(context).colorScheme.tertiary,
              value: _isSubstitute,
              onChanged: (value) {
                setState(() {
                  _isSubstitute = value;
                });
              },
              secondary: Icon(
                Icons.chair_rounded,
                color:
                    _isSubstitute
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _savePlayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Salvar', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!_isEditing) {
      await context.read<PlayerController>().add(context, await _buildPlayer());
    } else {
      await context.read<PlayerController>().update(
        context,
        await _buildPlayer(),
      );
    }

    Navigator.pop(context);
  }

  Future<Player> _buildPlayer() async {
    var urlFoto = await getPhotoPath();
    return Player(
      id: _id,
      grupoId: _groupId,
      nome: _name,
      nota: _skillRating,
      ehCapitao: _isCaptain,
      reserva: _isSubstitute,
      urlFoto: urlFoto,
      position: _position,
    );
  }

  Future<String?> getPhotoPath() async {
    if (_imageFile == null) return widget.player?.urlFoto;

    return await _imgController.uploadAndSaveImage(context, _imageFile);
  }

  ImageProvider? getProfilePicture() {
    if (_imageFile != null) return FileImage(_imageFile!);

    return _photoPath == null ? null : NetworkImage(_photoPath!);
  }
}
