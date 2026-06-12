import 'package:flutter/material.dart';

class AppUser {
  final String id;
  final String username;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final int colorValue;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  String get initial => username.isEmpty ? '?' : username[0].toUpperCase();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'passwordSalt': passwordSalt,
      'colorValue': colorValue,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      passwordHash: (json['passwordHash'] ?? json['password']) as String,
      passwordSalt: (json['passwordSalt'] ?? '') as String,
      colorValue: json['colorValue'] as int,
    );
  }
}
