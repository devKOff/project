import 'package:flutter/material.dart';

class AppUser {
  final String id;
  final String username;
  final String email;
  final String password;
  final int colorValue;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  String get initial => username.isEmpty ? '?' : username[0].toUpperCase();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'colorValue': colorValue,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      colorValue: json['colorValue'] as int,
    );
  }
}
