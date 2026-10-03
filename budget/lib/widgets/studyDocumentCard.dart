import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';

class DocumentCard extends StatelessWidget {
  final StudyDocument document;
  final Course? course;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTogglePin;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.course,
    this.onTap,
    this.onToggleStatus,
    this.onTogglePin,
    this.onDelete,
  });

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.lecture:
        return const Color(0xFF2A75D3);
      case DocumentType.exercise:
        return const Color(0xFFE65100);
      case DocumentType.reference:
        return const Color(0xFF2E7D32);
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
    final courseColor = course != null ? Color(course!.colorValue) : Colors.grey;
    final isDone = document.status == DocumentStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: document.isPinned ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: document.isPinned
            ? BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getTypeIcon(document.type), size: 14, color: typeColor),
                        const SizedBox(width: 4),
                        Text(
                          document.type.displayName,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: typeColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (course != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: courseColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course!.code,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: courseColor),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      document.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                      color: document.isPinned ? Colors.amber.shade700 : Colors.grey.shade400,
                    ),
                    tooltip: document.isPinned ? 'Bỏ ghim' : 'Ghim tài liệu',
                    visualDensity: VisualDensity.compact,
                    onPressed: onTogglePin,
                  ),
                  Icon(
                    document.isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                    size: 18,
                    color: document.isSynced ? Colors.teal : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                document.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey.shade600 : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (document.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  document.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              Row(
                children: [
                  if (document.deadline != null) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: document.deadline!.isBefore(DateTime.now()) && !isDone
                          ? Colors.red
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(document.deadline!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: document.deadline!.isBefore(DateTime.now()) && !isDone
                            ? Colors.red
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  InkWell(
                    onTap: onToggleStatus,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.shade50
                            : (document.status == DocumentStatus.inProgress
                                ? Colors.blue.shade50
                                : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDone
                              ? Colors.green.shade400
                              : (document.status == DocumentStatus.inProgress
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle : Icons.circle_outlined,
                            size: 13,
                            color: isDone ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            document.status.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDone ? Colors.green.shade800 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    tooltip: 'Xóa',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
