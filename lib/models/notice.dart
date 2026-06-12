import 'user.dart';

enum NoticePriority { urgent, info, general }

class Notice {
  final String id;
  final String title;
  final String body;
  final AppUser postedBy;
  final DateTime timestamp;
  final NoticePriority priority;
  final bool pinned;

  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.postedBy,
    required this.timestamp,
    this.priority = NoticePriority.general,
    this.pinned = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get priorityLabel {
    switch (priority) {
      case NoticePriority.urgent:
        return 'Urgent';
      case NoticePriority.info:
        return 'Info';
      case NoticePriority.general:
        return 'Notice';
    }
  }

  Notice copyWith({bool? pinned}) {
    return Notice(
      id: id,
      title: title,
      body: body,
      postedBy: postedBy,
      timestamp: timestamp,
      priority: priority,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'postedBy': postedBy.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.name,
      'pinned': pinned,
    };
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      postedBy: AppUser.fromJson(json['postedBy'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: NoticePriority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => NoticePriority.general,
      ),
      pinned: json['pinned'] as bool? ?? false,
    );
  }
}
