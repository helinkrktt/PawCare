import 'package:sqflite/sqflite.dart'; // Zaten import etmiş olman lazım
import 'package:path/path.dart'; // Zaten import etmiş olman lazım
import 'package:flutter_application_1/models/pet.dart'; // Kendi proje adın!

class DBHelper {
  static Database? _db; // Database sınıfı sqflite'tan geliyor
  static const String _dbName = 'pawcare.db';
  static const int _dbVersion = 2; // Versiyon numarasını artırdım
  static const String _petTable = 'pets';

  Future<Database> get database async {
    // Database sqflite'tan
    if (_db != null) {
      return _db!;
    }
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // Database sqflite'tan
    final dbPath = await getDatabasesPath(); // getDatabasesPath sqflite'tan
    final path = join(dbPath, _dbName); // join, path paketinden

    return await openDatabase(
        // openDatabase sqflite'tan
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Database sqflite
    await db.execute('''
      CREATE TABLE $_petTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT,
        birthDate TEXT,
        gender TEXT,
        weight REAL,
        color TEXT,
        microchipNumber TEXT,
        photoUrl TEXT,
        notes TEXT,
        lastVetVisit TEXT,
        nextVetVisit TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Yeni sütunları ekle
      await db.execute('ALTER TABLE $_petTable ADD COLUMN weight REAL');
      await db.execute('ALTER TABLE $_petTable ADD COLUMN color TEXT');
      await db
          .execute('ALTER TABLE $_petTable ADD COLUMN microchipNumber TEXT');
      await db.execute('ALTER TABLE $_petTable ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE $_petTable ADD COLUMN lastVetVisit TEXT');
      await db.execute('ALTER TABLE $_petTable ADD COLUMN nextVetVisit TEXT');
      await db.execute('ALTER TABLE $_petTable ADD COLUMN createdAt TEXT');
      await db.execute('ALTER TABLE $_petTable ADD COLUMN updatedAt TEXT');
    }
  }

  Future<int> insertPet(Pet pet) async {
    // Pet, senin model sınıfın
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final petData = pet.toJson();
    petData['createdAt'] = now;
    petData['updatedAt'] = now;
    return await db.insert(_petTable, petData);
  }

  Future<List<Pet>> getAllPets() async {
    // Pet
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_petTable);

    return List.generate(maps.length, (i) {
      return Pet.fromJson(maps[i]); // Pet.fromJson senin modelinde olmalı
    });
  }

  Future<Pet?> getPetById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _petTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Pet.fromJson(maps.first);
  }

  Future<int> updatePetDB(Pet pet) async {
    final db = await database;
    final petData = pet.toJson();
    petData['updatedAt'] = DateTime.now().toIso8601String();
    return await db.update(
      _petTable,
      petData,
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