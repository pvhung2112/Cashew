import 'package:flutter/material.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../database/study_document_dao.dart';
import '../database/study_course_dao.dart';
import '../widgets/studyDocumentCard.dart';
import 'addEditStudyDocumentPage.dart';
import 'studyDocumentSearchPage.dart';

class StudyDocumentsPage extends StatefulWidget {
  const StudyDocumentsPage({super.key});

  @override
  State<StudyDocumentsPage> createState() => _StudyDocumentsPageState();
}

class _StudyDocumentsPageState extends State<StudyDocumentsPage> with SingleTickerProviderStateMixin {
  final _documentDao = DocumentDao();
  final _courseDao = CourseDao();

  late TabController _tabController;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DocumentType? _getCurrentTabType() {
    switch (_tabController.index) {
      case 1:
        return DocumentType.lecture;
      case 2:
        return DocumentType.exercise;
      case 3:
        return DocumentType.reference;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentType = _getCurrentTabType();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho Tài liệu Học tập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Tìm kiếm & Bộ lọc',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DocumentSearchPage()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Bài giảng'),
            Tab(text: 'Bài tập'),
            Tab(text: 'Tham khảo'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Thanh lọc nhanh môn học dạng Chips
          StreamBuilder<List<Course>>(
            stream: _courseDao.watchAll(),
            initialData: _courseDao.getAll(),
            builder: (context, snapshot) {
              final courses = snapshot.data ?? [];
              if (courses.isEmpty) return const SizedBox.shrink();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả môn'),
                      selected: _selectedCourseId == null,
                      onSelected: (val) => setState(() => _selectedCourseId = null),
                    ),
                    const SizedBox(width: 8),
                    ...courses.map((c) {
                      final isSel = _selectedCourseId == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: Color(c.colorValue),
                            radius: 6,
                          ),
                          label: Text(c.code),
                          selected: isSel,
                          onSelected: (val) => setState(() => _selectedCourseId = val ? c.id : null),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),

          // Danh sách tài liệu phản hồi Reactive Stream
          Expanded(
            child: StreamBuilder<List<StudyDocument>>(
              stream: _documentDao.watchFiltered(
                courseId: _selectedCourseId,
                type: currentType,
              ),
              initialData: _documentDao.filterDocuments(
                courseId: _selectedCourseId,
                type: currentType,
              ),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];
                final courses = {for (var c in _courseDao.getAll()) c.id: c};

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Không có tài liệu nào trong mục này',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final course = courses[doc.courseId];

                    return DocumentCard(
                      document: doc,
                      course: course,
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
                      onTogglePin: () {
                        _documentDao.update(doc.copyWith(isPinned: !doc.isPinned));
                      },
                      onDelete: () => _documentDao.delete(doc.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
