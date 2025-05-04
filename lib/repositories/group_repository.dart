import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/models/group.dart';

class GroupRepository {
  static const String table = 'groups';

  Future<bool> add(Group group) async {
    final db = await DBHelper.getDatabase();
    return await db.insert(table, {'nome': group.nome}) > 0;
  }

  Future<List<Group>> getAll() async {
    final db = await DBHelper.getDatabase();
    final result = await db.rawQuery(
      '''SELECT g.id, g.nome, COUNT(p.Id) as playersCount, SUM(CASE WHEN p.ehGoleiro = 1 THEN 1 ELSE 0 END) AS captainCount
         FROM $table AS g 
         LEFT JOIN players AS p ON g.id = p.grupoId
         GROUP BY g.id
      ''',
    );
    return result.map((map) => Group.fromJson(map)).toList();
  }

  Future<bool> delete(int id) async {
    final db = await DBHelper.getDatabase();
    return await db.delete(table, where: 'id = ?', whereArgs: [id]) > 0;
  }
}
