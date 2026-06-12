import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_note_banner.dart';

class ChatScreen extends StatefulWidget {
  final List<Member> members;

  const ChatScreen({super.key, required this.members});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Member _currentUser;
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.members.first; // Riya is the current user

    _messages = [
      Message(
        id: '1',
        text: "Hey, who's buying groceries this week? 🛒",
        sender: widget.members[1], // Arjun
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 8)),
      ),
      Message(
        id: '2',
        text: "I can go Saturday morning, need a list",
        sender: widget.members[3], // Dev
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      ),
      Message(
        id: '3',
        text: "Added items to the notice board 📋",
        sender: widget.members[2], // Sneha
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 3)),
      ),
      Message(
        id: '4',
        text: "I blocked 10am on calendar for the shop run",
        sender: _currentUser,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: '5',
        text: "👍 seen it on the calendar",
        sender: widget.members[1], // Arjun
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      ),
    ];
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        sender: _currentUser,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const VoiceNoteBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + 1,
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Today',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ),
                  );
                }
                final msg = _messages[i - 1];
                return MessageBubble(
                  message: msg,
                  isMe: msg.isMine(_currentUser),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[600]),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Message Flat 4B...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF7C6FF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}