import 'package:flutter/material.dart';

import '../models/notice.dart';
import '../services/notice_service.dart';
import '../widgets/member_avatar.dart';

class NoticeScreen extends StatelessWidget {
  final NoticeService noticeService;

  const NoticeScreen({super.key, required this.noticeService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: noticeService,
      builder: (_, __) {
        final notices = noticeService.notices;

        return Column(
          children: [
            Expanded(
              child: notices.isEmpty
                  ? const Center(child: Text('No notices yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notices.length,
                      itemBuilder: (_, i) => _noticeCard(context, notices[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () => _showPostNoticeDialog(context),
                icon: const Icon(Icons.add_alert_outlined, size: 18),
                label: const Text('Post a notice'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _noticeCard(BuildContext context, Notice notice) {
    final borderColor = _borderColor(notice.priority);

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
            children: [
              Expanded(
                child: Text(
                  notice.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () => noticeService.togglePinned(notice),
                icon: Icon(
                  notice.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18,
                ),
                tooltip: notice.pinned ? 'Unpin' : 'Pin',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(notice.body, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              MemberAvatar(member: notice.postedBy, radius: 8),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${notice.postedBy.username} · ${notice.timeAgo} · ${notice.priorityLabel}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ),
              if (notice.pinned)
                const Text('Pinned', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostNoticeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    NoticePriority selectedPriority = NoticePriority.general;
    bool isPinned = false;

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
                  decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SegmentedButton<NoticePriority>(
                  segments: const [
                    ButtonSegment(value: NoticePriority.general, label: Text('General')),
                    ButtonSegment(value: NoticePriority.info, label: Text('Info')),
                    ButtonSegment(value: NoticePriority.urgent, label: Text('Urgent')),
                  ],
                  selected: {selectedPriority},
                  onSelectionChanged: (selection) => setModalState(() {
                    selectedPriority = selection.first;
                  }),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pin this notice'),
                  value: isPinned,
                  onChanged: (value) => setModalState(() => isPinned = value ?? false),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await noticeService.addNotice(
                        title: titleCtrl.text,
                        body: bodyCtrl.text,
                        priority: selectedPriority,
                        pinned: isPinned,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Post notice'),
                  ),
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
      case NoticePriority.urgent:
        return const Color(0xFFE24B4A);
      case NoticePriority.info:
        return const Color(0xFF1D9E75);
      case NoticePriority.general:
        return const Color(0xFF7C6FF7);
    }
  }
}
