import 'package:sqflite/sqflite.dart'; // Zaten import etmiş olman lazım
import 'package:path/path.dart'; // Zaten import etmiş olman lazım
import 'package:flutter_application_1/models/pet.dart'; // Kendi proje adın!

class DBHelper {
  static Database? _db; // Database sınıfı sqflite'tan geliyor
  static const String _dbName = 'pawcare.db';
  static const int _dbVersion = 1;
  static const String _petTable = 'pets';

  Future<Database> get database async { // Database sqflite'tan
    if (_db != null) {
      return _db!;
    }
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async { // Database sqflite'tan
    final dbPath = await getDatabasesPath(); // getDatabasesPath sqflite'tan
    final path = join(dbPath, _dbName); // join, path paketinden

    return await openDatabase( // openDatabase sqflite'tan
        path,
        version: _dbVersion,
        onCreate: _onCreate
    );
  }

    Future<void> _onCreate(Database db, int version) async { // Database sqflite
      await db.execute('''
      CREATE TABLE $_petTable (
        id TEXT PRIMARY KEY,
        name TEXT,
        species TEXT,
        breed TEXT,
        birthDate TEXT,
        gender TEXT,
        photoUrl TEXT
      )
    ''');
  }

  Future<int> insertPet(Pet pet) async { // Pet, senin model sınıfın
    final db = await database;
    return await db.insert(_petTable, pet.toJson());
  }

  Future<List<Pet>> getAllPets() async { // Pet
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_petTable);

    return List.generate(maps.length, (i) {
      return Pet.fromJson(maps[i]); // Pet.fromJson senin modelinde olmalı
    });
  }

 Future<int> updatePetDB(Pet pet) async {
    final db = await database;
    return await db.update(
      _petTable,
      pet.toJson(),
      where: 'id = ?',
      whereArgs: [pet.id],
    );
}

  Future<int> deletePetDB(String id) async {
  final db = await database;
  return await db.delete(
    _petTable,
    where: 'id = ?',
    whereArgs: [id],
  );
}
}