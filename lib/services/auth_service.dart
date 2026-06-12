import 'dart:convert';

import 'package:flutter/material.dart';
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

    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      username: normalizedUser,
      email: normalizedEmail,
      password: password,
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

    if (user == null || user.password != password) {
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
