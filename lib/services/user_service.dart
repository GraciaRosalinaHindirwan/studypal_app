import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studypal/models/user_model.dart';

class UserService {
  static const String _userIdKey = 'logged_in_user_id';

  static late Box _users;
  static late Box _session;

  // dipanggil sekali di main() sebelum runApp
  static Future<void> init() async {
    _users = await Hive.openBox('users');
    _session = await Hive.openBox('session');
  }

  // password ga disimpan polos, di-hash dulu
  static String hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  static UserModel? _find(bool Function(UserModel) test) {
    for (final data in _users.values) {
      final user = UserModel.fromMap(Map.from(data));
      if (test(user)) return user;
    }
    return null;
  }

  static UserModel? findById(int id) {
    final data = _users.get(id);
    return data == null ? null : UserModel.fromMap(Map.from(data));
  }

  static UserModel? findByEmail(String email) =>
      _find((u) => u.email == email);

  static UserModel? findByUsername(String username) =>
      _find((u) => u.username == username);

  static Future<UserModel> create({
    required String email,
    required String username,
    required String password,
  }) async {
    // add() ngasih id auto-increment, id-nya disimpan lagi di dalam datanya
    final id = await _users.add({});
    final user = UserModel(
      id: id,
      email: email,
      username: username,
      passwordHash: hash(password),
    );
    await _users.put(id, user.toMap());
    return user;
  }

  static Future<void> update(UserModel user) =>
      _users.put(user.id, user.toMap());

  // session: cuma nyimpen id user yang lagi login
  static Future<void> saveSession(int userId) =>
      _session.put(_userIdKey, userId);

  static int? getSessionUserId() => _session.get(_userIdKey) as int?;

  static Future<void> clearSession() => _session.delete(_userIdKey);
}