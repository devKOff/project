import 'package:flutter/material.dart';

class Member {
  final String id;
  final String name;
  final Color color;

  const Member({
    required this.id,
    required this.name,
    required this.color,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}