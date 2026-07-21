import 'dart:io';
import 'package:path_provider/path_provider.dart';

// SQLite persistence was removed in favour of the REST API.
// This stub keeps old imports compiling.
class DBHelper {
  static Future<void> initializeDatabase() async {}
  static Future<void> dropDatabase() async {}
  static Future<File> exportDatabase() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/export.json');
  static Future<Directory> getDefaultDatabaseStorage() async =>
      getApplicationDocumentsDirectory();
  static Future<bool> importDatabaseFromFile(String path) async => false;
}
