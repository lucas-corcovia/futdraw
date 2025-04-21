import 'dart:convert';
import 'dart:io';
import 'package:futdraw/models/imgbb.dart';
import 'package:http/http.dart' as http;

class ImgBBRepository {
  Future<ImgBbResult?> uploadImage(File imageFile) async {
    final apiKey = 'd7d23b3f9da79554e95f5732e46c2a50';

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final response = await http.post(
      uri,
      body: {'key': apiKey, 'image': base64Image},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      var result = ImgBbResult.fromJson(json);

      return result;
    }

    return null;
  }
}
