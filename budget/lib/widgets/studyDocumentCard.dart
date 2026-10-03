import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../database/study_course_dao.dart';
import '../pages/addEditStudyDocumentPage.dart';

typedef DocumentCard = StudyDocumentCard;

class StudyDocumentCard extends StatelessWidget {
  final StudyDocument document;
  final ValueChanged<DocumentStatus>? onStatusChanged;
  final VoidCallback? onDelete;

  final Course? course;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTogglePin;

  const StudyDocumentCard({
    super.key,
    required this.document,
    this.onStatusChanged,
    this.onDelete,
    this.course,
    this.onTap,
    this.onToggleStatus,
    this.onTogglePin,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.lecture:
        return Colors.blue;
      case DocumentType.exercise:
        return Colors.orange;
      case DocumentType.reference:
        return Colors.teal;
    }
  }

  String _getTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.lecture:
        return "Bài giảng";
      case DocumentType.exercise:
        return "Bài tập";
      case DocumentType.reference:
        return "Tài liệu tham khảo";
    }
  }

  IconData _getTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.lecture:
        return Icons.menu_book_rounded;
      case DocumentType.exercise:
        return Icons.assignment_rounded;
      case DocumentType.reference:
        return Icons.auto_stories_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(document.type);
    final isDone = document.status == DocumentStatus.completed;
    final isOverdue = document.deadline != null &&
        document.deadline!.isBefore(DateTime.now()) &&
        !isDone;

    final courseDao = CourseDao();
    final Course? course = document.courseId.isNotEmpty
        ? courseDao.getById(document.courseId)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: getColor(context, "lightDarkAccentHeavyLight"),
        borderRadius: BorderRadius.circular(15),
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: Tappable(
        borderRadius: 15,
        color: Colors.transparent,
        onTap: () {
          pushRoute(
            context,
            AddEditDocumentPage(initialDocument: document),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng Header thẻ: Loại tài liệu, Môn học, Nút ghim, Đã đồng bộ
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getTypeIcon(document.type), size: 13, color: typeColor),
                        const SizedBox(width: 5),
                        TextFont(
                          text: _getTypeLabel(document.type),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          textColor: typeColor,
                        ),
                      ],
                    ),
                  ),

                  if (course != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(course.colorValue).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFont(
                        text: course.code,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        textColor: Color(course.colorValue),
                      ),
                    ),
                  ],

                  const Spacer(),

                  if (document.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.push_pin_rounded, size: 15, color: Colors.amber.shade700),
                    ),

                  if (document.isSynced)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.cloud_done_rounded, size: 15, color: Colors.teal.shade600),
                    ),

                  // Menu hành động nhanh
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded, size: 18, color: getColor(context, "textLight")),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'edit') {
                        pushRoute(context, AddEditDocumentPage(initialDocument: document));
                      } else if (val == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 16),
                            SizedBox(width: 8),
                            TextFont(text: "Chỉnh sửa", fontSize: 13),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            TextFont(text: "Xóa tài liệu", fontSize: 13, textColor: Colors.red),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Tiêu đề tài liệu
              TextFont(
                text: document.title,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                textColor: isDone ? getColor(context, "textLight") : Theme.of(context).colorScheme.onSurface,
                maxLines: 2,
              ),

              if (document.description.isNotEmpty) ...[
                const SizedBox(height: 5),
                TextFont(
                  text: document.description,
                  fontSize: 13,
                  textColor: getColor(context, "textLight"),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Deadline, Trạng thái học, Nút check hoàn thành
              Row(
                children: [
                  if (document.deadline != null) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: isOverdue ? Colors.red : getColor(context, "textLight"),
                    ),
                    const SizedBox(width: 4),
                    TextFont(
                      text: _formatDate(document.deadline!),
                      fontSize: 12,
                      textColor: isOverdue ? Colors.red : getColor(context, "textLight"),
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Nhãn trạng thái
                  _buildStatusBadge(context, document.status),

                  const Spacer(),

                  // Nút chuyển trạng thái nhanh
                  Tappable(
                    borderRadius: 20,
                    color: isDone ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.12),
                    onTap: () {
                      if (onStatusChanged != null) {
                        onStatusChanged!(
                          isDone ? DocumentStatus.inProgress : DocumentStatus.completed,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isDone ? Colors.green.shade700 : getColor(context, "textLight"),
                          ),
                          const SizedBox(width: 5),
                          TextFont(
                            text: isDone ? "Đã xong" : "Hoàn thành",
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            textColor: isDone ? Colors.green.shade700 : getColor(context, "textLight"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, DocumentStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case DocumentStatus.completed:
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green.shade700;
        label = "Đã hoàn thành";
        break;
      case DocumentStatus.inProgress:
        bg = Colors.amber.withOpacity(0.15);
        fg = Colors.orange.shade800;
        label = "Đang học";
        break;
      case DocumentStatus.todo:
        bg = Colors.grey.withOpacity(0.12);
        fg = Colors.grey.shade700;
        label = "Cần học";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFont(
        text: label,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        textColor: fg,
      ),
    );
  }
}
