import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/logbook.dart';
import '../repositories/logbook_repository.dart';
import 'form_logbook_screen.dart';
import 'detail_logbook_screen.dart';
import '../widgets/photo_preview.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  final repository = LogbookRepository();

  List<Logbook> data = [];
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

  Future<void> bukaForm({Logbook? logbook}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormLogbookScreen(logbook: logbook)),
    );

    await muatData();
  }

  Future<void> hapusLogbook(Logbook item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Logbook?'),
        content: const Text('Apakah kamu yakin ingin menghapus catatan ini?'),
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
      await repository.hapus(item.id!);
      await muatData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logbook berhasil dihapus.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook PKL')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => bukaForm(),
        backgroundColor: AppTheme.cocoa,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kegiatan'),
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
                          Icons.menu_book_rounded,
                          size: 75,
                          color: AppTheme.latte,
                        ),
                        SizedBox(height: 15),
                        Center(child: Text('Belum ada kegiatan PKL.')),
                        SizedBox(height: 8),
                        Center(child: Text('Tekan tombol Tambah Kegiatan.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailLogbookScreen(logbook: item),
                                ),
                              );

                              await muatData();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 140,
                                      height: 150,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child: item.fotoPath.isNotEmpty
                                          ? photoPreview(
                                              item.fotoPath,
                                              fit: BoxFit.contain,
                                            )
                                          : const Icon(
                                              Icons.image_outlined,
                                              size: 45,
                                              color: AppTheme.cocoa,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.tanggal,
                                                style: const TextStyle(
                                                  color: AppTheme.mocha,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              onSelected: (value) {
                                                if (value == 'ubah') {
                                                  bukaForm(logbook: item);
                                                } else {
                                                  hapusLogbook(item);
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
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.kegiatan,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${item.jamMulai} - ${item.jamSelesai}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.kompetensi,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
