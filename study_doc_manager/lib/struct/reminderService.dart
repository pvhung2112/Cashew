import 'studyDocument.dart';

class ReminderNotification {
  final String id;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final String documentId;
  final bool isUrgent;

  ReminderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.scheduledTime,
    required this.documentId,
    this.isUrgent = false,
  });
}

/// Dịch vụ thông báo & nhắc nhở hạn học tập (Tương đương notificationsGlobal.dart trong Cashew)
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  /// Quét danh sách tài liệu để phát hiện các bài tập sắp hết hạn
  List<ReminderNotification> checkDeadlines(List<StudyDocument> documents) {
    final now = DateTime.now();
    final notifications = <ReminderNotification>[];

    for (var doc in documents) {
      if (doc.status == DocumentStatus.completed) continue;
      if (doc.deadline == null) continue;

      final diff = doc.deadline!.difference(now);
      if (diff.isNegative) {
        // Đã quá hạn
        notifications.add(ReminderNotification(
          id: 'overdue_${doc.id}',
          title: '⚠️ Quá hạn bài tập!',
          message: 'Tài liệu "${doc.title}" đã quá hạn ${-diff.inDays} ngày. Hãy hoàn thành ngay!',
          scheduledTime: now,
          documentId: doc.id,
          isUrgent: true,
        ));
      } else if (diff.inDays <= 3) {
        // Sắp đến hạn trong 3 ngày
        notifications.add(ReminderNotification(
          id: 'upcoming_${doc.id}',
          title: '⏰ Nhắc nhở hạn nộp',
          message: 'Bài tập "${doc.title}" cần nộp trong ${diff.inDays == 0 ? "hôm nay" : "${diff.inDays} ngày tới"}.',
          scheduledTime: now,
          documentId: doc.id,
          isUrgent: diff.inDays <= 1,
        ));
      }
    }

    return notifications;
  }
}
