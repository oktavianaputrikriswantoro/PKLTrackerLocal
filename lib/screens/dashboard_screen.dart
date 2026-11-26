import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_theme.dart';
import '../repositories/presensi_repository.dart';
import '../repositories/logbook_repository.dart';
import '../widgets/summary_card.dart';
import '../widgets/animated_button.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;

  const DashboardScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenSettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PresensiRepository _presensi = PresensiRepository();
  final LogbookRepository _logbook = LogbookRepository();

  int jumlahHadir = 0;
  int jumlahLogbook = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final presensi = await _presensi.ambilSemua();
      final logbook = await _logbook.ambilSemua();

      if (!mounted) return;

      setState(() {
        jumlahHadir = presensi
            .where((item) => item.status.toLowerCase() == 'hadir')
            .length;

        jumlahLogbook = logbook.length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  String get tanggalHariIni {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.cocoa,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PKL TRACKER',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 2,
                      color: AppTheme.mocha,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Lihat profil siswa',
                    onPressed: widget.onOpenProfile,
                    icon: const Icon(Icons.person_outline),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  IconButton(
                    tooltip: 'Pengaturan',
                    onPressed: widget.onOpenSettings,
                    icon: const Icon(Icons.settings_outlined),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            tanggalHariIni,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.latte, AppTheme.cocoa],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school_rounded, color: Colors.white, size: 35),
                SizedBox(height: 16),
                Text(
                  'Catatan Perjalanan PKL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Catat kehadiran dan kegiatan PKL '
                  'kamu dengan lebih mudah setiap hari.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'Ringkasan Aktivitas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 14),

          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Kehadiran',
                    value: '$jumlahHadir',
                    icon: Icons.fact_check_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Logbook',
                    value: '$jumlahLogbook',
                    icon: Icons.menu_book_rounded,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 25),

          Text(
            'Informasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.mocha,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jangan lupa mengisi presensi dan '
                    'logbook setiap hari agar kegiatan '
                    'PKL tercatat dengan rapi.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          AnimatedButton(
            text: 'Lihat Profil Siswa',
            icon: Icons.person_outline,
            onPressed: widget.onOpenProfile,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
