import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static const _usersKey = 'roommate_users';
  static const _currentUserKey = 'roommate_current_user_id';

  SharedPreferences? _prefs;
  final List<AppUser> _users = [];
  String? _currentUserId;

  List<AppUser> get users => List.unmodifiable(_users);

  AppUser? get currentUser {
    if (_currentUserId == null) return null;
    for (final user in _users) {
      if (user.id == _currentUserId) {
        return user;
      }
    }
    return null;
  }

  bool get isAuthenticated => currentUser != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final rawUsers = _prefs?.getString(_usersKey);
    if (rawUsers != null && rawUsers.isNotEmpty) {
      final decoded = jsonDecode(rawUsers) as List<dynamic>;
      _users
        ..clear()
        ..addAll(
          decoded.map((entry) => AppUser.fromJson(entry as Map<String, dynamic>)),
        );
    }

    _currentUserId = _prefs?.getString(_currentUserKey);
    notifyListeners();
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedUser = username.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedUser.isEmpty || normalizedEmail.isEmpty || password.isEmpty) {
      return 'All fields are required';
    }

    final usernameExists = _users.any(
      (u) => u.username.toLowerCase() == normalizedUser.toLowerCase(),
    );
    if (usernameExists) return 'Username is already taken';

    final emailExists = _users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (emailExists) return 'Email is already registered';

    final salt = _generateSalt();
    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      username: normalizedUser,
      email: normalizedEmail,
      passwordSalt: salt,
      passwordHash: _hashPassword(password, salt),
      colorValue: _avatarColors[_users.length % _avatarColors.length],
    );

    _users.add(user);
    _currentUserId = user.id;
    await _persist();
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim().toLowerCase();
    AppUser? user;
    for (final candidate in _users) {
      if (candidate.email.toLowerCase() == id ||
          candidate.username.toLowerCase() == id) {
        user = candidate;
        break;
      }
    }

    if (user == null ||
        !_constantTimeEquals(
          user.passwordHash,
          _hashPassword(password, user.passwordSalt),
        )) {
      return 'Invalid credentials';
    }

    _currentUserId = user.id;
    await _persist();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUserId = null;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs?.setString(
      _usersKey,
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );

    if (_currentUserId == null) {
      await _prefs?.remove(_currentUserKey);
    } else {
      await _prefs?.setString(_currentUserKey, _currentUserId!);
    }
  }
}

const List<int> _avatarColors = [
  0xFF7C6FF7,
  0xFF1D9E75,
  0xFFD85A30,
  0xFFD4537E,
  0xFF3C8DAD,
  0xFFB07D2D,
];

String _generateSalt() {
  final random = Random.secure();
  final values = List<int>.generate(16, (_) => random.nextInt(256));
  return base64Encode(values);
}

String _hashPassword(String password, String salt) {
  final passwordBytes = utf8.encode(password);
  final saltBytes = utf8.encode(salt);
  final derived = _pbkdf2(
    passwordBytes: passwordBytes,
    salt: saltBytes,
    iterations: 120000,
    keyLength: 32,
  );
  return base64Encode(derived);
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}

List<int> _pbkdf2({
  required List<int> passwordBytes,
  required List<int> salt,
  required int iterations,
  required int keyLength,
}) {
  final hmac = Hmac(sha256, passwordBytes);
  final hLen = sha256.convert(const <int>[]).bytes.length;
  final blockCount = (keyLength / hLen).ceil();
  final output = <int>[];

  for (var block = 1; block <= blockCount; block++) {
    final initial = <int>[
      ...salt,
      ..._int32BigEndian(block),
    ];

    var u = hmac.convert(initial).bytes;
    final f = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < f.length; j++) {
        f[j] ^= u[j];
      }
    }
    output.addAll(f);
  }

  return output.take(keyLength).toList();
}

List<int> _int32BigEndian(int value) {
  return [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}
