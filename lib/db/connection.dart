import 'package:coletor_patrimonio/db/register.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


Future<Database> getDatabase() async {
  String path = join(await getDatabasesPath(), databaseName);
  print(path);
  await deleteDatabase(path);
  return openDatabase(
    path, version: 1,
    onCreate: (Database db, int version) async {
      print('--- create tables ---');
      for (var table in createTables){
        await db.execute(table);
      }
      print('--- ${createTables.length} tables created ---');
    },
  );
}