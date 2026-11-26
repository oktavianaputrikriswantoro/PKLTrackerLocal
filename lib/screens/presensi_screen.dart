import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/presensi.dart';
import '../repositories/presensi_repository.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final repository = PresensiRepository();

  List<Presensi> data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    final hasil = await repository.ambilSemua();
    if (!mounted) return;

    setState(() {
      data = hasil;
      loading = false;
    });
  }

  Future<void> pilihWaktu(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final waktu = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (waktu != null) {
      controller.text =
          '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> tambahPresensi({Presensi? lama}) async {
    final tanggalController = TextEditingController(
      text: lama?.tanggal ?? DateTime.now().toString().substring(0, 10),
    );

    final masukController = TextEditingController(text: lama?.jamMasuk ?? '');

    final pulangController = TextEditingController(text: lama?.jamPulang ?? '');

    final keteranganController = TextEditingController(
      text: lama?.keterangan ?? '',
    );

    String status = lama?.status ?? 'Hadir';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(lama == null ? 'Tambah Presensi' : 'Ubah Presensi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
                      onTap: () async {
                        final tanggal = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(tanggalController.text) ??
                              DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (tanggal != null) {
                          tanggalController.text = tanggal.toString().substring(
                            0,
                            10,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: ['Hadir', 'Izin', 'Sakit']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => status = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: masukController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Jam Masuk',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => pilihWaktu(context, masukController),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pulangController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Jam Pulang',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => pilihWaktu(context, pulangController),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keteranganController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final hasil = Presensi(
                      id: lama?.id,
                      tanggal: tanggalController.text,
                      status: status,
                      jamMasuk: masukController.text,
                      jamPulang: pulangController.text,
                      keterangan: keteranganController.text,
                    );

                    try {
                      if (lama == null) {
                        await repository.tambah(hasil);
                      } else {
                        await repository.ubah(hasil);
                      }

                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      await muatData();
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Presensi pada tanggal tersebut sudah ada.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    tanggalController.dispose();
    masukController.dispose();
    pulangController.dispose();
    keteranganController.dispose();
  }

  Future<void> hapusPresensi(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Presensi?'),
        content: const Text('Data akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await repository.hapus(id);
      await muatData();
    }
  }

  Color warnaStatus(String status) {
    switch (status) {
      case 'Hadir':
        return Colors.green;
      case 'Izin':
        return Colors.orange;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi PKL')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => tambahPresensi(),
        backgroundColor: AppTheme.cocoa,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: muatData,
              child: data.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 130),
                        Icon(
                          Icons.event_available,
                          size: 70,
                          color: AppTheme.latte,
                        ),
                        SizedBox(height: 15),
                        Center(child: Text('Belum ada data presensi.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: warnaStatus(
                                item.status,
                              ).withAlpha(35),
                              child: Icon(
                                Icons.event_available,
                                color: warnaStatus(item.status),
                              ),
                            ),
                            title: Text(
                              item.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: warnaStatus(item.status),
                              ),
                            ),
                            subtitle: Text(
                              '${item.tanggal}\n'
                              'Masuk: ${item.jamMasuk ?? "-"}\n'
                              'Pulang: ${item.jamPulang ?? "-"}\n'
                              'Keterangan: ${item.keterangan ?? "-"}',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'ubah') {
                                  tambahPresensi(lama: item);
                                } else {
                                  hapusPresensi(item.id!);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'ubah',
                                  child: Text('Ubah'),
                                ),
                                PopupMenuItem(
                                  value: 'hapus',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
