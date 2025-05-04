import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/repositories/imgbb_repository.dart';
import 'package:image_picker/image_picker.dart';

class ImgBBController {
  final imgBBRepository = ImgBBRepository();
  final playerController = PlayerController();

  Future<String?> uploadAndSaveImage(
    BuildContext context,
    File? imageFile,
  ) async {
    try {
      if (imageFile == null) {
        return null;
      }
      var result = await imgBBRepository.uploadImage(imageFile);
      return result?.data.url;
    } catch (e) {
      Toast.show(context, 'Erro ao fazer upload da imagem: $e', true);
      return null;
    }
  }

  Future<File?> selectImage(
    BuildContext context,
    ImageSource imageSource,
    int playerId,
  ) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: imageSource);

    if (image != null) {
      File selectedImage = File(image.path);
      return selectedImage;
    }
    return null;
  }
}
