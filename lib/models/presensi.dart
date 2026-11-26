class Presensi {
  final int? id;
  final String tanggal;
  final String status;
  final String? jamMasuk;
  final String? jamPulang;
  final String? keterangan;

  Presensi({
    this.id,
    required this.tanggal,
    required this.status,
    this.jamMasuk,
    this.jamPulang,
    this.keterangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'status': status,
      'jam_masuk': jamMasuk,
      'jam_pulang': jamPulang,
      'keterangan': keterangan,
    };
  }

  factory Presensi.fromMap(Map<String, dynamic> map) {
    return Presensi(
      id: map['id'] as int?,
      tanggal: map['tanggal'] as String,
      status: map['status'] as String,
      jamMasuk: map['jam_masuk'] as String?,
      jamPulang: map['jam_pulang'] as String?,
      keterangan: map['keterangan'] as String?,
    );
  }
}