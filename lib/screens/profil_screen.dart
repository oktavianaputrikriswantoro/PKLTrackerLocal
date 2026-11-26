import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../widgets/animated_button.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final DbHelper db = DbHelper.instance;

  final namaController = TextEditingController();
  final nisController = TextEditingController();
  final kelasController = TextEditingController();
  final tempatController = TextEditingController();
  final industriController = TextEditingController();
  final sekolahController = TextEditingController();
  final mulaiController = TextEditingController();
  final selesaiController = TextEditingController();

  String? usernameAkun;
  bool loading = true;
  bool menyimpan = false;
  Object? errorMuat;

  @override
  void initState() {
    super.initState();
    muatProfil();
  }

  Future<void> muatProfil() async {
    setState(() {
      loading = true;
      errorMuat = null;
    });

    try {
      final username = await db.ambilUsernameAkun();
      final data = await db.ambilProfil();

      if (data != null) {
        namaController.text = data['nama'] ?? '';
        nisController.text = data['nis'] ?? '';
        kelasController.text = data['kelas'] ?? '';
        tempatController.text = data['tempat_pkl'] ?? '';
        industriController.text = data['pembimbing_industri'] ?? '';
        sekolahController.text = data['pembimbing_sekolah'] ?? '';
        mulaiController.text = data['tanggal_mulai'] ?? '';
        selesaiController.text = data['tanggal_selesai'] ?? '';
      }

      if (!mounted) return;
      setState(() {
        usernameAkun = username;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMuat = error;
        loading = false;
      });
    }
  }

  Future<void> pilihTanggal(TextEditingController controller) async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal != null) {
      controller.text =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> simpanProfil() async {
    if (menyimpan) return;

    if (namaController.text.trim().isEmpty ||
        nisController.text.trim().isEmpty ||
        kelasController.text.trim().isEmpty ||
        tempatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data profil terlebih dahulu.')),
      );
      return;
    }

    if (mulaiController.text.isNotEmpty &&
        selesaiController.text.isNotEmpty &&
        mulaiController.text.compareTo(selesaiController.text) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mulai tidak boleh setelah tanggal selesai.'),
        ),
      );
      return;
    }

    setState(() => menyimpan = true);

    try {
      await db.simpanProfil({
        'nama': namaController.text.trim(),
        'nis': nisController.text.trim(),
        'kelas': kelasController.text.trim(),
        'tempat_pkl': tempatController.text.trim(),
        'pembimbing_industri': industriController.text.trim(),
        'pembimbing_sekolah': sekolahController.text.trim(),
        'tanggal_mulai': mulaiController.text,
        'tanggal_selesai': selesaiController.text,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan!')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $error')));
    } finally {
      if (mounted) setState(() => menyimpan = false);
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    bool tanggal = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: tanggal,
        onTap: tanggal ? () => pilihTanggal(controller) : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
          suffixIcon: tanggal ? const Icon(Icons.calendar_month) : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    nisController.dispose();
    kelasController.dispose();
    tempatController.dispose();
    industriController.dispose();
    sekolahController.dispose();
    mulaiController.dispose();
    selesaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMuat != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Siswa')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text('Gagal memuat profil: $errorMuat'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: muatProfil,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Siswa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                radius: 26,
                child: Icon(Icons.person_rounded, size: 30),
              ),
              title: Text(
                namaController.text.isEmpty
                    ? 'Akun Siswa'
                    : namaController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                [
                  usernameAkun == null
                      ? 'Username akun tidak tersedia'
                      : '@$usernameAkun',
                  if (nisController.text.isNotEmpty)
                    'NIS ${nisController.text}',
                ].join(' • '),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Informasi Siswa',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Data ini terhubung dengan akun yang terdaftar dan dapat diperbarui.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 15),
          field('Nama Lengkap', namaController, icon: Icons.badge_outlined),
          field('NIS', nisController, icon: Icons.numbers),
          field('Kelas', kelasController, icon: Icons.groups_outlined),
          field('Tempat PKL', tempatController, icon: Icons.business_outlined),
          const SizedBox(height: 10),
          Text(
            'Pembimbing',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          field(
            'Pembimbing Industri',
            industriController,
            icon: Icons.engineering_outlined,
          ),
          field(
            'Pembimbing Sekolah',
            sekolahController,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Periode PKL',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          field(
            'Tanggal Mulai',
            mulaiController,
            tanggal: true,
            icon: Icons.event_available_outlined,
          ),
          field(
            'Tanggal Selesai',
            selesaiController,
            tanggal: true,
            icon: Icons.event_busy_outlined,
          ),
          const SizedBox(height: 15),
          AnimatedButton(
            text: menyimpan ? 'Menyimpan...' : 'Simpan Profil',
            icon: menyimpan ? Icons.hourglass_top : Icons.save,
            onPressed: simpanProfil,
          ),
        ],
      ),
    );
  }
}
