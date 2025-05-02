import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/models/group.dart';

class GroupRepository {
  static const String table = 'groups';

  Future<bool> add(Group group) async {
    final db = await DBHelper.getDatabase();
    return await db.insert(table, {'nome': group.nome}) > 0;
  }

  // Example method to get all groups
  Future<List<Group>> getAll() async {
    final db = await DBHelper.getDatabase();
    final result = await db.rawQuery(
      '''SELECT g.id, g.nome, COUNT(p.Id) as playersCount FROM $table AS g 
         LEFT JOIN players AS p ON g.id = p.grupoId
         GROUP BY g.id
      ''',
    );
    return result.map((map) => Group.fromJson(map)).toList();
  }

  // Example method to delete a group
  Future<bool> delete(int id) async {
    final db = await DBHelper.getDatabase();
    return await db.delete(table, where: 'id = ?', whereArgs: [id]) > 0;
  }
}
