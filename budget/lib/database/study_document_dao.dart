import 'dart:async';
import 'study_database_helper.dart';
import '../struct/studyDocument.dart';

/// Data Access Object cho Thực thể Tài liệu học tập (DAO Layer)
/// Đảm bảo phân tách hoàn toàn giữa Tầng Dữ liệu và Tầng Giao diện UI.
class DocumentDao {
  final AppDatabase _db;

  DocumentDao({AppDatabase? database}) : _db = database ?? AppDatabase();

  /// Thêm tài liệu mới
  Future<void> insert(StudyDocument doc) async {
    // Đánh dấu isSynced = false khi có bản ghi mới tạo cục bộ
    final newDoc = doc.copyWith(isSynced: false);
    await _db.insertDocument(newDoc);
  }

  /// Cập nhật tài liệu
  Future<void> update(StudyDocument doc) async {
    final updatedDoc = doc.copyWith(
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    await _db.updateDocument(updatedDoc);
  }

  /// Xóa tài liệu
  Future<void> delete(String id) async {
    await _db.deleteDocument(id);
  }

  /// Lấy chi tiết tài liệu theo ID
  StudyDocument? getById(String id) {
    return _db.getDocument(id);
  }

  /// Lấy toàn bộ danh sách tài liệu
  Stream<List<StudyDocument>> watchAll({DocumentType? type, String? courseId}) {
    return watchFiltered(type: type, courseId: courseId);
  }

  List<StudyDocument> getAll({DocumentType? type, String? courseId}) {
    if (type == null && (courseId == null || courseId.isEmpty || courseId == 'all')) {
      return _db.getAllDocuments();
    }
    return filterDocuments(type: type, courseId: courseId);
  }


  /// Tìm kiếm và lọc tài liệu đa tiêu chí (Search & Filter Logic)
  List<StudyDocument> filterDocuments({
    String? query,
    String? courseId,
    DocumentType? type,
    DocumentStatus? status,
    bool? isPinned,
  }) {
    var list = _db.getAllDocuments();

    // 1. Lọc theo từ khóa tìm kiếm (tiêu đề, mô tả, tag)
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((d) {
        final titleMatch = d.title.toLowerCase().contains(q);
        final descMatch = d.description.toLowerCase().contains(q);
        final tagMatch = d.tags.any((t) => t.toLowerCase().contains(q));
        return titleMatch || descMatch || tagMatch;
      }).toList();
    }

    // 2. Lọc theo môn học
    if (courseId != null && courseId.isNotEmpty && courseId != 'all') {
      list = list.where((d) => d.courseId == courseId).toList();
    }

    // 3. Lọc theo loại tài liệu (Bài giảng, Bài tập, Tham khảo)
    if (type != null) {
      list = list.where((d) => d.type == type).toList();
    }

    // 4. Lọc theo trạng thái học tập
    if (status != null) {
      list = list.where((d) => d.status == status).toList();
    }

    // 5. Lọc theo ghim (isPinned)
    if (isPinned != null) {
      list = list.where((d) => d.isPinned == isPinned).toList();
    }

    return list;
  }

  /// Reactive Stream theo dõi danh sách tài liệu với bộ lọc động
  Stream<List<StudyDocument>> watchFiltered({
    String? query,
    String? courseId,
    DocumentType? type,
    DocumentStatus? status,
    bool? isPinned,
  }) {
    return _db.watchAllDocuments().map((_) {
      return filterDocuments(
        query: query,
        courseId: courseId,
        type: type,
        status: status,
        isPinned: isPinned,
      );
    });
  }

  /// Lấy các tài liệu chưa đồng bộ để gửi cho Sync Client
  List<StudyDocument> getUnsyncedDocuments() {
    return _db.getAllDocuments().where((d) => !d.isSynced).toList();
  }

  /// Đánh dấu danh sách tài liệu đã đồng bộ lên Cloud thành công
  Future<void> markAsSynced(List<String> ids) async {
    for (var id in ids) {
      final doc = _db.getDocument(id);
      if (doc != null) {
        await _db.updateDocument(doc.copyWith(isSynced: true));
      }
    }
  }
}

