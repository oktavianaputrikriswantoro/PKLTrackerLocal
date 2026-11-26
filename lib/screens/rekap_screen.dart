import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../database/db_helper.dart';
import '../widgets/summary_card.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  final DbHelper db = DbHelper.instance;

  int hadir = 0;
  int izin = 0;
  int sakit = 0;
  int totalLogbook = 0;

  double persentase = 0;
  double totalJam = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    muatRekap();
  }

  Future<void> muatRekap() async {
    final presensi = await db.ambilPresensi();
    final logbook = await db.ambilLogbook();

    int hitungHadir = 0;
    int hitungIzin = 0;
    int hitungSakit = 0;

    double jam = 0;

    for (final item in presensi) {
      switch (item['status']) {
        case 'Hadir':
          hitungHadir++;
          break;
        case 'Izin':
          hitungIzin++;
          break;
        case 'Sakit':
          hitungSakit++;
          break;
      }
    }

    for (final item in logbook) {
      final mulai = (item['jam_mulai'] as String).split(':');
      final selesai = (item['jam_selesai'] as String).split(':');

      final menitMulai = int.parse(mulai[0]) * 60 + int.parse(mulai[1]);

      final menitSelesai = int.parse(selesai[0]) * 60 + int.parse(selesai[1]);

      if (menitSelesai > menitMulai) {
        jam += (menitSelesai - menitMulai) / 60;
      }
    }

    final totalPresensi = hitungHadir + hitungIzin + hitungSakit;

    final hasilPersentase = totalPresensi == 0
        ? 0.0
        : (hitungHadir / totalPresensi) * 100;

    if (!mounted) return;

    setState(() {
      hadir = hitungHadir;
      izin = hitungIzin;
      sakit = hitungSakit;
      totalLogbook = logbook.length;
      totalJam = jam;
      persentase = hasilPersentase;
      loading = false;
    });
  }

  Widget kartuRekap({
    required String judul,
    required int jumlah,
    required Color warna,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: warna.withAlpha(30),
              child: Icon(icon, color: warna),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                judul,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$jumlah',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap PKL'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => loading = true);
              muatRekap();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: muatRekap,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Ringkasan Kehadiran',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      SummaryCard(
                        title: 'Hadir',
                        value: '$hadir',
                        icon: Icons.check_circle_outline,
                      ),
                      SummaryCard(
                        title: 'Izin',
                        value: '$izin',
                        icon: Icons.info_outline,
                      ),
                      SummaryCard(
                        title: 'Sakit',
                        value: '$sakit',
                        icon: Icons.local_hospital_outlined,
                      ),
                      SummaryCard(
                        title: 'Logbook',
                        value: '$totalLogbook',
                        icon: Icons.menu_book_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Persentase Kehadiran',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: Text(
                              '${persentase.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cocoa,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: persentase / 100,
                              minHeight: 12,
                              backgroundColor: AppTheme.beige,
                              color: AppTheme.mocha,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Persentase dihitung dari jumlah hadir dibandingkan seluruh catatan presensi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.cocoa,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled,
                            color: AppTheme.mocha,
                            size: 35,
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Text(
                              'Total Jam Kegiatan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),

                          Text(
                            '${totalJam.toStringAsFixed(1)} jam',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.cocoa,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
