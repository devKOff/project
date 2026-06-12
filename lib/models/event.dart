import 'user.dart';

enum EventVisibility { personal, shared }

class ApartmentEvent {
  final String id;
  final String title;
  final DateTime dateTime;
  final EventVisibility visibility;
  final AppUser createdBy;

  const ApartmentEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.visibility,
    required this.createdBy,
  });

  String get dateLabel {
    const months = [
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
      'Dec'
    ];
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '${months[dateTime.month - 1]} ${dateTime.day}, $hh:$mm';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'visibility': visibility.name,
      'createdBy': createdBy.toJson(),
    };
  }

  factory ApartmentEvent.fromJson(Map<String, dynamic> json) {
    return ApartmentEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      visibility: EventVisibility.values.firstWhere(
        (value) => value.name == json['visibility'],
        orElse: () => EventVisibility.shared,
      ),
      createdBy: AppUser.fromJson(json['createdBy'] as Map<String, dynamic>),
    );
  }
}
