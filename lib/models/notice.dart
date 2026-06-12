import 'member.dart';

enum NoticePriority { urgent, info, general }

class Notice {
  final String id;
  final String title;
  final String body;
  final Member postedBy;
  final DateTime timestamp;
  final NoticePriority priority;
  final List<Member> seenBy;

  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.postedBy,
    required this.timestamp,
    this.priority = NoticePriority.general,
    this.seenBy = const [],
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get priorityLabel {
    switch (priority) {
      case NoticePriority.urgent: return 'Urgent';
      case NoticePriority.info: return 'Info';
      case NoticePriority.general: return 'Notice';
    }
  }
}