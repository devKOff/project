import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notice.dart';
import 'auth_service.dart';

class NoticeService extends ChangeNotifier {
  static const _storageKey = 'roommate_notices';

  final AuthService authService;
  SharedPreferences? _prefs;
  final List<Notice> _notices = [];

  NoticeService(this.authService);

  List<Notice> get notices {
    final sorted = List<Notice>.from(_notices)
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.timestamp.compareTo(a.timestamp);
      });
    return sorted;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _notices
        ..clear()
        ..addAll(decoded.map((item) => Notice.fromJson(item as Map<String, dynamic>)));
    }
  }

  Future<void> addNotice({
    required String title,
    required String body,
    required NoticePriority priority,
    required bool pinned,
  }) async {
    final user = authService.currentUser;
    if (user == null || title.trim().isEmpty || body.trim().isEmpty) return;

    _notices.add(
      Notice(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        body: body.trim(),
        postedBy: user,
        timestamp: DateTime.now(),
        priority: priority,
        pinned: pinned,
      ),
    );

    await _persist();
    notifyListeners();
  }

  Future<void> togglePinned(Notice notice) async {
    final index = _notices.indexWhere((n) => n.id == notice.id);
    if (index == -1) return;
    _notices[index] = _notices[index].copyWith(pinned: !_notices[index].pinned);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs?.setString(
      _storageKey,
      jsonEncode(_notices.map((notice) => notice.toJson()).toList()),
    );
  }
}
