import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/kohort_model.dart';
import '../models/anggota_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'general_kohort.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kohort (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        alamat TEXT,
        deskripsi TEXT,
        tanggalDibuat TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE anggota (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kohortId INTEGER NOT NULL,
        nama TEXT NOT NULL,
        nik TEXT,
        tanggalLahir TEXT,
        jenisKelamin TEXT,
        namaOrangTua TEXT,
        alamat TEXT,
        keterangan TEXT,
        riwayatPenyakit TEXT,
        FOREIGN KEY (kohortId) REFERENCES kohort (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Operasi Kohort ---
  Future<int> insertKohort(Kohort kohort) async {
    Database db = await database;
    return await db.insert('kohort', kohort.toMap());
  }

  Future<List<Kohort>> getKohortList() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kohort',
      orderBy: 'tanggalDibuat DESC',
    );
    return List.generate(maps.length, (i) => Kohort.fromMap(maps[i]));
  }

  Future<int> deleteKohort(int id) async {
    Database db = await database;
    return await db.delete('kohort', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operasi Anggota ---
  Future<int> getAnggotaCount(int kohortId) async {
    Database db = await database;
    // Menggunakan sql raw query untuk menghitung jumlah baris
    var result = await db.rawQuery(
      'SELECT COUNT(*) FROM anggota WHERE kohortId = ?',
      [kohortId],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<int> insertAnggota(Anggota anggota) async {
    Database db = await database;
    return await db.insert('anggota', anggota.toMap());
  }

  Future<List<Anggota>> getAnggotaList(int kohortId) async {
    Database db = await database;
    final maps = await db.query(
      'anggota',
      where: 'kohortId = ?',
      whereArgs: [kohortId],
    );
    return List.generate(maps.length, (i) => Anggota.fromMap(maps[i]));
  }

  Future<int> deleteAnggota(int id) async {
    Database db = await database;
    return await db.delete('anggota', where: 'id = ?', whereArgs: [id]);
  }
}
