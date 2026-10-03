import 'package:flutter/material.dart';
import '../../struct/studyDocument.dart';
import '../../struct/course.dart';
import '../../struct/syncClient.dart';
import '../../struct/reminderService.dart';
import '../../database/document_dao.dart';
import '../../database/course_dao.dart';
import '../../widgets/statSummaryCard.dart';
import '../../widgets/documentCard.dart';
import '../../widgets/importExportDialog.dart';
import '../../widgets/backupRestoreWidget.dart';
import '../documentsPage.dart';
import '../coursesPage.dart';
import '../studyGoalsPage.dart';
import '../addEditDocumentPage.dart';
import '../documentSearchPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  final _documentDao = DocumentDao();
  final _courseDao = CourseDao();
  final _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    // 4 Màn hình chính của BottomNavigation
    final pages = [
      _buildDashboardView(),
      const DocumentsPage(),
      const CoursesPage(),
      const StudyGoalsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) => setState(() => _currentNavIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Tài liệu',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Môn học',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes_rounded),
            label: 'Mục tiêu',
          ),
        ],
      ),
    );
  }

  /// Tầng Dashboard trung tâm (Tương đương Home Dashboard trong Cashew)
  Widget _buildDashboardView() {
    final syncClient = SyncClient();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cashew Study Docs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Quản lý Tài liệu Học tập • SV: Phạm Văn Hưng', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          // Nút Đồng bộ Local-First Sync
          AnimatedBuilder(
            animation: syncClient,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      syncClient.status == SyncStatus.syncing
                          ? Icons.sync_rounded
                          : (syncClient.pendingSyncCount > 0 ? Icons.cloud_upload_rounded : Icons.cloud_done_rounded),
                      color: syncClient.pendingSyncCount > 0 ? Colors.orangeAccent : Colors.lightGreenAccent,
                    ),
                    tooltip: 'Đồng bộ đám mây (${syncClient.pendingSyncCount} chờ)',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const SyncStatusDialog(),
                    ),
                  ),
                  if (syncClient.pendingSyncCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${syncClient.pendingSyncCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Nút Tìm kiếm
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Tìm kiếm nhanh',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DocumentSearchPage()),
            ),
          ),
          // Nút Xuất/Nhập dữ liệu sao lưu
          IconButton(
            icon: const Icon(Icons.backup_rounded),
            tooltip: 'Sao lưu & Phục hồi',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ImportExportDialog(),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<StudyDocument>>(
        stream: _documentDao.watchFiltered(),
        initialData: _documentDao.getAll(),
        builder: (context, snapshot) {
          final allDocs = snapshot.data ?? [];
          final courses = {for (var c in _courseDao.getAll()) c.id: c};
          final pinnedDocs = allDocs.where((d) => d.isPinned).toList();
          final recentDocs = allDocs.where((d) => !d.isPinned).take(5).toList();

          // Quét kiểm tra deadline bài tập
          final reminders = _reminderService.checkDeadlines(allDocs);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // 1. Thẻ tổng quan thống kê (Stat Summary Card)
                StatSummaryCard(documents: allDocs),

                // 2. Banner cảnh báo bài tập sắp đến hạn (nếu có)
                if (reminders.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notification_important_rounded, color: Colors.orange.shade800),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminders.first.title,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reminders.first.message,
                                style: TextStyle(fontSize: 12, color: Colors.brown.shade800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 3. Phân mục Môn học nhanh
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Môn học & Học phần',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _currentNavIndex = 2),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: StreamBuilder<List<Course>>(
                    stream: _courseDao.watchAll(),
                    initialData: _courseDao.getAll(),
                    builder: (context, cSnapshot) {
                      final cList = cSnapshot.data ?? [];
                      if (cList.isEmpty) return const Center(child: Text('Chưa có môn học'));

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: cList.length,
                        itemBuilder: (context, idx) {
                          final c = cList[idx];
                          final docCount = allDocs.where((d) => d.courseId == c.id).length;

                          return Container(
                            width: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(c.colorValue).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(c.colorValue).withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.code,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(c.colorValue), fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$docCount tài liệu',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // 4. Tài liệu được ghim ưu tiên (Pinned)
                if (pinnedDocs.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        Icon(Icons.push_pin, size: 18, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          'Tài liệu ưu tiên (Đã ghim)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ...pinnedDocs.map((doc) => DocumentCard(
                        document: doc,
                        course: courses[doc.courseId],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddEditDocumentPage(initialDocument: doc)),
                        ),
                        onToggleStatus: () {
                          final next = doc.status == DocumentStatus.completed
                              ? DocumentStatus.todo
                              : DocumentStatus.completed;
                          _documentDao.update(doc.copyWith(status: next));
                        },
                        onTogglePin: () => _documentDao.update(doc.copyWith(isPinned: !doc.isPinned)),
                        onDelete: () => _documentDao.delete(doc.id),
                      )),
                ],

                // 5. Tài liệu cập nhật gần đây
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tài liệu gần đây',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _currentNavIndex = 1),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                ),
                if (recentDocs.isEmpty && pinnedDocs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.folder_shared_outlined, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('Chưa có tài liệu học tập nào'),
                        ],
                      ),
                    ),
                  )
                else
                  ...recentDocs.map((doc) => DocumentCard(
                        document: doc,
                        course: courses[doc.courseId],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddEditDocumentPage(initialDocument: doc)),
                        ),
                        onToggleStatus: () {
                          final next = doc.status == DocumentStatus.completed
                              ? DocumentStatus.todo
                              : DocumentStatus.completed;
                          _documentDao.update(doc.copyWith(status: next));
                        },
                        onTogglePin: () => _documentDao.update(doc.copyWith(isPinned: !doc.isPinned)),
                        onDelete: () => _documentDao.delete(doc.id),
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditDocumentPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm tài liệu'),
      ),
    );
  }
}
