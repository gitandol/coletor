import 'package:coletor_patrimonio/db/register.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class Manager {
  Manager._();

  static String DB_NAME = "patrimonio.db";
  static final Manager instance = Manager._();
  static Database? _database;

  get database async {
    // await deleteDatabase(join(await getDatabasesPath(), DB_NAME));

    if (_database != null) return _database;
    return await _initDatabase();
  }



  _initDatabase() async {
    String path = join(await getDatabasesPath(), DB_NAME);
    return openDatabase(
      path, version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  _onCreate(Database db, int version) async {
    for (var table in createTables){
      await db.execute(table);
    }
    print('--- ${createTables.length} tables created ---');
  }
}