import 'package:flutter/material.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../database/study_document_dao.dart';
import '../database/study_course_dao.dart';
import '../widgets/studyDocumentCard.dart';
import 'addEditStudyDocumentPage.dart';

class DocumentSearchPage extends StatefulWidget {
  const DocumentSearchPage({super.key});

  @override
  State<DocumentSearchPage> createState() => _DocumentSearchPageState();
}

class _DocumentSearchPageState extends State<DocumentSearchPage> {
  final _documentDao = DocumentDao();
  final _courseDao = CourseDao();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCourseId;
  DocumentType? _selectedType;
  DocumentStatus? _selectedStatus;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _courses = _courseDao.getAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCourseId = null;
      _selectedType = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _documentDao.filterDocuments(
      query: _searchQuery,
      courseId: _selectedCourseId,
      type: _selectedType,
      status: _selectedStatus,
    );

    final coursesMap = {for (var c in _courses) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm tài liệu, bài tập, tag...',
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        actions: [
          if (_searchQuery.isNotEmpty || _selectedCourseId != null || _selectedType != null || _selectedStatus != null)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Xóa bộ lọc',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Thanh bộ lọc đa tiêu chí
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Lọc theo Môn học
                DropdownButton<String?>(
                  value: _selectedCourseId,
                  hint: const Text('Tất cả môn học'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả môn học')),
                    ..._courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.code))),
                  ],
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                ),
                const SizedBox(width: 8),

                // Lọc theo Loại tài liệu
                ChoiceChip(
                  label: const Text('Bài giảng'),
                  selected: _selectedType == DocumentType.lecture,
                  onSelected: (val) => setState(() => _selectedType = val ? DocumentType.lecture : null),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Bài tập'),
                  selected: _selectedType == DocumentType.exercise,
                  onSelected: (val) => setState(() => _selectedType = val ? DocumentType.exercise : null),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Tham khảo'),
                  selected: _selectedType == DocumentType.reference,
                  onSelected: (val) => setState(() => _selectedType = val ? DocumentType.reference : null),
                ),
                const SizedBox(width: 8),

                // Lọc theo Trạng thái
                FilterChip(
                  label: const Text('Đã xong'),
                  selected: _selectedStatus == DocumentStatus.completed,
                  onSelected: (val) => setState(() => _selectedStatus = val ? DocumentStatus.completed : null),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Danh sách kết quả
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy tài liệu phù hợp',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final doc = results[index];
                      final course = coursesMap[doc.courseId];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: StudyDocumentCard(
                          document: doc,
                          course: course,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddEditDocumentPage(initialDocument: doc),
                              ),
                            );
                            setState(() {});
                          },
                          onToggleStatus: () async {
                            final nextStatus = doc.status == DocumentStatus.completed
                                ? DocumentStatus.todo
                                : DocumentStatus.completed;
                            await _documentDao.update(doc.copyWith(status: nextStatus));
                            setState(() {});
                          },
                          onTogglePin: () async {
                            await _documentDao.update(doc.copyWith(isPinned: !doc.isPinned));
                            setState(() {});
                          },
                          onDelete: () async {
                            await _documentDao.delete(doc.id);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
