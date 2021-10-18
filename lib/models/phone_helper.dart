import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

final String phoneTable = "phoneTable";
final String idColumn = "idColumn";
final String contactIdColumn = "contactIdColumn";
final String phoneColumn = "phoneColumn";

class PhoneHelper {
  static final PhoneHelper _instance = PhoneHelper.internal();

  factory PhoneHelper() => _instance;

  PhoneHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();

    final path = join(databasesPath, "contacts.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newerVersion) async {
        await db.execute(
            "CREATE TABLE $phoneTable($idColumn INTEGER PRIMARY KEY, $phoneColumn TEXT, $contactIdColumn INTEGER)");
      },
    );
  }

  Future<Phone> savePhone(Phone phone) async {
    Database dbPhone = await db;
    phone.id = await dbPhone.insert(phoneTable, phone.toMap());
    return phone;
  }

  Future<Phone> getPhone(int id) async {
    Database dbPhone = await db;
    List<Map> maps = await dbPhone.query(
      phoneTable,
      columns: [idColumn, phoneColumn, contactIdColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Phone.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletePhone(int id) async {
    Database dbPhone = await db;
    return await dbPhone.delete(
      phoneTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updatePhone(Phone phone) async {
    Database dbPhone = await db;
    return await dbPhone.update(
      phoneTable,
      phone.toMap(),
      where: "$idColumn = ?",
      whereArgs: [phone.id],
    );
  }

  Future<int> getNumber() async {
    Database dbPhone = await db;
    return Sqflite.firstIntValue(
        await dbPhone.rawQuery("SELECT COUNT(*) FROM  $phoneTable"));
  }

  close() async {
    Database dbPhone = await db;
    dbPhone.close();
  }
}

class Phone {
  int id;
  int contact_id;
  String phone;

  Phone();

  void setPhone(String phone) => this.phone = phone;

  Phone.fromMap(Map map) {
    id = map[idColumn];
    contact_id = map[contactIdColumn];
    phone = map[phoneColumn];
  }

  Map toMap() {
    Map<String, dynamic> newMap = {
      phoneColumn: phone,
    };
    if (id != null) {
      newMap[idColumn] = id;
    }

    return newMap;
  }

  @override
  String toString() {
    return "Phone (id: $id, phone: $phone, contact_id: $contact_id)";
  }
}
