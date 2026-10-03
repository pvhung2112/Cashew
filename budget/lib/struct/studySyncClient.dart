import 'dart:async';
import 'package:flutter/foundation.dart';
import 'studyDocument.dart';

enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
}

/// Trạng thái hoạt động của Sync Client (Local-First Engine tương tự Cashew)
class SyncClient extends ChangeNotifier {
  static final SyncClient _instance = SyncClient._internal();
  factory SyncClient() => _instance;
  SyncClient._internal();

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  final List<String> _syncLogs = [];
  List<String> get syncLogs => List.unmodifiable(_syncLogs);

  void updatePendingCount(int count) {
    _pendingSyncCount = count;
    notifyListeners();
  }

  void addLog(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _syncLogs.insert(0, '[$timestamp] $message');
    if (_syncLogs.length > 50) _syncLogs.removeLast();
    notifyListeners();
  }

  /// Mô phỏng tiến trình đồng bộ dữ liệu hai chiều giữa Local Storage và Cloud Storage
  Future<bool> synchronize({required List<StudyDocument> unsyncedDocs}) async {
    if (_status == SyncStatus.syncing) return false;

    _status = SyncStatus.syncing;
    notifyListeners();
    addLog('Bắt đầu đồng bộ ${unsyncedDocs.length} tài liệu lên Cloud...');

    try {
      // Giả lập độ trễ mạng khi giao tiếp với Cloud BaaS (Firebase/REST)
      await Future.delayed(const Duration(milliseconds: 600));

      for (var doc in unsyncedDocs) {
        addLog('Đã đồng bộ tài liệu: "${doc.title}" [${doc.type.displayName}]');
      }

      _lastSyncTime = DateTime.now();
      _pendingSyncCount = 0;
      _status = SyncStatus.synced;
      addLog('Đồng bộ dữ liệu thành công. CSDL cục bộ và Cloud đã khớp!');
      notifyListeners();
      return true;
    } catch (e) {
      _status = SyncStatus.error;
      addLog('Lỗi đồng bộ: $e');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = SyncStatus.idle;
    _pendingSyncCount = 0;
    _syncLogs.clear();
    notifyListeners();
  }
}
