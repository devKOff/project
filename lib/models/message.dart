import 'member.dart';

class Message {
  final String id;
  final String text;
  final Member sender;
  final DateTime timestamp;
  final bool isVoiceNote;
  final Duration? voiceDuration;

  const Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isVoiceNote = false,
    this.voiceDuration,
  });

  bool isMine(Member currentUser) => sender.id == currentUser.id;

  String get timeString {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}