/// Định nghĩa Schema cơ sở dữ liệu (Tương đương tables.dart trong Drift/Cashew)
class DatabaseTables {
  // Bảng Tài liệu học tập (Documents)
  static const String tableDocuments = 'documents';
  static const String colDocId = 'id';
  static const String colDocTitle = 'title';
  static const String colDocCourseId = 'courseId';
  static const String colDocType = 'type';
  static const String colDocStatus = 'status';
  static const String colDocDescription = 'description';
  static const String colDocFileUrl = 'fileUrl';
  static const String colDocTags = 'tags';
  static const String colDocDeadline = 'deadline';
  static const String colDocCreatedAt = 'createdAt';
  static const String colDocUpdatedAt = 'updatedAt';
  static const String colDocIsPinned = 'isPinned';
  static const String colDocIsSynced = 'isSynced';

  // Bảng Môn học (Courses)
  static const String tableCourses = 'courses';
  static const String colCourseId = 'id';
  static const String colCourseCode = 'code';
  static const String colCourseName = 'name';
  static const String colCourseLecturer = 'lecturer';
  static const String colCourseCredits = 'credits';
  static const String colCourseColor = 'colorValue';
  static const String colCourseDescription = 'description';
  static const String colCourseCreatedAt = 'createdAt';

  // Bảng Mục tiêu học tập (Study Goals)
  static const String tableGoals = 'study_goals';
  static const String colGoalId = 'id';
  static const String colGoalTitle = 'title';
  static const String colGoalCourseId = 'courseId';
  static const String colGoalTarget = 'targetCount';
  static const String colGoalCompleted = 'completedCount';
  static const String colGoalDeadline = 'deadline';
  static const String colGoalNotes = 'notes';

  // Bảng hàng đợi đồng bộ (Sync Queue - Local-First Offline Sync)
  static const String tableSyncQueue = 'sync_queue';
  static const String colSyncId = 'id';
  static const String colSyncEntity = 'entityType';
  static const String colSyncEntityId = 'entityId';
  static const String colSyncAction = 'action'; // INSERT, UPDATE, DELETE
  static const String colSyncTimestamp = 'timestamp';
}
