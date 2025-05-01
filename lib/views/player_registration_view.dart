// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:futdraw/components/button.dart';
import 'package:futdraw/components/modal.dart';
import 'package:futdraw/components/text_field.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/controllers/imgbb_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/utils/money_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PlayerRegistrationView extends StatelessWidget {
  PlayerRegistrationView({super.key});

  final _formKey = GlobalKey<FormState>();
  Player player = Player.getInstance();
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PlayerController>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jogadores'),
            Text(
              'Total: ${controller.players.length}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          player = Player.getInstance();
          showDialog(
            context: context,
            builder:
                (context) => CustomModal(
                  titulo: 'Cadastrar jogador',
                  content: _modalContent(context, controller),
                ),
          );
        },
        tooltip: 'Adicionar',
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
      body: _bodyContent(),
    );
  }

  Widget _modalContent(
    BuildContext context,
    PlayerController controller, {
    Player? playerBd,
  }) {
    if (playerBd != null) {
      player = playerBd;
    }
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              label: 'Nome',
              controller: TextEditingController(text: player.nome),
              onChanged: (value) {
                player.nome = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Informe o nome";
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomTextFormField(
              label: 'Nota',
              controller: DecimalRangeController(),
              keyboardType: TextInputType.numberWithOptions(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
              ],
              onChanged: (value) {
                player.nota = value.toDouble();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Informe a nota";
                }

                if (value.toDouble() < 0 || value.toDouble() > 10) {
                  return "Informe uma nota entre 0 a 10";
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return Checkbox(
                      value: player.ehGoleiro,
                      onChanged: (bool? value) {
                        setModalState(() {
                          player.ehGoleiro = value ?? false;
                        });
                      },
                    );
                  },
                ),
                Text("É goleiro?", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: playerBd == null ? 'Adicionar' : 'Atualizar',
              icon: playerBd == null ? Icons.add : Icons.replay,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (playerBd == null) {
                    await controller.add(player);
                  } else {
                    await controller.update(player);
                  }

                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _bodyContent() {
    return Consumer<PlayerController>(
      builder: (context, controller, child) {
        return controller.players.isNotEmpty
            ? ListView.builder(
              itemCount: controller.players.length,
              itemBuilder: (context, index) {
                final player =
                    controller.players.sorted(
                      (a, b) => b.ehGoleiro ? 1 : (a.ehGoleiro ? -1 : 0),
                    )[index];

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: InkWell(
                      onTap: () async {
                        await _selectImage(player, context, controller);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage:
                            player.urlFoto == null
                                ? AssetImage('assets/images/user.png')
                                : NetworkImage(player.urlFoto!),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          player.nome ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        player.ehGoleiro
                            ? Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('(Goleiro)'),
                            )
                            : SizedBox(),
                      ],
                    ),
                    subtitle: Text('Nota: ${player.nota?.toString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.edit,
                            color: Colors.black87,
                            size: 25,
                          ),
                          onTap: () async {
                            if (player.id != null) {
                              var playerBd = await controller.getById(
                                player.id!,
                              );

                              showDialog(
                                context: context,
                                builder:
                                    (context) => CustomModal(
                                      titulo: 'Atualizar jogador',
                                      content: _modalContent(
                                        context,
                                        controller,
                                        playerBd: playerBd,
                                      ),
                                    ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          child: Icon(
                            Icons.delete,
                            color: Colors.red.shade800,
                            size: 25,
                          ),
                          onTap: () async {
                            if (player.id != null) {
                              await showDialog(
                                context: context,
                                builder:
                                    (context) => CustomModal(
                                      titulo: 'Excluir jogador',
                                      content: Column(
                                        children: [
                                          Text(
                                            'Deseja excluir o jogador ${player.nome}?',
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: CustomButton(
                                                  text: 'Sim',
                                                  icon: Icons.check_circle,
                                                  onPressed: () async {
                                                    await controller.delete(
                                                      player.id!,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: CustomButton(
                                                  text: 'Não',
                                                  icon: Icons.cancel,
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
            : Image.asset('assets/images/jogador_nao_encontrado.png');
      },
    );
  }

  Future<void> _selectImage(
    Player player,
    BuildContext context,
    PlayerController controller,
  ) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File selectedImage = File(image.path);
      final imgBBController = ImgBBController();

      var result = await imgBBController.uploadAndSaveImage(
        selectedImage,
        player.id!,
      );

      if (!result) {
        Toast.show(context, 'Ocorreu um erro ao selecionar imagem!');
      }

      await controller.getAll();
    }
  }
}
