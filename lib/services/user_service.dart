import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studypal/models/user_model.dart';

class UserService {
  static Box<UserModel> get _box => Hive.box<UserModel>('users');

  // loop pakai getAt, sama kayak itemBuilder di modul
  static int _indexWhere(bool Function(UserModel) test) {
    for (var i = 0; i < _box.length; i++) {
      final user = _box.getAt(i);
      if (user != null && test(user)) return i;
    }
    return -1;
  }

  static UserModel? getByIndex(int index) {
    if (index < 0 || index >= _box.length) return null;
    return _box.getAt(index);
  }

  // CREATE: return null kalau sukses, atau pesan error
  static Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final e = email.trim();
    final u = username.trim();
    if (e.isEmpty || u.isEmpty || password.isEmpty) {
      return 'Semua field wajib diisi';
    }
    if (_indexWhere((x) => x.email == e) != -1) return 'Email sudah terdaftar';
    if (_indexWhere((x) => x.username == u) != -1) {
      return 'Username sudah dipakai';
    }

    await _box.add(UserModel(email: e, username: u, password: password));
    return null;
  }

  // return index user kalau cocok, null kalau salah
  static int? login(String username, String password) {
    final index = _indexWhere(
      (x) => x.username == username.trim() && x.password == password,
    );
    return index == -1 ? null : index;
  }

  // UPDATE: bikin UserModel baru lalu putAt, kayak edit todo di modul
  static Future<String?> updateProfile(
    int index, {
    required String email,
    required String username,
    required String password,
    required String confirm,
  }) async {
    final user = _box.getAt(index)!;
    final e = email.trim();
    final u = username.trim();
    if (e.isEmpty || u.isEmpty) return 'Email dan username tidak boleh kosong';

    final emailIdx = _indexWhere((x) => x.email == e);
    if (emailIdx != -1 && emailIdx != index) return 'Email sudah terdaftar';
    final nameIdx = _indexWhere((x) => x.username == u);
    if (nameIdx != -1 && nameIdx != index) return 'Username sudah dipakai';

    var newPassword = user.password;
    // password cuma diganti kalau diisi
    if (password.isNotEmpty) {
      if (password != confirm) return 'Konfirmasi password tidak sama';
      newPassword = password;
    }

    await _box.putAt(
      index,
      UserModel(
        email: e,
        username: u,
        password: newPassword,
        photoBytes: user.photoBytes,
      ),
    );
    return null;
  }

  static Future<void> updatePhoto(int index, Uint8List bytes) async {
    final user = _box.getAt(index)!;
    await _box.putAt(
      index,
      UserModel(
        email: user.email,
        username: user.username,
        password: user.password,
        photoBytes: bytes,
      ),
    );
  }

  // SHARED PREFERENCES
  static Future<void> saveSession(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', true);
    await prefs.setInt('userIndex', index);
  }

  static Future<int?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final adaLogin = prefs.getBool('loginData') ?? false;
    if (!adaLogin) return null;
    final index = prefs.getInt('userIndex');
    if (index == null || getByIndex(index) == null) return null;
    return index;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('userIndex');
  }
}