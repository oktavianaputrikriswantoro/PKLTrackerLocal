import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/logbook_screen.dart';
import '../screens/presensi_screen.dart';
import '../screens/rekap_screen.dart';
import '../screens/riwayat_screen.dart';
import '../screens/profil_screen.dart';
import '../screens/pengaturan_screen.dart';
import '../screens/akun_screen.dart';
import '../services/settings_service.dart';
import '../widgets/bottom_navbar.dart';
import '../database/db_helper.dart';

class PKLTrackerApp extends StatefulWidget {
  const PKLTrackerApp({super.key});

  @override
  State<PKLTrackerApp> createState() => _PKLTrackerAppState();
}

class _PKLTrackerAppState extends State<PKLTrackerApp> {
  final SettingsService _settingsService = SettingsService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  int _selectedIndex = 0;
  bool _darkMode = false;
  bool _checkingAccount = true;
  bool _accountExists = false;
  bool _authenticated = false;
  Object? _startupError;

  NavigatorState get _navigator {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      throw StateError('Navigasi aplikasi belum siap.');
    }
    return navigator;
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _checkAccount();
  }

  Future<void> _checkAccount() async {
    try {
      final exists = await DbHelper.instance.akunTerdaftar();
      if (!mounted) return;
      setState(() {
        _accountExists = exists;
        _checkingAccount = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error;
        _checkingAccount = false;
      });
    }
  }

  Future<void> _loadTheme() async {
    final darkMode = await _settingsService.ambilTema();
    if (!mounted) return;

    setState(() => _darkMode = darkMode);
  }

  Future<void> _changeTheme(bool darkMode) async {
    setState(() => _darkMode = darkMode);
    await _settingsService.simpanTema(darkMode);
  }

  void _signOut() {
    setState(() {
      _authenticated = false;
      _selectedIndex = 0;
    });
  }

  void _openProfile() {
    _navigator.push(
      MaterialPageRoute<void>(builder: (_) => const ProfilScreen()),
    );
  }

  void _openSettings() {
    _navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => PengaturanScreen(
          darkMode: _darkMode,
          onThemeChanged: _changeTheme,
          onSignOut: () {
            _navigator.pop();
            _signOut();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'PKL Tracker Local',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOutCubic,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: _checkingAccount
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _startupError != null
          ? Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat akun: $_startupError'),
                ),
              ),
            )
          : !_authenticated
          ? AkunScreen(
              akunSudahTerdaftar: _accountExists,
              onRegistered: () => setState(() => _accountExists = true),
              onLogin: () => setState(() => _authenticated = true),
            )
          : Scaffold(
              body: switch (_selectedIndex) {
                0 => DashboardScreen(
                  onOpenProfile: _openProfile,
                  onOpenSettings: _openSettings,
                ),
                1 => const PresensiScreen(),
                2 => const LogbookScreen(),
                3 => const RiwayatScreen(),
                4 => const RekapScreen(),
                _ => throw StateError(
                  'Indeks navigasi tidak valid: $_selectedIndex',
                ),
              },
              bottomNavigationBar: BottomNavbar(
                selectedIndex: _selectedIndex,
                onChanged: (index) => setState(() => _selectedIndex = index),
              ),
            ),
    );
  }
}
