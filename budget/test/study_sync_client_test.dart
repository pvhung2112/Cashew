import 'package:flutter_test/flutter_test.dart';
import 'package:budget/struct/studyDocument.dart';
import 'package:budget/struct/studySyncClient.dart';
import 'package:budget/database/study_database_helper.dart';
import 'package:budget/database/study_document_dao.dart';

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

  group('Checklist 4 - Ki?m th? co ch? Sync Client Local-First (tuong t? Cashew)', () {
    test('1. Ki?m th? h�ng d?i d?ng b? khi c� t�i li?u m?i t?o offline', () async {
      final doc = StudyDocument(
        id: 'sync_test_1',
        title: 'T�i li?u t?o offline',
        courseId: 'c_ktpm',
        type: DocumentType.lecture,
      );

      await documentDao.insert(doc);

      final unsynced = documentDao.getUnsyncedDocuments();
      expect(unsynced.any((d) => d.id == 'sync_test_1'), true);
      expect(syncClient.pendingSyncCount, greaterThan(0));
    });

    test('2. Ki?m th? ti?n tr�nh d?ng b? 2 chi?u l�n Cloud Server', () async {
      final unsynced = documentDao.getUnsyncedDocuments();
      expect(unsynced.isNotEmpty, true);

      final success = await syncClient.synchronize(unsyncedDocs: unsynced);
      expect(success, true);
      expect(syncClient.status, SyncStatus.synced);
      expect(syncClient.lastSyncTime, isNotNull);

      await documentDao.markAsSynced(unsynced.map((d) => d.id).toList());

      final remainingUnsynced = documentDao.getUnsyncedDocuments();
      expect(remainingUnsynced.isEmpty, true);
    });
  });
}
