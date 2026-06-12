import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';
import '../models/user.dart';
import 'auth_service.dart';

class CalendarService extends ChangeNotifier {
  static const _storageKey = 'roommate_events';

  final AuthService authService;
  SharedPreferences? _prefs;
  final List<ApartmentEvent> _events = [];

  CalendarService(this.authService);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _events
        ..clear()
        ..addAll(
          decoded.map((item) => ApartmentEvent.fromJson(item as Map<String, dynamic>)),
        );
    }
  }

  List<ApartmentEvent> visibleEventsFor(AppUser user) {
    final visible = _events.where((event) {
      return event.visibility == EventVisibility.shared || event.createdBy.id == user.id;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return visible;
  }

  Future<void> addEvent({
    required String title,
    required DateTime dateTime,
    required EventVisibility visibility,
  }) async {
    final user = authService.currentUser;
    if (user == null || title.trim().isEmpty) return;

    _events.add(
      ApartmentEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        dateTime: dateTime,
        visibility: visibility,
        createdBy: user,
      ),
    );

    await _persist();
    notifyListeners();
  }

  List<ApartmentEvent> eventsOn(DateTime day, AppUser user) {
    return visibleEventsFor(user)
        .where((event) =>
            event.dateTime.year == day.year &&
            event.dateTime.month == day.month &&
            event.dateTime.day == day.day)
        .toList();
  }

  Future<void> _persist() async {
    await _prefs?.setString(
      _storageKey,
      jsonEncode(_events.map((event) => event.toJson()).toList()),
    );
  }
}
