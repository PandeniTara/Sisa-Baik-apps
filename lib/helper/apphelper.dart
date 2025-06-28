import 'package:sisa_baik/models/donasi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sumbangan_app.db');

    return await openDatabase(
      path,
      version: 3,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            noHp TEXT,
            foto TEXT,
            totalSumbangan INTEGER DEFAULT 0,
            totalPoin INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE donasi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            jumlah TEXT NOT NULL,
            catatan TEXT NOT NULL,
            imagePath TEXT,
            jenisMakanan TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            userId INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------------- USERS ----------------

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<double> sumJumlahDonasiByUserId(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(jumlah) as total FROM donasi WHERE userId = ?',
      [userId],
    );
    return result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // ---------------- DONASI ----------------

  Future<int> insertDonasi(Donasi donasi) async {
    final db = await database;
    return await db.insert('donasi', donasi.toMap());
  }

  Future<List<Donasi>> getAllDonasi() async {
    final db = await database;
    final result = await db.query('donasi');
    return result.map((map) => Donasi.fromMap(map)).toList();
  }

  Future<List<Donasi>> getDonasiByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'donasi',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Donasi.fromMap(map)).toList();
  }

  Future<int> updateDonasi(Donasi donasi) async {
    final db = await database;
    return await db.update(
      'donasi',
      donasi.toMap(),
      where: 'id = ?',
      whereArgs: [donasi.id],
    );
  }

  Future<int> deleteDonasi(int id) async {
    final db = await database;
    return await db.delete('donasi', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- CLOSE ----------------

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
