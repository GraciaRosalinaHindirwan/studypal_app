import 'package:flutter/foundation.dart';
import 'package:studypal/models/user_model.dart';
import 'package:studypal/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  // user yang lagi login, null kalau belum login
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // dipanggil pas app dibuka, biar user ga perlu login ulang
  void restoreSession() {
    final id = UserService.getSessionUserId();
    if (id == null) return;
    _currentUser = UserService.findById(id);
  }

  // semua method return null kalau sukses, atau pesan error kalau gagal
  Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final e = email.trim();
    final u = username.trim();
    if (e.isEmpty || u.isEmpty || password.isEmpty) {
      return 'Semua field wajib diisi';
    }
    if (UserService.findByEmail(e) != null) return 'Email sudah terdaftar';
    if (UserService.findByUsername(u) != null) return 'Username sudah dipakai';

    await UserService.create(email: e, username: u, password: password);
    return null;
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final user = UserService.findByUsername(username.trim());
    if (user == null || user.passwordHash != UserService.hash(password)) {
      return 'Username atau password salah';
    }
    await UserService.saveSession(user.id);
    _currentUser = user;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await UserService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> updateEmail(String newEmail) async {
  final email = newEmail.trim();
  if (email.isEmpty) return 'Email tidak boleh kosong';
  if (!email.contains('@')) return 'Format email tidak valid';
  final taken = UserService.findByEmail(email);
  if (taken != null && taken.id != _currentUser!.id) {
    return 'Email sudah terdaftar';
  }
  await _save(_currentUser!.copyWith(email: email));
  return null;
}
  Future<String?> updateUsername(String newUsername) async {
    final name = newUsername.trim();
    if (name.isEmpty) return 'Username tidak boleh kosong';
    final taken = UserService.findByUsername(name);
    if (taken != null && taken.id != _currentUser!.id) {
      return 'Username sudah dipakai';
    }
    await _save(_currentUser!.copyWith(username: name));
    return null;
  }

  Future<String?> updatePassword(String newPassword, String confirm) async {
    if (newPassword.isEmpty) return 'Password tidak boleh kosong';
    if (newPassword != confirm) return 'Konfirmasi password tidak sama';
    await _save(
      _currentUser!.copyWith(passwordHash: UserService.hash(newPassword)),
    );
    return null;
  }

  Future<void> updatePhoto(Uint8List bytes) =>
    _save(_currentUser!.copyWith(photoBytes: bytes));

  Future<void> _save(UserModel user) async {
    await UserService.update(user);
    _currentUser = user;
    notifyListeners();
  }
}