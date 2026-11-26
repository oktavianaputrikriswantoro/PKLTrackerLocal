import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/logbook.dart';
import 'form_logbook_screen.dart';
import '../widgets/photo_preview.dart';

class DetailLogbookScreen extends StatelessWidget {
  final Logbook logbook;

  const DetailLogbookScreen({super.key, required this.logbook});

  Widget informasi(String judul, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              color: AppTheme.mocha,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            isi.isEmpty ? '-' : isi,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adaFoto = logbook.fotoPath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Logbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Logbook',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormLogbookScreen(logbook: logbook),
                ),
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: adaFoto
                          ? photoPreview(logbook.fotoPath, fit: BoxFit.contain)
                          : const Icon(
                              Icons.image_outlined,
                              size: 65,
                              color: AppTheme.cocoa,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logbook.kegiatan,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      logbook.tanggal,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    informasi(
                      'Waktu Kegiatan',
                      '${logbook.jamMulai} - ${logbook.jamSelesai}',
                    ),
                    informasi('Deskripsi Kegiatan', logbook.kegiatan),
                    informasi('Kompetensi yang Diperoleh', logbook.kompetensi),
                    informasi('Kendala', logbook.kendala ?? '-'),
                    informasi('Solusi', logbook.solusi ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
