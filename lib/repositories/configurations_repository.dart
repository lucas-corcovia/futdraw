import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/models/configuration.dart';
import 'package:sqflite/sqflite.dart';

class ConfigurationsRepository {
  static const String table = 'configurations';

  Future<Configuration?> get() async {
    final db = await DBHelper.getDatabase();
    final result = await db.query(table);
    return result.map((map) => Configuration.fromJson(map)).firstOrNull;
  }

  Future<void> update(Configuration config) async {
    final db = await DBHelper.getDatabase();
    await db.update(table, {'isOnlySociety': config.isOnlySociety ? 1 : 0});
  }

  Future<void> insert() async {
    final db = await DBHelper.getDatabase();
    try {
      await db.insert(table, {'isOnlySociety': 0});
    } catch (e) {
      await DBHelper.initializeDatabase();
      await openDatabase(DBHelper.dbName, version: 2);
    }

    await openDatabase(DBHelper.dbName);
  }
}
