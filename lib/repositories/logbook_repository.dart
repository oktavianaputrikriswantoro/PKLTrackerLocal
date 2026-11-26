import '../database/db_helper.dart';
import '../models/logbook.dart';

class LogbookRepository {
  final DbHelper _db = DbHelper.instance;

  Future<List<Logbook>> ambilSemua() async {
    final data = await _db.ambilLogbook();
    return data.map((item) => Logbook.fromMap(item)).toList();
  }

  Future<Logbook?> ambilById(int id) async {
    final data = await _db.ambilLogbookById(id);
    if (data == null) return null;
    return Logbook.fromMap(data);
  }

  Future<int> tambah(Logbook data) async {
    final nilai = data.toMap();
    nilai.remove('id');
    return await _db.tambahLogbook(nilai);
  }

  Future<int> ubah(Logbook data) async {
    if (data.id == null) {
      throw Exception('ID logbook tidak ditemukan');
    }
    final nilai = data.toMap();
    nilai.remove('id');
    return await _db.ubahLogbook(data.id!, nilai);
  }

  Future<int> hapus(int id) async {
    return await _db.hapusLogbook(id);
  }
}