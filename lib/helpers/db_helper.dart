import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  static Future<void> initializeDataBase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    if (await databaseExists(path)) return;

    await createDataBase();
  }

  static Future<void> createDataBase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    await openDatabase(
      path,
      version: 2,
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

        db.execute('''
        CREATE TABLE groups(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT
        )
      ''');

        db.execute('''
        CREATE TABLE configurations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          isOnlySociety INTEGER
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('''
          CREATE TABLE configurations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isOnlySociety INTEGER
          )
        ''');
        }
      },
    );
  }

  static Future<void> exportDatabase() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestStoragePermission();
    });

    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, dbName));

    if (!await dbFile.exists()) return;

    final directory = await getExternalStorageDirectory();
    final documentsDir = Directory('${directory!.path}/Documents');
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }

    final exportFile = File(join(documentsDir.path, '${dbName}_backup.db'));

    await dbFile.copy(exportFile.path);
  }

  static Future<bool> importDatabase() async {
    final directory = await getExternalStorageDirectory();
    final documentsDir = Directory('${directory!.path}/Documents');
    final result = await FilePicker.platform.pickFiles(
      initialDirectory: documentsDir.path,
    );

    if (result == null && result!.files.single.path == null) return false;

    final importFile = File(result.files.single.path!);

    final dbFolder = await getDatabasesPath();
    final dbFilePath = join(dbFolder, dbName);

    await deleteDatabase(dbFilePath);

    final dbFile = File(dbFilePath);
    await dbFile.writeAsBytes(await importFile.readAsBytes());
    return true;
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }
}
