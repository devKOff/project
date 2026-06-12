import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/calendar_service.dart';
import '../widgets/member_avatar.dart';

enum CalendarViewMode { month, week }

const _daysInYear = 365;
const _yearsForward = 10;

class CalendarScreen extends StatefulWidget {
  final AuthService authService;
  final CalendarService calendarService;

  const CalendarScreen({
    super.key,
    required this.authService,
    required this.calendarService,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authService.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please login to view calendar'));
    }

    return AnimatedBuilder(
      animation: widget.calendarService,
      builder: (_, __) {
        final visibleEvents = widget.calendarService.visibleEventsFor(currentUser);
        final selectedEvents = _selectedDay == null
            ? visibleEvents
            : widget.calendarService.eventsOn(_selectedDay!, currentUser);

        return Column(
          children: [
            _buildPeriodHeader(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<CalendarViewMode>(
                segments: const [
                  ButtonSegment(value: CalendarViewMode.month, label: Text('Month view')),
                  ButtonSegment(value: CalendarViewMode.week, label: Text('Week view')),
                ],
                selected: {_viewMode},
                onSelectionChanged: (selection) => setState(() {
                  _viewMode = selection.first;
                }),
              ),
            ),
            if (_viewMode == CalendarViewMode.month) _buildMonthGrid(currentUser),
            if (_viewMode == CalendarViewMode.week) _buildWeekStrip(currentUser),
            const Divider(height: 1),
            Expanded(
              child: selectedEvents.isEmpty
                  ? const Center(child: Text('No events for this selection'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedEvents.length,
                      itemBuilder: (_, i) => _eventTile(selectedEvents[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () => _showAddEventDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add event'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeriodHeader() {
    final label = _viewMode == CalendarViewMode.month
        ? '${_monthName(_focusedDay.month)} ${_focusedDay.year}'
        : 'Week of ${_focusedDay.month}/${_focusedDay.day}/${_focusedDay.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() {
              _focusedDay = _viewMode == CalendarViewMode.month
                  ? DateTime(_focusedDay.year, _focusedDay.month - 1, 1)
                  : _focusedDay.subtract(const Duration(days: 7));
            }),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _focusedDay = _viewMode == CalendarViewMode.month
                  ? DateTime(_focusedDay.year, _focusedDay.month + 1, 1)
                  : _focusedDay.add(const Duration(days: 7));
            }),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(AppUser currentUser) {
    final monthFirst = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final startPadding = monthFirst.weekday % 7;
    final cells = <Widget>[];

    for (int i = 0; i < startPadding; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      final selected = _selectedDay != null && _sameDay(_selectedDay!, date);
      final hasEvents = widget.calendarService.eventsOn(date, currentUser).isNotEmpty;
      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDay = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF7C6FF7) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(color: selected ? Colors.white : Colors.black87),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        children: cells,
      ),
    );
  }

  Widget _buildWeekStrip(AppUser currentUser) {
    final start = _focusedDay.subtract(Duration(days: _focusedDay.weekday % 7));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(7, (index) {
          final day = start.add(Duration(days: index));
          final selected = _selectedDay != null && _sameDay(_selectedDay!, day);
          final hasEvents = widget.calendarService.eventsOn(day, currentUser).isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = day),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF7C6FF7) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${day.month}/${day.day}',
                      style: TextStyle(color: selected ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      hasEvents ? Icons.event : Icons.event_available,
                      size: 14,
                      color: selected ? Colors.white : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _eventTile(ApartmentEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MemberAvatar(member: event.createdBy, radius: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(event.dateLabel, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  '${event.visibility == EventVisibility.shared ? 'Shared' : 'Personal'} · ${event.createdBy.username}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    EventVisibility selectedVisibility = EventVisibility.shared;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Event name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            firstDate: DateTime.now().subtract(const Duration(days: _daysInYear)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: _daysInYear * _yearsForward)),
                            initialDate: selectedDate,
                          );
                          if (picked != null) {
                            setStateModal(() => selectedDate = picked);
                          }
                        },
                        child: Text('Date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setStateModal(() => selectedTime = picked);
                          }
                        },
                        child: Text('Time: ${selectedTime.format(ctx)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedButton<EventVisibility>(
                  segments: const [
                    ButtonSegment(value: EventVisibility.shared, label: Text('Shared')),
                    ButtonSegment(value: EventVisibility.personal, label: Text('Personal')),
                  ],
                  selected: {selectedVisibility},
                  onSelectionChanged: (selection) =>
                      setStateModal(() => selectedVisibility = selection.first),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final dateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      await widget.calendarService.addEvent(
                        title: titleCtrl.text,
                        dateTime: dateTime,
                        visibility: selectedVisibility,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
