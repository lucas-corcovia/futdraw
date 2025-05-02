import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String dbName = 'futdraw.db';
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return openDatabase(path, version: 1);
  }

  static Future<void> dropDataBase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    await deleteDatabase(path);
  }

  static Future<void> createDataBase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE players(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          grupoId INTEGER,
          nome TEXT,
          nota REAL,
          ehGoleiro INTEGER,
          urlFoto TEXT,
          posicao INTEGER
        )
      ''');

        return db.execute('''
        CREATE TABLE groups(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT
        )
      ''');
      },
    );
  }
}
