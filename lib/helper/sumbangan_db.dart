// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/sumbangan_model.dart';
// import '../models/user_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDb();
//     return _database!;
//   }

//   Future<Database> _initDb() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'sumbangan_app.db');

//     return await openDatabase(
//       path,
//       version: 5, // 🆙 Upgrade ke versi terbaru
//       onCreate: (db, version) async {
//         await _createTables(db);
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute('ALTER TABLE sumbangan ADD COLUMN latitude REAL');
//           await db.execute('ALTER TABLE sumbangan ADD COLUMN longitude REAL');
//         }
//         if (oldVersion < 3) {
//           await db.execute('ALTER TABLE sumbangan ADD COLUMN userId INTEGER');
//         }
//         if (oldVersion < 4) {
//           // Tambahkan kolom jika hilang atau buat ulang jika sebelumnya tidak ada
//           await _createTables(db);
//         }
//       },
//     );
//   }

//   Future<void> _createTables(Database db) async {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS users (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nama TEXT,
//         username TEXT,
//         password TEXT,
//         noHp TEXT,
//         foto TEXT,
//         totalSumbangan INTEGER DEFAULT 0,
//         totalPoin INTEGER DEFAULT 0
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS sumbangan (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         nama TEXT,
//         jumlah TEXT,
//         catatan TEXT,
//         imagePath TEXT,
//         jenisMakanan TEXT,
//         latitude REAL,
//         longitude REAL,
//         userId INTEGER,
//         FOREIGN KEY (userId) REFERENCES users(id)
//       )
//     ''');
//   }

//   // ================= USERS ===================

//   Future<int> insertUser(User user) async {
//     final db = await database;
//     return await db.insert('users', user.toMap());
//   }

//   Future<User?> getUserById(int id) async {
//     final db = await database;
//     final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
//     if (result.isNotEmpty) return User.fromMap(result.first);
//     return null;
//   }

//   Future<User?> getUserByUsername(String username) async {
//     final db = await database;
//     final result = await db.query(
//       'users',
//       where: 'username = ?',
//       whereArgs: [username],
//     );
//     if (result.isNotEmpty) return User.fromMap(result.first);
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

//   // ================= SUMBANGAN ===================

//   Future<int> insertSumbangan(Sumbangan s) async {
//     final db = await database;

//     final id = await db.insert('sumbangan', s.toMap());

//     if (s.userId != null) {
//       final jumlah =
//           int.tryParse(s.jumlah.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

//       print('Jumlah donasi ditambahkan: $jumlah');

//       final user = await getUserById(s.userId!);
//       if (user != null) {
//         final updatedUser = user.copyWith(
//           totalSumbangan: user.totalSumbangan + jumlah,
//           totalPoin: user.totalPoin + 10,
//         );

//         print('User sebelumnya: ${user.totalSumbangan}');
//         print('User sesudahnya: ${updatedUser.totalSumbangan}');

//         await updateUser(updatedUser);
//       }
//     }

//     return id;
//   }

//   Future<List<Sumbangan>> getAllSumbangan() async {
//     final db = await database;
//     final result = await db.query('sumbangan');
//     return result.map((e) => Sumbangan.fromMap(e)).toList();
//   }

//   Future<List<Sumbangan>> getSumbanganByUserId(int userId) async {
//     final db = await database;
//     final result = await db.query(
//       'sumbangan',
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return result.map((e) => Sumbangan.fromMap(e)).toList();
//   }

//   Future<int> deleteSumbangan(int id) async {
//     final db = await database;
//     return await db.delete('sumbangan', where: 'id = ?', whereArgs: [id]);
//   }

//   // ================= GENERAL ===================

//   Future<void> deleteDatabaseFile() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'sumbangan_app.db');
//     await deleteDatabase(path);
//     print('🗑️ Database berhasil dihapus: $path');
//   }
// }
