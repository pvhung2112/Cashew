import 'package:flutter/material.dart';
import '../struct/studyCourse.dart';
import '../struct/studyDocument.dart';
import '../database/study_course_dao.dart';
import '../database/study_document_dao.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _courseDao = CourseDao();
  final _documentDao = DocumentDao();

  void _showAddEditCourseDialog([Course? initialCourse]) {
    final isEdit = initialCourse != null;
    final codeController = TextEditingController(text: initialCourse?.code ?? '');
    final nameController = TextEditingController(text: initialCourse?.name ?? '');
    final lecturerController = TextEditingController(text: initialCourse?.lecturer ?? '');
    final creditsController = TextEditingController(text: '${initialCourse?.credits ?? 3}');
    int selectedColor = initialCourse?.colorValue ?? 0xFF1E88E5;

    final colorOptions = [
      0xFF1E88E5, // Xanh dương
      0xFF43A047, // Xanh lá
      0xFFFB8C00, // Cam
      0xFFE53935, // Đỏ
      0xFF8E24AA, // Tím
      0xFF00ACC1, // Xanh lơ
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa môn học' : 'Thêm môn học mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Mã môn (VD: SE301)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên môn học', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lecturerController,
                  decoration: const InputDecoration(labelText: 'Giảng viên phụ trách', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tín chỉ', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Màu đại diện:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: colorOptions.map((c) {
                    final isSel = selectedColor == c;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.black, width: 2.5) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                final name = nameController.text.trim();
                if (code.isEmpty || name.isEmpty) return;

                final course = Course(
                  id: isEdit ? initialCourse.id : 'c_${DateTime.now().millisecondsSinceEpoch}',
                  code: code,
                  name: name,
                  lecturer: lecturerController.text.trim(),
                  credits: int.tryParse(creditsController.text) ?? 3,
                  colorValue: selectedColor,
                );

                if (isEdit) {
                  await _courseDao.update(course);
                } else {
                  await _courseDao.insert(course);
                }

                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Môn học / Học phần'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Thêm môn học',
            onPressed: () => _showAddEditCourseDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: _courseDao.watchAll(),
        initialData: _courseDao.getAll(),
        builder: (context, snapshot) {
          final courses = snapshot.data ?? [];
          final allDocs = _documentDao.getAll();

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Chưa có môn học nào', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showAddEditCourseDialog(),
                    child: const Text('Thêm môn học đầu tiên'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final c = courses[index];
              final count = allDocs.where((d) => d.courseId == c.id).length;
              final completed = allDocs.where((d) => d.courseId == c.id && d.status == DocumentStatus.completed).length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(c.colorValue),
                    child: Text(
                      c.code.length > 2 ? c.code.substring(0, 2) : c.code,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  title: Text('${c.code} - ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'GV: ${c.lecturer.isNotEmpty ? c.lecturer : "Chưa cập nhật"} • $count tài liệu ($completed đã xong)',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showAddEditCourseDialog(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận xóa môn học?'),
                              content: Text('Hành động này sẽ xóa luôn $count tài liệu thuộc môn ${c.code}.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _courseDao.delete(c.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

