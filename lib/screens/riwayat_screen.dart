import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/presensi.dart';
import '../models/logbook.dart';
import '../repositories/presensi_repository.dart';
import '../repositories/logbook_repository.dart';
import 'detail_logbook_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final presensiRepository = PresensiRepository();
  final logbookRepository = LogbookRepository();

  final searchController = TextEditingController();

  List<Presensi> presensi = [];
  List<Logbook> logbook = [];

  bool loading = true;
  String pencarian = '';

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    muatData();
  }

  Future<void> muatData() async {
    final hasilPresensi = await presensiRepository.ambilSemua();
    final hasilLogbook = await logbookRepository.ambilSemua();

    if (!mounted) return;

    setState(() {
      presensi = hasilPresensi;
      logbook = hasilLogbook;
      loading = false;
    });
  }

  List<Presensi> get hasilPresensi {
    return presensi.where((item) {
      final kata = pencarian.toLowerCase();

      return item.tanggal.toLowerCase().contains(kata) ||
          item.status.toLowerCase().contains(kata) ||
          (item.keterangan ?? '').toLowerCase().contains(kata);
    }).toList();
  }

  List<Logbook> get hasilLogbook {
    return logbook.where((item) {
      final kata = pencarian.toLowerCase();

      return item.tanggal.toLowerCase().contains(kata) ||
          item.kegiatan.toLowerCase().contains(kata) ||
          item.kompetensi.toLowerCase().contains(kata);
    }).toList();
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat PKL'),
        bottom: TabBar(
          controller: tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.event_available), text: 'Presensi'),
            Tab(icon: Icon(Icons.menu_book), text: 'Logbook'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => pencarian = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari riwayat...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          setState(() => pencarian = '');
                        },
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: muatData,
                        child: hasilPresensi.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Icon(
                                    Icons.history,
                                    size: 60,
                                    color: AppTheme.latte,
                                  ),
                                  SizedBox(height: 12),
                                  Center(
                                    child: Text('Tidak ada riwayat presensi.'),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: hasilPresensi.length,
                                itemBuilder: (context, index) {
                                  final item = hasilPresensi[index];

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.event_available,
                                        color: AppTheme.mocha,
                                      ),
                                      title: Text(item.status),
                                      subtitle: Text(
                                        '${item.tanggal}\n'
                                        '${item.jamMasuk ?? "-"} - '
                                        '${item.jamPulang ?? "-"}',
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                      ),

                      RefreshIndicator(
                        onRefresh: muatData,
                        child: hasilLogbook.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Icon(
                                    Icons.menu_book,
                                    size: 60,
                                    color: AppTheme.latte,
                                  ),
                                  SizedBox(height: 12),
                                  Center(
                                    child: Text('Tidak ada riwayat logbook.'),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: hasilLogbook.length,
                                itemBuilder: (context, index) {
                                  final item = hasilLogbook[index];

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.menu_book,
                                        color: AppTheme.mocha,
                                      ),
                                      title: Text(
                                        item.kegiatan,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${item.tanggal}\n'
                                        '${item.jamMulai} - ${item.jamSelesai}',
                                      ),
                                      isThreeLine: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetailLogbookScreen(
                                              logbook: item,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
