import 'user.dart';

class Message {
  final String id;
  final String conversationId;
  final String text;
  final AppUser sender;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  bool isMine(AppUser currentUser) => sender.id == currentUser.id;

  String get timeString {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'text': text,
      'sender': sender.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      text: json['text'] as String,
      sender: AppUser.fromJson(json['sender'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
