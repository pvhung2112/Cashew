import 'package:flutter_test/flutter_test.dart';
import 'package:study_doc_manager/struct/studyDocument.dart';
import 'package:study_doc_manager/struct/course.dart';
import 'package:study_doc_manager/database/database_helper.dart';
import 'package:study_doc_manager/database/document_dao.dart';
import 'package:study_doc_manager/database/course_dao.dart';

void main() {
  late AppDatabase db;
  late DocumentDao documentDao;
  late CourseDao courseDao;

  setUp(() {
    db = AppDatabase();
    db.resetDatabase();
    documentDao = DocumentDao(database: db);
    courseDao = CourseDao(database: db);
  });

  group('Checklist 4 - Kiểm thử tính đúng đắn của việc phân tách logic kiến trúc', () {
    test('1. Kiểm thử tính tách biệt của tầng Data Access (DAO Layer)', () {
      // Đảm bảo DAO chỉ đảm nhiệm truy vấn và thao tác dữ liệu, độc lập với UI
      final allCourses = courseDao.getAll();
      expect(allCourses.length, greaterThanOrEqualTo(3));

      final c = courseDao.getById('c_ktpm');
      expect(c, isNotNull);
      expect(c!.name, 'Kiến trúc Phần mềm');
    });

    test('2. Kiểm thử cơ chế Reactive Streams (tương tự Drift .watch() trong Cashew)', () async {
      // Khi chèn tài liệu qua DAO, Stream watchFiltered() phải tự động phát tín hiệu cập nhật
      final stream = documentDao.watchFiltered();

      expectLater(
        stream,
        emitsThrough(predicate<List<StudyDocument>>((list) {
          return list.any((d) => d.id == 'reactive_doc_test');
        })),
      );

      await documentDao.insert(StudyDocument(
        id: 'reactive_doc_test',
        title: 'Tài liệu kiểm thử Reactive Stream',
        courseId: 'c_ktpm',
        type: DocumentType.lecture,
      ));
    });

    test('3. Kiểm thử tính toàn vẹn dữ liệu quan hệ (Cascade Delete)', () async {
      // Tạo môn học mới và 2 tài liệu thuộc môn học đó
      final testCourse = Course(
        id: 'c_temp_delete',
        code: 'TEMP999',
        name: 'Môn học tạm để test xóa',
      );
      await courseDao.insert(testCourse);

      await documentDao.insert(StudyDocument(
        id: 'doc_temp_1',
        title: 'Tài liệu 1 của môn tạm',
        courseId: 'c_temp_delete',
        type: DocumentType.lecture,
      ));
      await documentDao.insert(StudyDocument(
        id: 'doc_temp_2',
        title: 'Tài liệu 2 của môn tạm',
        courseId: 'c_temp_delete',
        type: DocumentType.exercise,
      ));

      expect(documentDao.getById('doc_temp_1'), isNotNull);
      expect(documentDao.getById('doc_temp_2'), isNotNull);

      // Khi xóa môn học, tầng Storage phải tự động xóa liên hoàn các tài liệu con
      await courseDao.delete('c_temp_delete');

      expect(courseDao.getById('c_temp_delete'), isNull);
      expect(documentDao.getById('doc_temp_1'), isNull);
      expect(documentDao.getById('doc_temp_2'), isNull);
    });

    test('4. Kiểm thử chiến lược Sao lưu và Phục hồi (Backup & Restore Strategy)', () {
      final exportJson = db.exportToJson();
      expect(exportJson.isNotEmpty, true);
      expect(exportJson.contains('Kiến trúc Phần mềm'), true);

      // Xóa trắng DB
      db.resetDatabase();

      // Tiến hành khôi phục từ JSON
      db.importFromJson(exportJson);

      final restoredDocs = documentDao.getAll();
      expect(restoredDocs.length, greaterThanOrEqualTo(4));
      final restoredCourses = courseDao.getAll();
      expect(restoredCourses.length, greaterThanOrEqualTo(3));
    });
  });
}
