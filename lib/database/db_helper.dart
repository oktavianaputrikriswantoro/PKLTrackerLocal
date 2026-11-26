import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  DbHelper._privateConstructor();

  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final folder = await getDatabasesPath();
    final dbPath = join(folder, 'pkl_tracker_local.db');

    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profil (
            id INTEGER PRIMARY KEY,
            nama TEXT NOT NULL,
            nis TEXT NOT NULL,
            kelas TEXT NOT NULL,
            tempat_pkl TEXT NOT NULL,
            pembimbing_industri TEXT NOT NULL,
            pembimbing_sekolah TEXT NOT NULL,
            tanggal_mulai TEXT NOT NULL,
            tanggal_selesai TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE presensi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL UNIQUE,
            status TEXT NOT NULL,
            jam_masuk TEXT,
            jam_pulang TEXT,
            keterangan TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE logbook (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            jam_mulai TEXT NOT NULL,
            jam_selesai TEXT NOT NULL,
            kegiatan TEXT NOT NULL,
            kompetensi TEXT NOT NULL,
            kendala TEXT,
            solusi TEXT,
            foto_path TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE akun (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE akun (
              id INTEGER PRIMARY KEY,
              username TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              password_salt TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<bool> akunTerdaftar() async {
    final db = await database;
    final hasil = await db.query('akun', columns: ['id'], limit: 1);
    return hasil.isNotEmpty;
  }

  Future<Map<String, dynamic>?> ambilAkun(String username) async {
    final db = await database;
    final hasil = await db.query(
      'akun',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return hasil.isEmpty ? null : hasil.first;
  }

  Future<String?> ambilUsernameAkun() async {
    final db = await database;
    final hasil = await db.query('akun', columns: ['username'], limit: 1);
    return hasil.isEmpty ? null : hasil.first['username'] as String;
  }

  Future<void> daftarkanAkun({
    required String username,
    required String passwordHash,
    required String passwordSalt,
    required Map<String, dynamic> profil,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final akunAda = await txn.query('akun', columns: ['id'], limit: 1);
      if (akunAda.isNotEmpty) {
        throw StateError('Akun lokal sudah terdaftar di perangkat ini.');
      }

      await txn.insert('akun', {
        'username': username,
        'password_hash': passwordHash,
        'password_salt': passwordSalt,
      });
      await txn.insert('profil', {'id': 1, ...profil});
    });
  }

  // SIMPAN PROFIL

  Future<void> simpanProfil(Map<String, dynamic> data) async {
    final db = await database;

    await db.insert('profil', {
      'id': 1,
      ...data,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // AMBIL PROFIL

  Future<Map<String, dynamic>?> ambilProfil() async {
    final db = await database;

    final hasil = await db.query('profil', where: 'id = ?', whereArgs: [1]);

    if (hasil.isEmpty) return null;

    return hasil.first;
  }

  // TAMBAH PRESENSI

  Future<int> tambahPresensi(Map<String, dynamic> data) async {
    final db = await database;

    return await db.insert('presensi', data);
  }

  // AMBIL PRESENSI

  Future<List<Map<String, dynamic>>> ambilPresensi() async {
    final db = await database;

    return await db.query('presensi', orderBy: 'tanggal DESC');
  }

  // UBAH PRESENSI

  Future<int> ubahPresensi(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update('presensi', data, where: 'id = ?', whereArgs: [id]);
  }

  // HAPUS PRESENSI

  Future<int> hapusPresensi(int id) async {
    final db = await database;

    return await db.delete('presensi', where: 'id = ?', whereArgs: [id]);
  }

  // TAMBAH LOGBOOK

  Future<int> tambahLogbook(Map<String, dynamic> data) async {
    final db = await database;

    return await db.insert('logbook', data);
  }

  // AMBIL LOGBOOK

  Future<List<Map<String, dynamic>>> ambilLogbook() async {
    final db = await database;

    return await db.query('logbook', orderBy: 'tanggal DESC, id DESC');
  }

  // DETAIL LOGBOOK

  Future<Map<String, dynamic>?> ambilLogbookById(int id) async {
    final db = await database;

    final hasil = await db.query('logbook', where: 'id = ?', whereArgs: [id]);

    if (hasil.isEmpty) return null;

    return hasil.first;
  }

  // UBAH LOGBOOK

  Future<int> ubahLogbook(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update('logbook', data, where: 'id = ?', whereArgs: [id]);
  }

  // HAPUS LOGBOOK

  Future<int> hapusLogbook(int id) async {
    final db = await database;

    return await db.delete('logbook', where: 'id = ?', whereArgs: [id]);
  }

  // HAPUS SEMUA DATA

  Future<void> hapusSemuaData() async {
    final db = await database;

    await db.delete('profil');
    await db.delete('presensi');
    await db.delete('logbook');
  }
}
