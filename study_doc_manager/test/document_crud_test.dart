import 'package:flutter_test/flutter_test.dart';
import 'package:study_doc_manager/struct/studyDocument.dart';
import 'package:study_doc_manager/database/database_helper.dart';
import 'package:study_doc_manager/database/document_dao.dart';

void main() {
  late AppDatabase db;
  late DocumentDao documentDao;

  setUp(() {
    db = AppDatabase();
    db.resetDatabase();
    documentDao = DocumentDao(database: db);
  });

  group('Checklist 3 - Kiểm thử chức năng cốt lõi (CRUD & Search/Filter)', () {
    test('1. Thêm tài liệu học tập mới vào hệ thống', () async {
      final doc = StudyDocument(
        id: 'test_doc_1',
        title: 'Slide Thiết kế Kiến trúc Hệ thống',
        courseId: 'c_ktpm',
        type: DocumentType.lecture,
        description: 'Kiến trúc Local-First và Cashew',
        tags: ['KTPM', 'Architecture'],
      );

      await documentDao.insert(doc);

      final retrieved = documentDao.getById('test_doc_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Slide Thiết kế Kiến trúc Hệ thống');
      expect(retrieved.type, DocumentType.lecture);
      expect(retrieved.isSynced, false, reason: 'Tài liệu mới tạo cục bộ phải có isSynced = false');
    });

    test('2. Cập nhật thông tin và trạng thái tài liệu học tập', () async {
      final doc = StudyDocument(
        id: 'test_doc_2',
        title: 'Bài tập 1: Vẽ sơ đồ luồng dữ liệu DFD',
        courseId: 'c_ktpm',
        type: DocumentType.exercise,
        status: DocumentStatus.todo,
      );
      await documentDao.insert(doc);

      // Cập nhật trạng thái sang hoàn thành
      final updated = doc.copyWith(
        status: DocumentStatus.completed,
        title: 'Bài tập 1: Đã hoàn thành DFD',
      );
      await documentDao.update(updated);

      final result = documentDao.getById('test_doc_2');
      expect(result!.status, DocumentStatus.completed);
      expect(result.title, 'Bài tập 1: Đã hoàn thành DFD');
    });

    test('3. Xóa tài liệu khỏi hệ thống lưu trữ', () async {
      final doc = StudyDocument(
        id: 'test_doc_3',
        title: 'Tài liệu tạm cần xóa',
        courseId: 'c_flutter',
        type: DocumentType.reference,
      );
      await documentDao.insert(doc);
      expect(documentDao.getById('test_doc_3'), isNotNull);

      await documentDao.delete('test_doc_3');
      expect(documentDao.getById('test_doc_3'), isNull);
    });

    test('4. Tìm kiếm tài liệu theo từ khóa (Keyword Search)', () {
      final results = documentDao.filterDocuments(query: 'Cashew');
      expect(results.isNotEmpty, true);
      for (var d in results) {
        final match = d.title.contains('Cashew') ||
            d.description.contains('Cashew') ||
            d.tags.contains('Cashew');
        expect(match, true);
      }
    });

    test('5. Lọc tài liệu đa tiêu chí: Môn học + Phân loại', () {
      final lecturesKTPM = documentDao.filterDocuments(
        courseId: 'c_ktpm',
        type: DocumentType.lecture,
      );
      for (var d in lecturesKTPM) {
        expect(d.courseId, 'c_ktpm');
        expect(d.type, DocumentType.lecture);
      }
    });
  });
}
