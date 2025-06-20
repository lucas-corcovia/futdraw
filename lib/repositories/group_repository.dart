import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/models/group.dart';

class GroupRepository {
  static const String table = 'groups';

  Future<bool> add(Group group) async {
    final db = await DBHelper.getDatabase();
    return await db.insert(table, group.toUpdate()) > 0;
  }

  Future<List<Group>> getAll() async {
    final db = await DBHelper.getDatabase();
    final result = await db.rawQuery('''
          SELECT 
            g.id,
            g.nome,
            g.avatarPath,
            g.gameDays,
            g.fixedGoalkeepers,
            g.maxStarters,
            g.defaultLocation,
            g.fieldType,
            g.gameTime,
            g.gameTimeMinutes,
            g.playersPerTeam,
            COUNT(p.Id) as totalPlayersCount,
            SUM(CASE WHEN p.capitao = 1 THEN 1 ELSE 0 END) AS captainCount,
            SUM(CASE WHEN p.reserva = 1 THEN 1 ELSE 0 END) AS substituteCount,
            SUM(CASE WHEN p.posicao = 0 THEN 1 ELSE 0 END) AS goalkeppersCount,
            SUM(CASE WHEN p.reserva = 0 THEN 1 ELSE 0 END) AS playersCount
          FROM $table AS g 
          LEFT JOIN players AS p ON g.id = p.grupoId
          GROUP BY g.id
      ''');
    return result.map((map) => Group.fromJson(map)).toList();
  }

  Future<bool> delete(int id) async {
    final db = await DBHelper.getDatabase();
    return await db.delete(table, where: 'id = ?', whereArgs: [id]) > 0;
  }

  Future<bool> update(Group group) async {
    final db = await DBHelper.getDatabase();
    final result = await db.update(
      table,
      group.toUpdate(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
    return result > 0;
  }
}
