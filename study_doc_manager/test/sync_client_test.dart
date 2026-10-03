import 'package:flutter_test/flutter_test.dart';
import 'package:study_doc_manager/struct/studyDocument.dart';
import 'package:study_doc_manager/struct/syncClient.dart';
import 'package:study_doc_manager/database/database_helper.dart';
import 'package:study_doc_manager/database/document_dao.dart';

void main() {
  late AppDatabase db;
  late DocumentDao documentDao;
  late SyncClient syncClient;

  setUp(() {
    db = AppDatabase();
    db.resetDatabase();
    documentDao = DocumentDao(database: db);
    syncClient = SyncClient();
    syncClient.reset();
  });

  group('Checklist 4 - Kiểm thử cơ chế Sync Client Local-First (tương tự Cashew)', () {
    test('1. Kiểm thử hàng đợi đồng bộ khi có tài liệu mới tạo offline', () async {
      final doc = StudyDocument(
        id: 'sync_test_1',
        title: 'Tài liệu tạo offline',
        courseId: 'c_ktpm',
        type: DocumentType.lecture,
      );

      await documentDao.insert(doc);

      final unsynced = documentDao.getUnsyncedDocuments();
      expect(unsynced.any((d) => d.id == 'sync_test_1'), true);
      expect(syncClient.pendingSyncCount, greaterThan(0));
    });

    test('2. Kiểm thử tiến trình đồng bộ 2 chiều lên Cloud Server', () async {
      final unsynced = documentDao.getUnsyncedDocuments();
      expect(unsynced.isNotEmpty, true);

      final success = await syncClient.synchronize(unsyncedDocs: unsynced);
      expect(success, true);
      expect(syncClient.status, SyncStatus.synced);
      expect(syncClient.lastSyncTime, isNotNull);

      // Cập nhật trạng thái đã đồng bộ vào DAO
      await documentDao.markAsSynced(unsynced.map((d) => d.id).toList());

      final remainingUnsynced = documentDao.getUnsyncedDocuments();
      expect(remainingUnsynced.isEmpty, true);
    });
  });
}
