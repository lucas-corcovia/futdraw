import 'dart:convert';

import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/models/player.dart';

class PlayerRepository {
  static const String table = 'players';

  Future<void> add(Player player) async {
    final db = await DBHelper.getDatabase();
    await db.insert(table, {
      'nome': player.nome,
      'nota': player.nota,
      'ehGoleiro': player.ehGoleiro ? 1 : 0,
      'urlFoto': player.urlFoto,
    });
  }

  Future<List<Player>> getAll() async {
    final db = await DBHelper.getDatabase();
    final result = await db.query(table);
    String jsonString = jsonEncode(result);
    print(jsonString);
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<Player?> getById(int id) async {
    final db = await DBHelper.getDatabase();
    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);

    return result.isNotEmpty ? Player.fromMap(result.first) : null;
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.getDatabase();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Player player) async {
    final db = await DBHelper.getDatabase();

    await db.update(
      table,
      {
        'nome': player.nome,
        'nota': player.nota,
        'ehGoleiro': player.ehGoleiro ? 1 : 0,
        'urlFoto': player.urlFoto,
      },
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }
}
