import 'package:flutter/material.dart';
import '../models/message.dart';
import 'member_avatar.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isMe ? _mineRow() : _othersRow(),
      ),
    );
  }

  List<Widget> _othersRow() => [
    MemberAvatar(member: message.sender, radius: 14),
    const SizedBox(width: 6),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.sender.name,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        _bubble(),
        const SizedBox(height: 2),
        Text(message.timeString, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    ),
  ];

  List<Widget> _mineRow() => [
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bubble(),
        const SizedBox(height: 2),
        Text('${message.timeString} · ✓✓', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    ),
    const SizedBox(width: 6),
    MemberAvatar(member: message.sender, radius: 14),
  ];

  Widget _bubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF7C6FF7) : Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(4),
          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(14),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          fontSize: 13,
          color: isMe ? Colors.white : Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}