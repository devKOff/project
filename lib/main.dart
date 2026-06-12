import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/calendar_service.dart';
import 'services/chat_service.dart';
import 'services/notice_service.dart';

void main() {
  runApp(const RoommateApp());
}

class RoommateApp extends StatefulWidget {
  const RoommateApp({super.key});

  @override
  State<RoommateApp> createState() => _RoommateAppState();
}

class _RoommateAppState extends State<RoommateApp> {
  late final AuthService _authService;
  late final ChatService _chatService;
  late final NoticeService _noticeService;
  late final CalendarService _calendarService;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _chatService = ChatService(_authService);
    _noticeService = NoticeService(_authService);
    _calendarService = CalendarService(_authService);

    _initialization = _initServices();
  }

  Future<void> _initServices() async {
    await _authService.init();
    await _chatService.init();
    await _noticeService.init();
    await _calendarService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roommate Apartment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C6FF7)),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedBuilder(
            animation: _authService,
            builder: (_, __) {
              if (!_authService.isAuthenticated) {
                return AuthScreen(authService: _authService);
              }

              return DashboardScreen(
                authService: _authService,
                chatService: _chatService,
                noticeService: _noticeService,
                calendarService: _calendarService,
              );
            },
          );
        },
      ),
    );
  }
}
