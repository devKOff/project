import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message.dart';
import 'auth_service.dart';

class ChatService extends ChangeNotifier {
  static const _storageKey = 'roommate_messages';

  final AuthService authService;
  SharedPreferences? _prefs;
  final Map<String, List<Message>> _messagesByConversation = {
    'general': [],
    'chores': [],
    'bills': [],
  };

  ChatService(this.authService);

  List<String> get conversations => _messagesByConversation.keys.toList();

  List<Message> messagesFor(String conversationId) {
    return List.unmodifiable(_messagesByConversation[conversationId] ?? const []);
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _messagesByConversation[entry.key] = (entry.value as List<dynamic>)
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final user = authService.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final messages = _messagesByConversation.putIfAbsent(conversationId, () => []);
    messages.add(
      Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        conversationId: conversationId,
        text: text.trim(),
        sender: user,
        timestamp: DateTime.now(),
      ),
    );

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final data = <String, dynamic>{};
    for (final entry in _messagesByConversation.entries) {
      data[entry.key] = entry.value.map((message) => message.toJson()).toList();
    }
    await _prefs?.setString(_storageKey, jsonEncode(data));
  }
}
