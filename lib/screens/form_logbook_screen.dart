import 'package:flutter/material.dart';

import '../models/logbook.dart';
import '../repositories/logbook_repository.dart';
import '../widgets/animated_button.dart';
import '../widgets/photo_picker.dart';

class FormLogbookScreen extends StatefulWidget {
  final Logbook? logbook;

  const FormLogbookScreen({super.key, this.logbook});

  @override
  State<FormLogbookScreen> createState() => _FormLogbookScreenState();
}

class _FormLogbookScreenState extends State<FormLogbookScreen> {
  final repository = LogbookRepository();

  final tanggalController = TextEditingController();
  final mulaiController = TextEditingController();
  final selesaiController = TextEditingController();
  final kegiatanController = TextEditingController();
  final kompetensiController = TextEditingController();
  final kendalaController = TextEditingController();
  final solusiController = TextEditingController();

  String? fotoPath;
  bool loading = false;

  bool get sedangEdit => widget.logbook != null;

  @override
  void initState() {
    super.initState();

    if (sedangEdit) {
      final item = widget.logbook!;

      tanggalController.text = item.tanggal;
      mulaiController.text = item.jamMulai;
      selesaiController.text = item.jamSelesai;
      kegiatanController.text = item.kegiatan;
      kompetensiController.text = item.kompetensi;
      kendalaController.text = item.kendala ?? '';
      solusiController.text = item.solusi ?? '';
      fotoPath = item.fotoPath;
    } else {
      tanggalController.text = DateTime.now().toString().substring(0, 10);
    }
  }

  Future<void> pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(tanggalController.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal != null) {
      tanggalController.text =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pilihWaktu(TextEditingController controller) async {
    final waktu = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (waktu != null) {
      controller.text =
          '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }

  Future<void> simpanLogbook() async {
    if (tanggalController.text.isEmpty ||
        mulaiController.text.isEmpty ||
        selesaiController.text.isEmpty ||
        kegiatanController.text.trim().isEmpty ||
        kompetensiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data wajib terlebih dahulu.'),
        ),
      );
      return;
    }

    final mulai = mulaiController.text.split(':');
    final selesai = selesaiController.text.split(':');

    final menitMulai = int.parse(mulai[0]) * 60 + int.parse(mulai[1]);

    final menitSelesai = int.parse(selesai[0]) * 60 + int.parse(selesai[1]);

    if (menitSelesai <= menitMulai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam selesai harus setelah jam mulai.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final hasil = Logbook(
        id: widget.logbook?.id,
        tanggal: tanggalController.text,
        jamMulai: mulaiController.text,
        jamSelesai: selesaiController.text,
        kegiatan: kegiatanController.text.trim(),
        kompetensi: kompetensiController.text.trim(),
        kendala: kendalaController.text.trim(),
        solusi: solusiController.text.trim(),
        fotoPath: fotoPath ?? '',
      );

      if (sedangEdit) {
        await repository.ubah(hasil);
      } else {
        await repository.tambah(hasil);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sedangEdit
                ? 'Logbook berhasil diperbarui.'
                : 'Logbook berhasil disimpan.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan logbook: $e')));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    tanggalController.dispose();
    mulaiController.dispose();
    selesaiController.dispose();
    kegiatanController.dispose();
    kompetensiController.dispose();
    kendalaController.dispose();
    solusiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sedangEdit ? 'Edit Logbook' : 'Tambah Logbook'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Informasi Kegiatan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 18),

          field(
            'Tanggal Kegiatan',
            tanggalController,
            readOnly: true,
            onTap: pilihTanggal,
            icon: Icons.calendar_month,
          ),

          Row(
            children: [
              Expanded(
                child: field(
                  'Jam Mulai',
                  mulaiController,
                  readOnly: true,
                  onTap: () => pilihWaktu(mulaiController),
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: field(
                  'Jam Selesai',
                  selesaiController,
                  readOnly: true,
                  onTap: () => pilihWaktu(selesaiController),
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),

          field('Deskripsi Kegiatan', kegiatanController, maxLines: 4),

          field('Kompetensi yang Diperoleh', kompetensiController, maxLines: 3),

          const SizedBox(height: 8),

          Text(
            'Kendala dan Solusi',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 15),

          field('Kendala yang Dihadapi', kendalaController, maxLines: 3),

          field('Solusi yang Dilakukan', solusiController, maxLines: 3),

          const SizedBox(height: 10),

          Text(
            'Dokumentasi Kegiatan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 15),

          PhotoPicker(
            initialPath: fotoPath,
            onPhotoSelected: (path) {
              setState(() {
                fotoPath = path;
              });
            },
          ),

          const SizedBox(height: 25),

          AnimatedButton(
            text: loading
                ? 'Menyimpan...'
                : sedangEdit
                ? 'Perbarui Logbook'
                : 'Simpan Logbook',
            icon: Icons.save,
            onPressed: loading ? () {} : simpanLogbook,
          ),
        ],
      ),
    );
  }
}
