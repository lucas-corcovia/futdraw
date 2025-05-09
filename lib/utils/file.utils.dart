import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class FileUtils {
  /// Share a file on mobile platforms
  static Future<void> shareFileMobile(
    Uint8List bytes,
    String fileName,
    String mimeType, {
    String? subject,
    String? text,
  }) async {
    try {
      // Get a temporary directory to store the file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';

      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final params = ShareParams(
        text: text,
        files: [XFile(filePath, mimeType: mimeType)],
      );

      // Share the file
      await SharePlus.instance.share(params);
    } catch (e) {
      rethrow; // Let the caller handle the error
    }
  }

  /// Generate a unique filename with timestamp
  static String generateUniqueFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${baseName}_$timestamp.$extension';
  }
}
