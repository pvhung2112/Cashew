import 'dart:convert';

/// Phân loại tài liệu học tập theo nghiệp vụ
enum DocumentType {
  lecture, // Bài giảng / Slide môn học
  exercise, // Bài tập / Đồ án / Bài tập lớn
  reference, // Tài liệu tham khảo / Sách / Giáo trình
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.lecture:
        return 'Bài giảng';
      case DocumentType.exercise:
        return 'Bài tập';
      case DocumentType.reference:
        return 'Tài liệu tham khảo';
    }
  }

  String get keyName => name;

  static DocumentType fromString(String? value) {
    if (value == null) return DocumentType.lecture;
    return DocumentType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DocumentType.lecture,
    );
  }
}

/// Trạng thái học tập của tài liệu
enum DocumentStatus {
  todo, // Chưa học / Cần làm
  inProgress, // Đang học / Đang làm
  completed, // Đã hoàn thành
}

extension DocumentStatusExtension on DocumentStatus {
  String get displayName {
    switch (this) {
      case DocumentStatus.todo:
        return 'Cần học';
      case DocumentStatus.inProgress:
        return 'Đang học';
      case DocumentStatus.completed:
        return 'Đã hoàn thành';
    }
  }

  static DocumentStatus fromString(String? value) {
    if (value == null) return DocumentStatus.todo;
    return DocumentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DocumentStatus.todo,
    );
  }
}

/// Thực thể Tài liệu học tập (Tương đương Transaction/Budget trong Cashew)
class StudyDocument {
  final String id;
  final String title;
  final String courseId;
  final DocumentType type;
  final DocumentStatus status;
  final String description;
  final String fileUrl; // Đường dẫn tệp nội bộ hoặc URL tài liệu đám mây
  final List<String> tags;
  final DateTime? deadline; // Hạn nộp bài tập hoặc hạn đọc tài liệu
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isSynced; // Cờ phục vụ cơ chế Sync Client Local-First giống Cashew

  StudyDocument({
    required this.id,
    required this.title,
    required this.courseId,
    required this.type,
    this.status = DocumentStatus.todo,
    this.description = '',
    this.fileUrl = '',
    this.tags = const [],
    this.deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.isSynced = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  StudyDocument copyWith({
    String? id,
    String? title,
    String? courseId,
    DocumentType? type,
    DocumentStatus? status,
    String? description,
    String? fileUrl,
    List<String>? tags,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isSynced,
  }) {
    return StudyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      tags: tags ?? this.tags,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'courseId': courseId,
      'type': type.name,
      'status': status.name,
      'description': description,
      'fileUrl': fileUrl,
      'tags': jsonEncode(tags),
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory StudyDocument.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null) {
      if (map['tags'] is List) {
        parsedTags = List<String>.from(map['tags']);
      } else if (map['tags'] is String && (map['tags'] as String).isNotEmpty) {
        try {
          parsedTags = List<String>.from(jsonDecode(map['tags']));
        } catch (_) {
          parsedTags = (map['tags'] as String).split(',').map((e) => e.trim()).toList();
        }
      }
    }

    return StudyDocument(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      courseId: map['courseId'] ?? '',
      type: DocumentTypeExtension.fromString(map['type']),
      status: DocumentStatusExtension.fromString(map['status']),
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      tags: parsedTags,
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      isPinned: map['isPinned'] == 1 || map['isPinned'] == true,
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
    );
  }
}

