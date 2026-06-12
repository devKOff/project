import 'package:flutter/material.dart';
import 'member.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final Member addedBy;
  final Color? dotColor;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.addedBy,
    this.dotColor,
  });

  String get dateLabel {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}