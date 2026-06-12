import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/notice.dart';
import '../widgets/member_avatar.dart';

class NoticeScreen extends StatefulWidget {
  final List<Member> members;

  const NoticeScreen({super.key, required this.members});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  late List<Notice> _notices;

  @override
  void initState() {
    super.initState();
    _notices = [
      Notice(
        id: '1',
        title: '🔴 Water shutdown tomorrow',
        body: 'Building maintenance from 9am–12pm. Fill water before tonight!',
        postedBy: widget.members[2],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        priority: NoticePriority.urgent,
        seenBy: [widget.members[0], widget.members[1], widget.members[3]],
      ),
      Notice(
        id: '2',
        title: '🛒 Grocery list ready',
        body: 'Milk, eggs, bread, vegetables, dish soap. Budget ₹800. Dev is going Saturday morning.',
        postedBy: widget.members[2],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        priority: NoticePriority.info,
        seenBy: [widget.members[1], widget.members[3]],
      ),
      Notice(
        id: '3',
        title: '📶 WiFi password changed',
        body: 'New password is on the kitchen whiteboard. Don\'t share outside the flat.',
        postedBy: widget.members[0],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        priority: NoticePriority.general,
        seenBy: widget.members,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final newCount = _notices.where((n) => !n.seenBy.contains(widget.members.first)).length;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildNoticeHeader(newCount),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notices.length,
              itemBuilder: (ctx, i) => _noticeCard(_notices[i]),
            ),
          ),
          _buildPostButton(context),
        ],
      ),
    );
  }

  Widget _buildNoticeHeader(int newCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Notices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (newCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$newCount new',
                style: const TextStyle(fontSize: 11, color: Color(0xFF185FA5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _noticeCard(Notice notice) {
    final borderColor = _borderColor(notice.priority);
    final badgeBg = _badgeBg(notice.priority);
    final badgeText = _badgeText(notice.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notice.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                child: Text(notice.priorityLabel, style: TextStyle(fontSize: 10, color: badgeText)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(notice.body, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MemberAvatar(member: notice.postedBy, radius: 8),
                  const SizedBox(width: 5),
                  Text(
                    '${notice.postedBy.name} · ${notice.timeAgo}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
              Row(
                children: [
                  ...notice.seenBy.take(4).map((m) => Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: MemberAvatar(member: m, radius: 8),
                      )),
                  const SizedBox(width: 4),
                  Text(
                    notice.seenBy.length == widget.members.length ? 'All seen ✓✓' : 'Seen',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: OutlinedButton.icon(
        onPressed: () => _showPostNoticeDialog(context),
        icon: const Icon(Icons.add_alert_outlined, size: 18),
        label: const Text('Post a notice'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _showPostNoticeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    NoticePriority selectedPriority = NoticePriority.general;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Post a notice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SegmentedButton<NoticePriority>(
                  segments: const [
                    ButtonSegment(value: NoticePriority.general, label: Text('General')),
                    ButtonSegment(value: NoticePriority.info, label: Text('Info')),
                    ButtonSegment(value: NoticePriority.urgent, label: Text('Urgent')),
                  ],
                  selected: {selectedPriority},
                  onSelectionChanged: (s) => setModalState(() => selectedPriority = s.first),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isNotEmpty && bodyCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _notices.insert(0, Notice(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          postedBy: widget.members.first,
                          timestamp: DateTime.now(),
                          priority: selectedPriority,
                          seenBy: [widget.members.first],
                        ));
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C6FF7),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Post notice', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColor(NoticePriority p) {
    switch (p) {
      case NoticePriority.urgent: return const Color(0xFFE24B4A);
      case NoticePriority.info: return const Color(0xFF1D9E75);
      case NoticePriority.general: return const Color(0xFF7C6FF7);
    }
  }

  Color _badgeBg(NoticePriority p) {
    switch (p) {
      case NoticePriority.urgent: return const Color(0xFFFCEBEB);
      case NoticePriority.info: return const Color(0xFFE1F5EE);
      case NoticePriority.general: return const Color(0xFFEEEDFE);
    }
  }

  Color _badgeText(NoticePriority p) {
    switch (p) {
      case NoticePriority.urgent: return const Color(0xFFA32D2D);
      case NoticePriority.info: return const Color(0xFF0F6E56);
      case NoticePriority.general: return const Color(0xFF3C3489);
    }
  }
}