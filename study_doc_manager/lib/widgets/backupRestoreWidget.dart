import 'package:flutter/material.dart';
import '../struct/syncClient.dart';
import '../database/document_dao.dart';
import '../database/database_helper.dart';

class SyncStatusDialog extends StatelessWidget {
  const SyncStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final syncClient = SyncClient();

    return AnimatedBuilder(
      animation: syncClient,
      builder: (context, _) {
        final statusColor = syncClient.status == SyncStatus.syncing
            ? Colors.blue
            : (syncClient.status == SyncStatus.synced ? Colors.green : Colors.orange);

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_sync_rounded, color: Color(0xFF2A5298)),
              SizedBox(width: 8),
              Text('Sync Engine (Local-First)'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trạng thái: ${syncClient.status.name.toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                    ),
                    const Spacer(),
                    Text(
                      'Chưa đồng bộ: ${syncClient.pendingSyncCount}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nhật ký hoạt động (Sync Logs):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: syncClient.syncLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có log đồng bộ nào...',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        )
                      : ListView.builder(
                          itemCount: syncClient.syncLogs.length,
                          itemBuilder: (context, index) {
                            return Text(
                              syncClient.syncLogs[index],
                              style: const TextStyle(color: Colors.lightGreenAccent, fontFamily: 'monospace', fontSize: 11),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3C72),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: syncClient.status == SyncStatus.syncing
                            ? null
                            : () async {
                                final unsynced = DocumentDao().getUnsyncedDocuments();
                                final success = await syncClient.synchronize(unsyncedDocs: unsynced);
                                if (success) {
                                  await DocumentDao().markAsSynced(unsynced.map((d) => d.id).toList());
                                }
                              },
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('Kích hoạt đồng bộ Cloud ngay'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      AppDatabase().resetDatabase();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: const Text('Khôi phục dữ liệu mẫu ban đầu (Reset DB)'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
