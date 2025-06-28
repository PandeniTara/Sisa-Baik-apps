// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/donasi_model.dart';

// class DonasiDatabase {
//   static final DonasiDatabase _instance = DonasiDatabase._internal();
//   factory DonasiDatabase() => _instance;
//   DonasiDatabase._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'sumbangan_app.db');

//     return await openDatabase(
//       path,
//       version: 2,
//       onOpen: (db) async {
//         await db.execute('PRAGMA foreign_keys = ON');
//       },
//       onCreate: (db, version) async {
//         // Jika kamu pisahkan dengan UserDatabase, pastikan ini sinkron
//         await db.execute('''
//           CREATE TABLE IF NOT EXISTS users (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             nama TEXT NOT NULL,
//             username TEXT NOT NULL UNIQUE,
//             password TEXT NOT NULL,
//             noHp TEXT,
//             foto TEXT,
//             totalSumbangan INTEGER DEFAULT 0,
//             totalPoin INTEGER DEFAULT 0
//           )
//         ''');
//       },
//     );
//   }

//   Future<int> insertDonasi(Donasi donasi) async {
//     final db = await database;
//     return await db.insert('donasi', donasi.toMap());
//   }

//   Future<List<Donasi>> getAllDonasi() async {
//     final db = await database;
//     final result = await db.query('donasi');

//     return result.map((map) => Donasi.fromMap(map)).toList();
//   }

//   Future<List<Donasi>> getDonasiByUserId(int userId) async {
//     final db = await database;
//     final result = await db.query(
//       'donasi',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );

//     return result.map((map) => Donasi.fromMap(map)).toList();
//   }

//   Future<int> updateDonasi(Donasi donasi) async {
//     final db = await database;
//     return await db.update(
//       'donasi',
//       donasi.toMap(),
//       where: 'id = ?',
//       whereArgs: [donasi.id],
//     );
//   }

//   Future<int> deleteDonasi(int id) async {
//     final db = await database;
//     return await db.delete('donasi', where: 'id = ?', whereArgs: [id]);
//   }

//   Future close() async {
//     final db = await database;
//     db.close();
//   }
// }
