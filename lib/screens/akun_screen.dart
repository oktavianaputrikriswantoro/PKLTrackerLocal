import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../repositories/auth_repository.dart';

class AkunScreen extends StatefulWidget {
  final bool akunSudahTerdaftar;
  final VoidCallback onRegistered;
  final VoidCallback onLogin;

  const AkunScreen({
    super.key,
    required this.akunSudahTerdaftar,
    required this.onRegistered,
    required this.onLogin,
  });

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final _repository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nis = TextEditingController();
  final _kelas = TextEditingController();
  final _industri = TextEditingController();
  final _sekolah = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _konfirmasiPassword = TextEditingController();
  bool _menunggu = false;
  bool _lihatPassword = false;
  bool _isRegistering = false;
  String? _pesanError;

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _menunggu = true;
      _pesanError = null;
    });

    try {
      await _repository.daftarkanAkun(
        username: _username.text,
        password: _password.text,
        profil: {
          'nama': _nama.text.trim(),
          'nis': _nis.text.trim(),
          'kelas': _kelas.text.trim(),
          'tempat_pkl': '',
          'pembimbing_industri': _industri.text.trim(),
          'pembimbing_sekolah': _sekolah.text.trim(),
          'tanggal_mulai': '',
          'tanggal_selesai': '',
        },
      );
      if (!mounted) return;
      _password.clear();
      _konfirmasiPassword.clear();
      setState(() => _isRegistering = false);
      widget.onRegistered();
    } catch (error) {
      if (mounted) setState(() => _pesanError = 'Gagal mendaftar: $error');
    } finally {
      if (mounted) setState(() => _menunggu = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _menunggu = true;
      _pesanError = null;
    });

    try {
      final berhasil = await _repository.verifikasiLogin(
        username: _username.text,
        password: _password.text,
      );
      if (!mounted) return;
      if (berhasil) {
        widget.onLogin();
      } else {
        setState(() => _pesanError = 'Username atau password salah.');
      }
    } catch (error) {
      if (mounted) setState(() => _pesanError = 'Gagal masuk: $error');
    } finally {
      if (mounted) setState(() => _menunggu = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool wajib = true,
    bool password = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: password && !_lihatPassword,
        validator:
            validator ??
            (value) => wajib && (value == null || value.trim().isEmpty)
                ? '$label wajib diisi.'
                : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: password
              ? IconButton(
                  onPressed: () =>
                      setState(() => _lihatPassword = !_lihatPassword),
                  icon: Icon(
                    _lihatPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nama.dispose();
    _nis.dispose();
    _kelas.dispose();
    _industri.dispose();
    _sekolah.dispose();
    _username.dispose();
    _password.dispose();
    _konfirmasiPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _isRegistering;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: daftar
            ? IconButton(
                tooltip: 'Kembali ke login',
                onPressed: () => setState(() {
                  _isRegistering = false;
                  _pesanError = null;
                }),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          if (!widget.akunSudahTerdaftar && !daftar)
            IconButton(
              tooltip: 'Daftar akun',
              onPressed: () => setState(() {
                _isRegistering = true;
                _pesanError = null;
              }),
              icon: const Icon(Icons.person_add_alt_1),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Icon(Icons.school_rounded, size: 64, color: AppTheme.mocha),
              const SizedBox(height: 12),
              Text(
                daftar ? 'Daftar Akun PKL' : 'Login PKL Tracker',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (!daftar && !widget.akunSudahTerdaftar)
                Text(
                  'Belum punya akun? Tekan ikon orang untuk mendaftar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                daftar
                    ? 'Buat akun untuk menyimpan data PKL di perangkat ini.'
                    : 'Masuk dengan username dan password akun lokal Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 26),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (daftar) ...[
                      _field('Nama', _nama),
                      _field('NIS', _nis),
                      _field('Kelas', _kelas),
                      _field('Pembimbing Industri', _industri),
                      _field('Pembimbing Sekolah', _sekolah),
                    ],
                    _field('Username', _username),
                    _field(
                      'Password',
                      _password,
                      password: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi.';
                        }
                        if (daftar && value.length < 6) {
                          return 'Password minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    if (daftar)
                      _field(
                        'Konfirmasi Password',
                        _konfirmasiPassword,
                        password: true,
                        validator: (value) => value != _password.text
                            ? 'Konfirmasi password tidak sama.'
                            : null,
                      ),
                  ],
                ),
              ),
              if (_pesanError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _pesanError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _menunggu ? null : (daftar ? _daftar : _login),
                  icon: _menunggu
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(daftar ? Icons.person_add_alt_1 : Icons.login),
                  label: Text(
                    _menunggu
                        ? 'Mohon tunggu...'
                        : daftar
                        ? 'Daftar Akun'
                        : 'Login',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
