import 'package:futdraw/models/interfaces/migration.dart';
import 'package:sqflite/sqflite.dart';

class AlterGroupNewFields implements Migration {
  @override
  Future<void> up(Database db) async {
    db.transaction((txn) async {
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN gameDays TEXT DEFAULT '[]';",
      );
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN gameTime TEXT DEFAULT '00:00';",
      );
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN fixedGoalkeepers INTEGER DEFAULT 0;",
      );
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN maxStarters INTEGER DEFAULT 0;",
      );
      await txn.execute("ALTER TABLE groups ADD COLUMN defaultLocation TEXT;");
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN fieldType INTEGER DEFAULT 0;",
      );
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN gameTimeMinutes INTEGER DEFAULT 0;",
      );
      await txn.execute(
        "ALTER TABLE groups ADD COLUMN playersPerTeam INTEGER DEFAULT 0;",
      );
      await txn.execute("ALTER TABLE groups ADD COLUMN avatarPath TEXT;");
    });
  }

  @override
  Future<void> down(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('ALTER TABLE groups RENAME TO groups_temp;');

      await txn.execute('''
      CREATE TABLE groups(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT
        );
      ''');

      await txn.execute('''
      INSERT INTO groups (id, nome)
      SELECT id, nome FROM groups_temp;
      ''');

      await txn.execute('DROP TABLE groups_temp;');
    });
  }
}
