import 'package:flutter/material.dart';
import 'models/member.dart';
import 'screens/chat_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/notice_screen.dart';

void main() {
  runApp(const RoommateApp());
}

class RoommateApp extends StatelessWidget {
  const RoommateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoommateV01',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C6FF7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Member> members = [
    Member(id: '1', name: 'Riya', color: Color(0xFF7C6FF7)),
    Member(id: '2', name: 'Arjun', color: Color(0xFF1D9E75)),
    Member(id: '3', name: 'Sneha', color: Color(0xFFD85A30)),
    Member(id: '4', name: 'Dev', color: Color(0xFFD4537E)),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      ChatScreen(members: members),
      CalendarScreen(members: members),
      NoticeScreen(members: members),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A2E),
        indicatorColor: const Color(0xFF7C6FF7),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.white54),
            selectedIcon: Icon(Icons.chat_bubble, color: Colors.white),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.calendar_today, color: Colors.white),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined, color: Colors.white54),
            selectedIcon: Icon(Icons.notifications, color: Colors.white),
            label: 'Notices',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏠 Flat 4B',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '4 members · all online',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.call_outlined, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onPressed: () => _showMembersBottomSheet(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...members.map((m) => _memberChip(m)),
              _addMemberChip(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberChip(Member member) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Tooltip(
        message: member.name,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: member.color,
          child: Text(
            member.name[0],
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _addMemberChip(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddMemberDialog(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 1.5),
        ),
        child: const Icon(Icons.add, color: Colors.white54, size: 16),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add member'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  members.add(Member(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: controller.text.trim(),
                    color: Colors.blueGrey,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMembersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...members.map(
            (m) => ListTile(
              leading: CircleAvatar(
                backgroundColor: m.color,
                child: Text(m.name[0],
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(m.name),
            ),
          ),
        ],
      ),
    );
  }
}