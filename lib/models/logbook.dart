class Logbook {
  final int? id;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String kegiatan;
  final String kompetensi;
  final String? kendala;
  final String? solusi;
  final String fotoPath;

  Logbook({
    this.id,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kegiatan,
    required this.kompetensi,
    this.kendala,
    this.solusi,
    this.fotoPath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'kegiatan': kegiatan,
      'kompetensi': kompetensi,
      'kendala': kendala,
      'solusi': solusi,
      'foto_path': fotoPath,
    };
  }

  factory Logbook.fromMap(Map<String, dynamic> map) {
    return Logbook(
      id: map['id'] as int?,
      tanggal: map['tanggal'] as String,
      jamMulai: map['jam_mulai'] as String,
      jamSelesai: map['jam_selesai'] as String,
      kegiatan: map['kegiatan'] as String,
      kompetensi: map['kompetensi'] as String,
      kendala: map['kendala'] as String?,
      solusi: map['solusi'] as String?,
      fotoPath: (map['foto_path'] as String?) ?? '',
    );
  }
}
