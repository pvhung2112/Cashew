import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../struct/studyGoal.dart';
import '../database/goal_dao.dart';

class StudyGoalsPage extends StatefulWidget {
  const StudyGoalsPage({super.key});

  @override
  State<StudyGoalsPage> createState() => _StudyGoalsPageState();
}

class _StudyGoalsPageState extends State<StudyGoalsPage> {
  final _goalDao = GoalDao();

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '5');
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm Mục tiêu Học tập'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên mục tiêu',
                  hintText: 'VD: Hoàn thành 10 bài tập lớn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng mục tiêu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Hạn: ${DateFormat('dd/MM/yyyy').format(selectedDeadline)}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDeadline = picked);
                    }
                  },
                  child: const Text('Đổi ngày'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final target = int.tryParse(targetController.text) ?? 5;
                if (title.isEmpty) return;

                final goal = StudyGoal(
                  id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  targetCount: target,
                  completedCount: 0,
                  deadline: selectedDeadline,
                );
                await _goalDao.insert(goal);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Thêm mục tiêu'),
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
        title: const Text('Mục tiêu Tiến độ Học tập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Thêm mục tiêu',
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<StudyGoal>>(
        stream: _goalDao.watchAll(),
        initialData: _goalDao.getAll(),
        builder: (context, snapshot) {
          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.track_changes_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Chưa có mục tiêu học tập nào', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showAddGoalDialog,
                    child: const Text('Tạo mục tiêu đầu tiên'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final g = goals[index];
              final progress = g.progressPercentage;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                            onPressed: () => _goalDao.delete(g.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ: ${g.completedCount}/${g.targetCount} (${(progress * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            'Hạn: ${DateFormat('dd/MM/yyyy').format(g.deadline)}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: g.isAchieved ? Colors.green : const Color(0xFF1E3C72),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: g.completedCount > 0
                                ? () => _goalDao.update(g.copyWith(completedCount: g.completedCount - 1))
                                : null,
                            icon: const Icon(Icons.remove, size: 16),
                            label: const Text('Giảm'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3C72),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _goalDao.update(g.copyWith(completedCount: g.completedCount + 1)),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Đã xong +1'),
                          ),
                        ],
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
