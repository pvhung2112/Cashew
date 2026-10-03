import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../struct/studyDocument.dart';
import '../struct/course.dart';
import '../database/document_dao.dart';
import '../database/course_dao.dart';
import '../struct/externalStorageService.dart';

class AddEditDocumentPage extends StatefulWidget {
  final StudyDocument? initialDocument;

  const AddEditDocumentPage({super.key, this.initialDocument});

  @override
  State<AddEditDocumentPage> createState() => _AddEditDocumentPageState();
}

class _AddEditDocumentPageState extends State<AddEditDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _documentDao = DocumentDao();
  final _courseDao = CourseDao();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _fileUrlController;
  late TextEditingController _tagsController;

  String? _selectedCourseId;
  DocumentType _selectedType = DocumentType.lecture;
  DocumentStatus _selectedStatus = DocumentStatus.todo;
  DateTime? _selectedDeadline;
  bool _isPinned = false;
  List<Course> _courses = [];
  bool _isFetchingMetadata = false;

  @override
  void initState() {
    super.initState();
    final doc = widget.initialDocument;
    _titleController = TextEditingController(text: doc?.title ?? '');
    _descController = TextEditingController(text: doc?.description ?? '');
    _fileUrlController = TextEditingController(text: doc?.fileUrl ?? '');
    _tagsController = TextEditingController(text: doc?.tags.join(', ') ?? '');

    _selectedType = doc?.type ?? DocumentType.lecture;
    _selectedStatus = doc?.status ?? DocumentStatus.todo;
    _selectedDeadline = doc?.deadline;
    _isPinned = doc?.isPinned ?? false;

    _loadCourses();
  }

  void _loadCourses() {
    final list = _courseDao.getAll();
    setState(() {
      _courses = list;
      if (widget.initialDocument != null) {
        _selectedCourseId = widget.initialDocument!.courseId;
      } else if (_courses.isNotEmpty) {
        _selectedCourseId = _courses.first.id;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _fileUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _checkMetadata() async {
    final url = _fileUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isFetchingMetadata = true);
    final meta = await ExternalStorageService().fetchDocumentMetadata(url);
    setState(() => _isFetchingMetadata = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nguồn: ${meta['source']} | Định dạng: .${meta['extension']} (~${meta['sizeKb']} KB)'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn môn học!')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final isEdit = widget.initialDocument != null;
    final docId = isEdit ? widget.initialDocument!.id : 'doc_${DateTime.now().millisecondsSinceEpoch}';

    final document = StudyDocument(
      id: docId,
      title: _titleController.text.trim(),
      courseId: _selectedCourseId!,
      type: _selectedType,
      status: _selectedStatus,
      description: _descController.text.trim(),
      fileUrl: _fileUrlController.text.trim(),
      tags: tags,
      deadline: _selectedDeadline,
      isPinned: _isPinned,
      isSynced: false, // Thay đổi mới cần đồng bộ
      createdAt: isEdit ? widget.initialDocument!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEdit) {
      await _documentDao.update(document);
    } else {
      await _documentDao.insert(document);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Đã cập nhật tài liệu!' : 'Đã thêm tài liệu thành công!'),
          backgroundColor: const Color(0xFF1E3C72),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialDocument != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa Tài liệu' : 'Thêm Tài liệu Học tập'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? Colors.amber : null,
            ),
            tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim ưu tiên',
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Lưu',
            onPressed: _saveDocument,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tiêu đề
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề tài liệu *',
                hintText: 'VD: Slide Chương 3 - Thiết kế Cơ sở Dữ liệu',
                prefixIcon: Icon(Icons.title_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),

            // Chọn Môn học (Courses)
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Môn học / Học phần *',
                prefixIcon: Icon(Icons.school_rounded),
                border: OutlineInputBorder(),
              ),
              items: _courses.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(c.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${c.code} - ${c.name}'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCourseId = val),
            ),
            const SizedBox(height: 16),

            // Phân loại tài liệu (Lecture, Exercise, Reference)
            const Text(
              'Phân loại tài liệu:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            SegmentedButton<DocumentType>(
              segments: const [
                ButtonSegment(
                  value: DocumentType.lecture,
                  label: Text('Bài giảng'),
                  icon: Icon(Icons.menu_book_rounded, size: 16),
                ),
                ButtonSegment(
                  value: DocumentType.exercise,
                  label: Text('Bài tập'),
                  icon: Icon(Icons.assignment_rounded, size: 16),
                ),
                ButtonSegment(
                  value: DocumentType.reference,
                  label: Text('Tham khảo'),
                  icon: Icon(Icons.auto_stories_rounded, size: 16),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (set) => setState(() => _selectedType = set.first),
            ),
            const SizedBox(height: 16),

            // Trạng thái học tập
            const Text(
              'Trạng thái học tập:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            SegmentedButton<DocumentStatus>(
              segments: const [
                ButtonSegment(
                  value: DocumentStatus.todo,
                  label: Text('Cần học'),
                ),
                ButtonSegment(
                  value: DocumentStatus.inProgress,
                  label: Text('Đang học'),
                ),
                ButtonSegment(
                  value: DocumentStatus.completed,
                  label: Text('Đã xong'),
                ),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (set) => setState(() => _selectedStatus = set.first),
            ),
            const SizedBox(height: 16),

            // Hạn nộp / Deadline
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_note_rounded, color: Color(0xFF1E3C72)),
              title: Text(
                _selectedDeadline == null
                    ? 'Chưa đặt hạn nộp / thời hạn hoàn thành'
                    : 'Hạn: ${DateFormat('dd/MM/yyyy').format(_selectedDeadline!)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Nhắc nhở tự động theo kiến trúc Cashew'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedDeadline != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _selectedDeadline = null),
                    ),
                  ElevatedButton(
                    onPressed: _pickDeadline,
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Đường dẫn tệp / Cloud Link
            TextFormField(
              controller: _fileUrlController,
              decoration: InputDecoration(
                labelText: 'Đường dẫn tệp / URL Đám mây',
                hintText: 'https://drive.google.com/... hoặc /path/to/file.pdf',
                prefixIcon: const Icon(Icons.link_rounded),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isFetchingMetadata
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.travel_explore_rounded),
                  tooltip: 'Kiểm tra thông tin ngoại vi',
                  onPressed: _checkMetadata,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Thẻ tag (phân tách bởi dấu phẩy)',
                hintText: 'VD: Chương 1, Thi cuối kỳ, Quan trọng',
                prefixIcon: Icon(Icons.tag_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả chi tiết
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú & Tóm tắt nội dung',
                hintText: 'Ghi chú nhanh các điểm cần lưu ý khi học...',
                prefixIcon: Icon(Icons.notes_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Nút Lưu
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveDocument,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  isEdit ? 'Lưu thay đổi' : 'Thêm tài liệu vào hệ thống',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
