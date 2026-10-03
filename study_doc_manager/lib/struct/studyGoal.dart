/// Thực thể Mục tiêu học tập (Tương đương Objective / Budget trong Cashew)
class StudyGoal {
  final String id;
  final String title;
  final String? courseId;
  final int targetCount; // Số lượng tài liệu/bài tập mục tiêu
  final int completedCount; // Số lượng đã hoàn thành
  final DateTime deadline;
  final String notes;

  StudyGoal({
    required this.id,
    required this.title,
    this.courseId,
    required this.targetCount,
    this.completedCount = 0,
    required this.deadline,
    this.notes = '',
  });

  double get progressPercentage {
    if (targetCount <= 0) return 0.0;
    final p = completedCount / targetCount;
    return p > 1.0 ? 1.0 : p;
  }

  bool get isAchieved => completedCount >= targetCount;

  StudyGoal copyWith({
    String? id,
    String? title,
    String? courseId,
    int? targetCount,
    int? completedCount,
    DateTime? deadline,
    String? notes,
  }) {
    return StudyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      targetCount: targetCount ?? this.targetCount,
      completedCount: completedCount ?? this.completedCount,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'courseId': courseId,
      'targetCount': targetCount,
      'completedCount': completedCount,
      'deadline': deadline.toIso8601String(),
      'notes': notes,
    };
  }

  factory StudyGoal.fromMap(Map<String, dynamic> map) {
    return StudyGoal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      courseId: map['courseId'],
      targetCount: map['targetCount'] is int ? map['targetCount'] : int.tryParse('${map['targetCount']}') ?? 1,
      completedCount: map['completedCount'] is int ? map['completedCount'] : int.tryParse('${map['completedCount']}') ?? 0,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : DateTime.now().add(const Duration(days: 30)),
      notes: map['notes'] ?? '',
    );
  }
}
