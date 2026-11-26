class ProfilPKL {
  final String nama;
  final String nis;
  final String kelas;
  final String tempatPkl;
  final String pembimbingIndustri;
  final String pembimbingSekolah;
  final String tanggalMulai;
  final String tanggalSelesai;

  ProfilPKL({
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.tempatPkl,
    required this.pembimbingIndustri,
    required this.pembimbingSekolah,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  // Mengubah data profil menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'nis': nis,
      'kelas': kelas,
      'tempat_pkl': tempatPkl,
      'pembimbing_industri': pembimbingIndustri,
      'pembimbing_sekolah': pembimbingSekolah,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
    };
  }

  // Mengambil data profil dari Map
  factory ProfilPKL.fromMap(Map<String, dynamic> map) {
    return ProfilPKL(
      nama: map['nama'] ?? '',
      nis: map['nis'] ?? '',
      kelas: map['kelas'] ?? '',
      tempatPkl: map['tempat_pkl'] ?? '',
      pembimbingIndustri:
          map['pembimbing_industri'] ?? '',
      pembimbingSekolah:
          map['pembimbing_sekolah'] ?? '',
      tanggalMulai: map['tanggal_mulai'] ?? '',
      tanggalSelesai: map['tanggal_selesai'] ?? '',
    );
  }
}