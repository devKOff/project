import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/calendar_event.dart';
import '../widgets/member_avatar.dart';

class CalendarScreen extends StatefulWidget {
  final List<Member> members;

  const CalendarScreen({super.key, required this.members});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  late List<CalendarEvent> _events;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _events = [
      CalendarEvent(
        id: '1',
        title: 'Grocery run — 10am',
        description: 'Meet at ground floor lobby',
        date: DateTime(now.year, now.month, now.day + 1),
        addedBy: widget.members[0],
        dotColor: const Color(0xFF7C6FF7),
      ),
      CalendarEvent(
        id: '2',
        title: 'Rent due',
        description: 'Transfer to Arjun before noon',
        date: DateTime(now.year, now.month, 15),
        addedBy: widget.members[2],
        dotColor: const Color(0xFFD85A30),
      ),
      CalendarEvent(
        id: '3',
        title: 'Flat cleaning day',
        description: '10am–1pm, everyone participates',
        date: DateTime(now.year, now.month, 20),
        addedBy: widget.members[1],
        dotColor: const Color(0xFF1D9E75),
      ),
    ];
  }

  List<CalendarEvent> _eventsForDay(DateTime day) {
    return _events
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .toList();
  }

  List<CalendarEvent> get _upcomingEvents {
    final now = DateTime.now();
    return _events
        .where((e) => e.date.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          const Divider(height: 1),
          Expanded(child: _buildEventList()),
          _buildAddEventButton(context),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    const weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                }),
              ),
              Text(
                '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                }),
              ),
            ],
          ),
          Row(
            children: weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final today = DateTime.now();

    final cells = <Widget>[];

    // Previous month padding
    final prevMonthDays =
        DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;
    for (int i = startWeekday - 1; i >= 0; i--) {
      cells.add(_dayCell(prevMonthDays - i, isOtherMonth: true));
    }

    // Current month
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, d);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = _selectedDay != null &&
          date.year == _selectedDay!.year &&
          date.month == _selectedDay!.month &&
          date.day == _selectedDay!.day;
      final hasEvent = _eventsForDay(date).isNotEmpty;

      cells.add(_dayCell(d,
          isToday: isToday,
          isSelected: isSelected,
          hasEvent: hasEvent,
          date: date));
    }

    // Next month padding
    final remaining = (7 - (cells.length % 7)) % 7;
    for (int i = 1; i <= remaining; i++) {
      cells.add(_dayCell(i, isOtherMonth: true));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1,
        children: cells,
      ),
    );
  }

  Widget _dayCell(
    int day, {
    bool isToday = false,
    bool isSelected = false,
    bool isOtherMonth = false,
    bool hasEvent = false,
    DateTime? date,
  }) {
    final bg = isToday || isSelected
        ? const Color(0xFF7C6FF7)
        : Colors.transparent;
    final textColor = isToday || isSelected
        ? Colors.white
        : isOtherMonth
            ? Colors.grey[400]!
            : Colors.black87;

    return GestureDetector(
      onTap: date != null ? () => setState(() => _selectedDay = date) : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(8)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('$day', style: TextStyle(fontSize: 13, color: textColor)),
            if (hasEvent)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isToday || isSelected
                        ? Colors.white
                        : const Color(0xFFE24B4A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _selectedDay != null
        ? _eventsForDay(_selectedDay!)
        : _upcomingEvents;

    if (events.isEmpty) {
      return Center(
        child: Text(
          _selectedDay != null
              ? 'No events on this day'
              : 'No upcoming events',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _selectedDay != null
                ? 'Events on selected day'
                : 'Upcoming events',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
        ),
        ...events.map((e) => _eventTile(e)),
      ],
    );
  }

  Widget _eventTile(CalendarEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: event.dotColor ?? const Color(0xFF7C6FF7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (event.description != null)
                  Text(event.description!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    MemberAvatar(member: event.addedBy, radius: 8),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Added by ${event.addedBy.name} · ${event.dateLabel} · visible to all',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEventButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: OutlinedButton.icon(
        onPressed: () => _showAddEventDialog(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add event'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New event',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _events.add(CalendarEvent(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                        date: selectedDate,
                        addedBy: widget.members.first,
                        dotColor: const Color(0xFF7C6FF7),
                      ));
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FF7),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Add event',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}