import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../database/db_helper.dart';

class PengaturanScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onSignOut;

  const PengaturanScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
    required this.onSignOut,
  });

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final DbHelper db = DbHelper.instance;

  bool menghapus = false;
  late bool darkMode;

  @override
  void initState() {
    super.initState();
    darkMode = widget.darkMode;
  }

  @override
  void didUpdateWidget(covariant PengaturanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.darkMode != widget.darkMode) {
      darkMode = widget.darkMode;
    }
  }

  Future<void> hapusSemuaData() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Seluruh profil, presensi, dan logbook akan dihapus. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    setState(() => menghapus = true);

    try {
      await db.hapusSemuaData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seluruh data berhasil dihapus.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
    } finally {
      if (mounted) {
        setState(() => menghapus = false);
      }
    }
  }

  Widget bagian({
    required IconData icon,
    required String judul,
    required String deskripsi,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.mocha, size: 27),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(deskripsi),
        trailing: trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Tampilan Aplikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        darkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppTheme.mocha,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tema Aplikasi',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Pilih tampilan terang atau gelap.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Terang'),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Gelap'),
                        ),
                      ],
                      selected: {darkMode},
                      onSelectionChanged: (selection) {
                        final value = selection.first;
                        setState(() => darkMode = value);
                        widget.onThemeChanged(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          Text(
            'Pengelolaan Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          bagian(
            icon: Icons.delete_outline,
            judul: 'Hapus Semua Data',
            deskripsi: 'Hapus profil, presensi, dan logbook.',
            onTap: menghapus ? null : hapusSemuaData,
            trailing: IconButton(
              onPressed: menghapus ? null : hapusSemuaData,
              tooltip: 'Hapus semua data',
              icon: menghapus
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red,
                      size: 18,
                    ),
            ),
          ),

          const SizedBox(height: 12),

          bagian(
            icon: Icons.logout,
            judul: 'Keluar dari Akun',
            deskripsi: 'Keluar dan kembali ke halaman login.',
            onTap: widget.onSignOut,
            trailing: IconButton(
              onPressed: widget.onSignOut,
              tooltip: 'Keluar dari akun',
              icon: const Icon(Icons.logout, color: AppTheme.cocoa),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
