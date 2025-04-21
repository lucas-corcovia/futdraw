import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String dbName = 'futdraw.db';
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE players(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT,
          nota REAL,
          ehGoleiro INTEGER,
          urlFoto TEXT
        )
      ''');
      },
    );
  }

  static Future<void> dropDataBase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    await deleteDatabase(path);
  }
}
