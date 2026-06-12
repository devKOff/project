import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/calendar_service.dart';
import '../services/chat_service.dart';
import '../services/notice_service.dart';
import 'calendar_screen.dart';
import 'chat_screen.dart';
import 'notice_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AuthService authService;
  final ChatService chatService;
  final NoticeService noticeService;
  final CalendarService calendarService;

  const DashboardScreen({
    super.key,
    required this.authService,
    required this.chatService,
    required this.noticeService,
    required this.calendarService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    final screens = [
      ChatScreen(authService: widget.authService, chatService: widget.chatService),
      NoticeScreen(noticeService: widget.noticeService),
      CalendarScreen(authService: widget.authService, calendarService: widget.calendarService),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Flat dashboard · ${user?.username ?? ''}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(authService: widget.authService),
                ),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Notice'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Calendar'),
        ],
      ),
    );
  }
}
