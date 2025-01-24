import 'package:coletor_patrimonio/db/manager.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'registro';
const String columnId = 'id';
const String columnPai = 'pai_id';
const String columnNome = 'nome';
const String columnTipo = 'tipo';

const createTableRegistro = '''
  CREATE TABLE IF NOT EXISTS $tableName ( 
    $columnId INTEGER PRIMARY KEY autoincrement, 
    $columnPai INTEGER,
    $columnNome TEXT NOT NULL,
    $columnTipo TEXT NOT NULL,
    FOREIGN KEY ($columnPai) REFERENCES $tableName ($columnId) ON DELETE CASCADE
  )
''';

class Registro {
  late Database db;

  int? id;
  int? pai;
  String? nome;
  String? tipo;

  Registro({this.id, this.pai, required this.tipo, required this.nome});

  Registro.fromJson(Map<String, dynamic> json) {
    id = json[columnId];
    pai = json[columnPai];
    nome = json[columnNome];
    tipo = json[columnTipo];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[columnId] = id;
    data[columnPai] = pai;
    data[columnNome] = nome;
    data[columnTipo] = tipo;
    return data;
  }

  Future<Registro?> insert() async {
    db = await Manager.instance.database;
    try{
      id = await db.insert(tableName, toMap());
      return this;
    } catch (ex) {
      print('Erro: $ex');
      return null;
    }
  }

  Future<List<String>> path({required List<String> local}) async {
    // Registro? registro = await Registro.get(id: pai);
    // if (registro != null){
    //   local.insert(0, registro.nome.toString());
    //   if (registro.pai != null){
    //     local = await registro.path(local: local);
    //   }
    // } else {
    //   if (local.isEmpty){
    //     local.add("Início");
    //   }
    // }
    // return local;

    if (pai != null){
      Registro? registro = await Registro.get(id: pai);
      if (registro != null){
        local.insert(0, registro.nome.toString());
        local = await registro.path(local: local);
      }
    } else {
      if (local.isEmpty){
        local.add("Início");
      }
    }
    return local;
  }

  static Future<Registro?> get({
    id, pai, nome, tipo
  }) async {
    // Get a reference to the database.
    Database db = await Manager.instance.database;
    List<String> args = [];
    if (id != null){ args.add("id=$id"); }
    if (pai != null){ args.add("$columnPai=$pai"); }
    if (nome != null){ args.add("$columnNome='$nome'"); }
    if (tipo != null){ args.add("$columnTipo=$tipo"); }

    String select = 'SELECT * FROM $tableName';
    if (args.isNotEmpty) { select += " WHERE ${args.join(" and ")}"; };
    final List<Map<String, Object?>> objects = await db.rawQuery(select);

    if (objects.isNotEmpty){
      return Registro.fromJson(objects.last);
    }

    return null;
  }

  static Future<List<Registro>> filter({
    id, pai, nome, tipo
  }) async {
    // Get a reference to the database.
    Database db = await Manager.instance.database;
    List<String> args = [];
    if (id != null){ args.add("id=$id"); }
    if (pai != null){ args.add("$columnPai=$pai"); }
    if (nome != null){ args.add("$columnNome='$nome'"); }
    if (tipo != null){ args.add("$columnTipo=$tipo"); }

    if (args.isEmpty){ args.add("$columnPai is null"); }

    String select = 'SELECT * FROM $tableName';
    if (args.isNotEmpty) { select += " WHERE ${args.join(" and ")} ORDER BY $columnTipo DESC"; };
    final List<Map<String, Object?>> objects = await db.rawQuery(select);

    List<Registro> lista = [];
    for (var object in objects){
      lista.add(Registro.fromJson(object));
    }
    return lista;
  }

  Future<int> delete() async {
    db = await Manager.instance.database;
    int deleted = 0;

    if (id != 0){
      deleted = await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } else {
      deleted = await db.delete(tableName, where: 'id != ?', whereArgs: [id]);
    }
    return deleted;
  }

  Future<int> update() async {
    db = await Manager.instance.database;
    int updated = 0;

    if (id != null){
      updated = await db.update(
          tableName,
          toMap(),
          where: "id = ?",
          whereArgs: [id]
      );
    }
    return updated;
  }

}