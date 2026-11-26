import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../database/db_helper.dart';

class AuthRepository {
  final DbHelper _db = DbHelper.instance;

  Future<bool> akunTerdaftar() => _db.akunTerdaftar();

  Future<void> daftarkanAkun({
    required String username,
    required String password,
    required Map<String, dynamic> profil,
  }) async {
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final saltHex = salt
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    final passwordHash = sha256
        .convert(utf8.encode('$saltHex:$password'))
        .toString();

    await _db.daftarkanAkun(
      username: username.trim().toLowerCase(),
      passwordHash: passwordHash,
      passwordSalt: saltHex,
      profil: profil,
    );
  }

  Future<bool> verifikasiLogin({
    required String username,
    required String password,
  }) async {
    final akun = await _db.ambilAkun(username.trim().toLowerCase());
    if (akun == null) return false;

    final salt = akun['password_salt'] as String;
    final hash = sha256.convert(utf8.encode('$salt:$password')).toString();
    return hash == akun['password_hash'];
  }
}
