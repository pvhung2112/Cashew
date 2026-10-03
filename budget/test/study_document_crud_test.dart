import 'package:flutter_test/flutter_test.dart';
import 'package:budget/struct/studyDocument.dart';
import 'package:budget/database/study_database_helper.dart';
import 'package:budget/database/study_document_dao.dart';

void main() {
  late AppDatabase db;
  late DocumentDao documentDao;

  setUp(() {
    db = AppDatabase();
    db.resetDatabase();
    documentDao = DocumentDao(database: db);
  });

  group('Checklist 3 - Ki?m th? ch?c nang c?t l�i (CRUD & Search/Filter)', () {
    test('1. Th�m t�i li?u h?c t?p m?i v�o h? th?ng', () async {
      final doc = StudyDocument(
        id: 'test_doc_1',
        title: 'Slide Thi?t k? Ki?n tr�c H? th?ng',
        courseId: 'c_ktpm',
        type: DocumentType.lecture,
        description: 'Ki?n tr�c Local-First v� Cashew',
        tags: ['KTPM', 'Architecture'],
      );

      await documentDao.insert(doc);

      final retrieved = documentDao.getById('test_doc_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Slide Thi?t k? Ki?n tr�c H? th?ng');
      expect(retrieved.type, DocumentType.lecture);
      expect(retrieved.isSynced, false, reason: 'T�i li?u m?i t?o c?c b? ph?i c� isSynced = false');
    });

    test('2. C?p nh?t th�ng tin v� tr?ng th�i t�i li?u h?c t?p', () async {
      final doc = StudyDocument(
        id: 'test_doc_2',
        title: 'B�i t?p 1: V? so d? lu?ng d? li?u DFD',
        courseId: 'c_ktpm',
        type: DocumentType.exercise,
        status: DocumentStatus.todo,
      );
      await documentDao.insert(doc);

      final updated = doc.copyWith(
        status: DocumentStatus.completed,
        title: 'B�i t?p 1: �� ho�n th�nh DFD',
      );
      await documentDao.update(updated);

      final result = documentDao.getById('test_doc_2');
      expect(result!.status, DocumentStatus.completed);
      expect(result.title, 'B�i t?p 1: �� ho�n th�nh DFD');
    });

    test('3. X�a t�i li?u kh?i h? th?ng luu tr?', () async {
      final doc = StudyDocument(
        id: 'test_doc_3',
        title: 'T�i li?u t?m c?n x�a',
        courseId: 'c_flutter',
        type: DocumentType.reference,
      );
      await documentDao.insert(doc);
      expect(documentDao.getById('test_doc_3'), isNotNull);

      await documentDao.delete('test_doc_3');
      expect(documentDao.getById('test_doc_3'), isNull);
    });

    test('4. T�m ki?m t�i li?u theo t? kh�a (Keyword Search)', () {
      final results = documentDao.filterDocuments(query: 'Cashew');
      expect(results.isNotEmpty, true);
      for (var d in results) {
        final match = d.title.contains('Cashew') ||
            d.description.contains('Cashew') ||
            d.tags.contains('Cashew');
        expect(match, true);
      }
    });

    test('5. L?c t�i li?u da ti�u ch�: M�n h?c + Ph�n lo?i', () {
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
