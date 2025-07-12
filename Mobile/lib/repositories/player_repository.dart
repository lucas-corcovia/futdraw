import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/models/player.dart';

class PlayerRepository {
  static const String table = 'players';

  Future<void> add(Player player) async {
    final db = await DBHelper.getDatabase();
    await db.insert(table, {
      'nome': player.nome,
      'nota': player.nota,
      'capitao': player.ehCapitao ? 1 : 0,
      'reserva': player.reserva ? 1 : 0,
      'urlFoto': player.urlFoto,
      'grupoId': player.grupoId,
      'posicao': player.position.index,
    });
  }

  Future<void> addMany(List<Player> players) async {
    final db = await DBHelper.getDatabase();
    final batch = db.batch();
    for (final player in players) {
      batch.insert(table, {
        'nome': player.nome,
        'nota': player.nota,
        'capitao': player.ehCapitao ? 1 : 0,
        'reserva': player.reserva ? 1 : 0,
        'urlFoto': player.urlFoto,
        'grupoId': player.grupoId,
        'posicao': player.position.index,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Player>> getAll() async {
    final db = await DBHelper.getDatabase();
    final result = await db.query(table);
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<Player?> getById(int id) async {
    final db = await DBHelper.getDatabase();
    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);

    return result.isNotEmpty ? Player.fromMap(result.first) : null;
  }

  Future<List<Player>> getAllByGroupId(int groupId) async {
    final db = await DBHelper.getDatabase();
    final result = await db.query(
      table,
      where: 'grupoId = ?',
      whereArgs: [groupId],
    );

    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<void> delete(Player player) async {
    final db = await DBHelper.getDatabase();
    await db.delete(table, where: 'id = ?', whereArgs: [player.id]);
  }

  Future<void> update(Player player) async {
    final db = await DBHelper.getDatabase();

    await db.update(
      table,
      {
        'nome': player.nome,
        'nota': player.nota,
        'capitao': player.ehCapitao ? 1 : 0,
        'reserva': player.reserva ? 1 : 0,
        'urlFoto': player.urlFoto,
        'grupoId': player.grupoId,
        'posicao': player.position.index,
      },
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }
}
