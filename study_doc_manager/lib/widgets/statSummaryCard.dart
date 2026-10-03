import 'package:flutter/material.dart';
import '../struct/studyDocument.dart';

class StatSummaryCard extends StatelessWidget {
  final List<StudyDocument> documents;

  const StatSummaryCard({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    final total = documents.length;
    final lectures = documents.where((d) => d.type == DocumentType.lecture).length;
    final exercises = documents.where((d) => d.type == DocumentType.exercise).length;
    final references = documents.where((d) => d.type == DocumentType.reference).length;
    final completed = documents.where((d) => d.status == DocumentStatus.completed).length;
    final rate = total > 0 ? (completed / total) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3C72).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng quan Tài liệu Học tập',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total tài liệu',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Cột thống kê: Bài giảng, Bài tập, Tham khảo
          Row(
            children: [
              _buildMiniStat('Bài giảng', '$lectures', Icons.menu_book_rounded, Colors.lightBlueAccent),
              _buildDivider(),
              _buildMiniStat('Bài tập', '$exercises', Icons.assignment_rounded, Colors.orangeAccent),
              _buildDivider(),
              _buildMiniStat('Tham khảo', '$references', Icons.auto_stories_rounded, Colors.lightGreenAccent),
            ],
          ),

          const SizedBox(height: 16),

          // Thanh tiến độ hoàn thành
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ học tập ($completed/$total hoàn thành)',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
              Text(
                '${(rate * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
