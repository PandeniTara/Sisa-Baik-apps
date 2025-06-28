// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/user_model.dart';

// class UserDatabase {
//   static final UserDatabase _instance = UserDatabase._internal();
//   factory UserDatabase() => _instance;
//   UserDatabase._internal();

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
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE users (
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
//       onUpgrade: (db, oldVersion, newVersion) async {
//         // Tidak perlu tambahkan kolom foto lagi, sudah ada di onCreate
//         // Tambahkan migrasi lainnya jika nanti versi naik lagi
//       },
//       onOpen: (db) async {
//         // Aktifkan foreign key support jika nanti pakai relasi
//         await db.execute('PRAGMA foreign_keys = ON');
//       },
//     );
//   }

//   Future<int> insertUser(User user) async {
//     final db = await database;
//     return await db.insert('users', user.toMap());
//   }

//   Future<User?> getUser(String username, String password) async {
//     final db = await database;
//     final result = await db.query(
//       'users',
//       where: 'username = ? AND password = ?',
//       whereArgs: [username, password],
//     );
//     if (result.isNotEmpty) {
//       return User.fromMap(result.first);
//     }
//     return null;
//   }

//   Future<User?> getUserById(int id) async {
//     final db = await database;
//     final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
//     if (result.isNotEmpty) {
//       return User.fromMap(result.first);
//     }
//     return null;
//   }

//   Future<User?> getUserByUsername(String username) async {
//     final db = await database;
//     final result = await db.query(
//       'users',
//       where: 'username = ?',
//       whereArgs: [username],
//     );
//     if (result.isNotEmpty) {
//       return User.fromMap(result.first);
//     }
//     return null;
//   }

//   Future<int> updateUser(User user) async {
//     final db = await database;
//     return await db.update(
//       'users',
//       user.toMap(),
//       where: 'id = ?',
//       whereArgs: [user.id],
//     );
//   }

//   Future close() async {
//     final db = await database;
//     db.close();
//   }
// }
