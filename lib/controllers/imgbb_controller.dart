import 'dart:io';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/repositories/imgbb_repository.dart';

class ImgBBController {
  final imgBBRepository = ImgBBRepository();
  final playerController = PlayerController();

  Future<bool> uploadAndSaveImage(File imageFile, int playerId) async {
    try {
      var result = await imgBBRepository.uploadImage(imageFile);

      if (result != null) {
        var playerBd = await playerController.getById(playerId);
        if (playerBd != null) {
          playerBd.urlFoto = result.data.url;
          await playerController.update(playerBd);
        }
      }
    } catch (e) {
      return false;
    }

    return true;
  }
}
