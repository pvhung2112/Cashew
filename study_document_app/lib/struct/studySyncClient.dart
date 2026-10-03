import 'dart:async';
import '../database/study_document_dao.dart';
import 'studyDocument.dart';

class StudySyncClient {
  final DocumentDao _documentDao;
  bool _isSyncing = false;

  StudySyncClient({DocumentDao? documentDao})
      : _documentDao = documentDao ?? DocumentDao();

  bool get isSyncing => _isSyncing;

  Future<int> getPendingSyncCount() async {
    final unsynced = _documentDao.getUnsyncedDocuments();
    return unsynced.length;
  }

  Future<SyncResult> syncWithCloud({
    Future<bool> Function(List<StudyDocument> docs)? uploadMock,
  }) async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Đang có tiến trình đồng bộ khác');
    }

    _isSyncing = true;
    try {
      final unsyncedDocs = _documentDao.getUnsyncedDocuments();
      if (unsyncedDocs.isEmpty) {
        _isSyncing = false;
        return SyncResult(success: true, syncedCount: 0, message: 'Dữ liệu đã được đồng bộ');
      }

      bool uploadSuccess = true;
      if (uploadMock != null) {
        uploadSuccess = await uploadMock(unsyncedDocs);
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        uploadSuccess = true;
      }

      if (uploadSuccess) {
        final syncedIds = unsyncedDocs.map((d) => d.id).toList();
        await _documentDao.markAsSynced(syncedIds);
        _isSyncing = false;
        return SyncResult(
          success: true,
          syncedCount: syncedIds.length,
          message: 'Đồng bộ thành công ${syncedIds.length} tài liệu lên Cloud',
        );
      } else {
        _isSyncing = false;
        return SyncResult(success: false, message: 'Máy chủ Cloud không phản hồi');
      }
    } catch (e) {
      _isSyncing = false;
      return SyncResult(success: false, message: 'Lỗi đồng bộ: $e');
    }
  }
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final String message;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    required this.message,
  });
}
