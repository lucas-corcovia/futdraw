import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String dbName = 'futdraw.db';

  /// Retorna a instância do banco de dados, criando se necessário
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  /// Cria as tabelas do banco de dados
  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grupoId INTEGER,
        nome TEXT,
        nota REAL,
        urlFoto TEXT,
        posicao INTEGER,
        capitao INTEGER DEFAULT 0,
        reserva INTEGER DEFAULT 0
      );
    ''');
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT
      );
    ''');
  }

  /// Remove o banco de dados local
  static Future<void> dropDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    if (await databaseExists(path)) {
      await deleteDatabase(path);
    }
  }

  /// Inicializa o banco de dados se não existir
  static Future<void> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    if (!await databaseExists(path)) {
      await getDatabase();
    }
  }

  /// Exporta o banco de dados para a pasta Documents
  static Future<File?> exportDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFilePath = join(dbPath, dbName);

      // Fecha o banco se estiver aberto para garantir flush dos dados
      final db = await openDatabase(dbFilePath);
      await db.close();

      final dbFile = File(dbFilePath);
      if (!await dbFile.exists()) return null;

      var documentsDir = await _getDefaultExportDirectory();
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final exportFile = File(join(documentsDir.path, '${dbName}_backup.db'));

      await dbFile.copy(exportFile.path);
      return exportFile;
    } catch (e) {
      return null;
    }
  }

  static Future<Directory> _getDefaultExportDirectory() async {
    if (Platform.isAndroid) {
      final downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir != null) {
        final downloadsPath = Directory('${downloadsDir.path}/Downloads');
        if (await downloadsPath.exists()) {
          return downloadsPath;
        } else {
          await downloadsPath.create(recursive: true);
          return downloadsPath;
        }
      } else {
        throw Exception(
          'Não foi possível acessar o diretório de armazenamento externo.',
        );
      }
    } else if (Platform.isIOS) {
      final downloadsDir = await getApplicationDocumentsDirectory();
      return Directory('${downloadsDir.path}/Downloads');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final downloadsDir = Directory(
        '${Platform.environment['USERPROFILE'] ?? Platform.environment['HOME']}/Downloads',
      );
      return downloadsDir;
    } else {
      throw UnsupportedError(
        'Plataforma não suportada para exportação de banco de dados.',
      );
    }
  }

  static Future<Directory> getDefaultDatabaseStorage() =>
      _getDefaultExportDirectory();

  static Future<bool> importDatabaseFromFile(String importFilePath) async {
    try {
      final importFile = File(importFilePath);
      if (!await importFile.exists()) return false;

      final dbFolder = await getDatabasesPath();
      final dbFilePath = join(dbFolder, dbName);
      if (await File(dbFilePath).exists()) {
        await deleteDatabase(dbFilePath);
      }

      await importFile.copy(dbFilePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, dbName);
  }
}
