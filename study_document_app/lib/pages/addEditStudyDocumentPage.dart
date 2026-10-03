import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../database/study_document_dao.dart';
import '../database/study_course_dao.dart';

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

  bool get _isEdit => widget.initialDocument != null;

  @override
  void initState() {
    super.initState();
    final doc = widget.initialDocument;
    _titleController = TextEditingController(text: doc?.title ?? '');
    _descController = TextEditingController(text: doc?.description ?? '');
    _fileUrlController = TextEditingController(text: doc?.fileUrl ?? '');
    _tagsController = TextEditingController(text: doc?.tags.join(', ') ?? '');
    _selectedCourseId = doc?.courseId;
    _selectedType = doc?.type ?? DocumentType.lecture;
    _selectedStatus = doc?.status ?? DocumentStatus.todo;
    _selectedDeadline = doc?.deadline;
    _isPinned = doc?.isPinned ?? false;

    _loadCourses();
  }

  void _loadCourses() {
    _courses = _courseDao.getAll();
    if (_courses.isNotEmpty && _selectedCourseId == null) {
      _selectedCourseId = _courses.first.id;
    }
    setState(() {});
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
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date != null) {
      setState(() => _selectedDeadline = date);
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isEdit) {
      final updated = widget.initialDocument!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
        courseId: _selectedCourseId ?? '',
        type: _selectedType,
        status: _selectedStatus,
        tags: tags,
        deadline: _selectedDeadline,
        isPinned: _isPinned,
      );
      await _documentDao.update(updated);
    } else {
      final newDoc = StudyDocument(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
        courseId: _selectedCourseId ?? '',
        type: _selectedType,
        status: _selectedStatus,
        tags: tags,
        deadline: _selectedDeadline,
        isPinned: _isPinned,
      );
      await _documentDao.insert(newDoc);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
        final deadlineText = _selectedDeadline != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDeadline!)
        : 'Chưa đặt hạn nộp';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa tài liệu' : 'Thêm tài liệu mới'),
        actions: [
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
          padding: const EdgeInsets.all(20),
          children: [
            // Tiêu đề
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề tài liệu *',
                hintText: 'VD: Bài tập lớn: Thiết kế Sync Engine',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),

            // Chọn Môn học
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Môn học / Học phần *',
                border: OutlineInputBorder(),
              ),
              items: _courses.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: Color(c.colorValue), radius: 6),
                      const SizedBox(width: 8),
                      Text('${c.code} - ${c.name}'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCourseId = val),
            ),
            const SizedBox(height: 16),

            // Phân loại tài liệu
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DocumentType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Loại tài liệu',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.displayName));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<DocumentStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.displayName));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hạn nộp Deadline
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Hạn nộp (Deadline)'),
              subtitle: Text(deadlineText),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedDeadline != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDeadline = null),
                    ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
              onTap: _pickDeadline,
            ),
            const SizedBox(height: 16),

            // Mô tả
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả / Ghi chú chi tiết',
                hintText: 'Nhập nội dung tóm tắt tài liệu...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Link URL / File đính kèm
            TextFormField(
              controller: _fileUrlController,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn liên kết / File URL',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Thẻ tag (ngăn cách bằng dấu phẩy)',
                hintText: 'KTPM, Cashew, SQLite',
                prefixIcon: Icon(Icons.tag_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Ghim lên đầu
            SwitchListTile(
              title: const Text('Ghim tài liệu quan trọng lên đầu'),
              value: _isPinned,
              onChanged: (val) => setState(() => _isPinned = val),
            ),

            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEdit ? 'LƯU THAY ĐỔI' : 'TẠO TÀI LIỆU MỚI'),
              onPressed: _saveDocument,
            ),
          ],
        ),
      ),
    );
  }
}
