import '../database/db_helper.dart';
import '../models/presensi.dart';

class PresensiRepository {
  final DbHelper _db = DbHelper.instance;

  Future<List<Presensi>> ambilSemua() async {
    final data = await _db.ambilPresensi();

    return data.map((item) => Presensi.fromMap(item)).toList();
  }

  Future<int> tambah(Presensi data) async {
    final nilai = data.toMap();
    nilai.remove('id');

    return await _db.tambahPresensi(nilai);
  }

  Future<int> ubah(Presensi data) async {
    if (data.id == null) {
      throw Exception('ID presensi tidak ditemukan');
    }

    final nilai = data.toMap();
    nilai.remove('id');

    return await _db.ubahPresensi(data.id!, nilai);
  }

  Future<int> hapus(int id) async {
    return await _db.hapusPresensi(id);
  }
}