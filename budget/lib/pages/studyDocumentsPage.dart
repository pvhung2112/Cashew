import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/noResults.dart';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../database/study_document_dao.dart';
import '../database/study_course_dao.dart';
import '../widgets/studyDocumentCard.dart';
import 'addEditStudyDocumentPage.dart';
import 'studyDocumentSearchPage.dart';
import 'studyCoursesPage.dart';
import 'studyGoalsPage.dart';

class StudyDocumentsPage extends StatefulWidget {
  const StudyDocumentsPage({this.backButton = true, super.key});
  final bool backButton;

  @override
  State<StudyDocumentsPage> createState() => StudyDocumentsPageState();
}

class StudyDocumentsPageState extends State<StudyDocumentsPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();
  final DocumentDao _documentDao = DocumentDao();
  final CourseDao _courseDao = CourseDao();

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
    return PageFramework(
      key: pageState,
      dragDownToDismiss: widget.backButton,
      title: "Kho Tài liệu Học tập",
      backButton: widget.backButton,
      horizontalPaddingConstrained: true,
      actions: [
        IconButton(
          padding: const EdgeInsetsDirectional.all(15),
          tooltip: "Tìm kiếm & Lọc",
          onPressed: () {
            pushRoute(context, const DocumentSearchPage());
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.search_outlined
                : Icons.search_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        IconButton(
          padding: const EdgeInsetsDirectional.all(15),
          tooltip: "Quản lý môn học",
          onPressed: () {
            pushRoute(context, const CoursesPage());
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.school_outlined
                : Icons.school_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        IconButton(
          padding: const EdgeInsetsDirectional.all(15),
          tooltip: "Mục tiêu học tập",
          onPressed: () {
            pushRoute(context, const StudyGoalsPage());
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.flag_outlined
                : Icons.flag_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        IconButton(
          padding: const EdgeInsetsDirectional.all(15),
          tooltip: "Thêm tài liệu",
          onPressed: () {
            pushRoute(context, const AddEditDocumentPage());
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.add_outlined
                : Icons.add_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ],
      floatingActionButton: AddFAB(
        tooltip: "Thêm tài liệu",
        openPage: const AddEditDocumentPage(),
      ),
      slivers: [
        // 1. Thống kê nhanh theo phong cách Cashew Dashboard (như ảnh 1)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: _buildStatsSummary(context),
          ),
        ),

        // 2. Bộ lọc Tab loại tài liệu (Tất cả, Bài giảng, Bài tập, Tham khảo)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTypeTabs(context),
          ),
        ),

        // 3. Thanh lọc môn học bằng Chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildCourseFilterChips(context),
          ),
        ),

        // 4. Danh sách tài liệu phản ứng thời gian thực (Reactive Stream)
        _buildDocumentListSliver(context),

        const SliverToBoxAdapter(
          child: SizedBox(height: 70),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    return StreamBuilder<List<StudyDocument>>(
      stream: _documentDao.watchAll(),
      initialData: _documentDao.getAll(),
      builder: (context, snapshot) {
        final docs = snapshot.data ?? [];
        final totalCount = docs.length;
        final inProgressCount = docs.where((d) => d.status == DocumentStatus.inProgress).length;
        final completedCount = docs.where((d) => d.status == DocumentStatus.completed).length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: "TỔNG TÀI LIỆU",
                count: totalCount.toString(),
                subtitle: "trong kho",
                icon: Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: "ĐANG HỌC",
                count: inProgressCount.toString(),
                subtitle: "cần làm",
                icon: Icons.timelapse_rounded,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: "HOÀN THÀNH",
                count: completedCount.toString(),
                subtitle: "đã xong",
                icon: Icons.check_circle_rounded,
                color: Colors.green.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(context, "lightDarkAccentHeavyLight"),
        borderRadius: BorderRadius.circular(15),
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFont(
                text: title,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                textColor: getColor(context, "textLight"),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          TextFont(
            text: count,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            textColor: color,
          ),
          const SizedBox(height: 2),
          TextFont(
            text: subtitle,
            fontSize: 11,
            textColor: getColor(context, "textLight"),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabs(BuildContext context) {
    final tabs = [
      {"label": "Tất cả", "index": 0},
      {"label": "Bài giảng", "index": 1},
      {"label": "Bài tập", "index": 2},
      {"label": "Tham khảo", "index": 3},
    ];

    return Container(
      decoration: BoxDecoration(
        color: getColor(context, "lightDarkAccentHeavyLight"),
        borderRadius: BorderRadius.circular(14),
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((t) {
          final isSelected = _tabController.index == t["index"];
          return Expanded(
            child: Tappable(
              borderRadius: 10,
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
              onTap: () {
                _tabController.animateTo(t["index"] as int);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Center(
                  child: TextFont(
                    text: t["label"] as String,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    textColor: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : getColor(context, "textLight"),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseFilterChips(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: _courseDao.watchAll(),
      initialData: _courseDao.getAll(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterPill(
                context,
                label: "Tất cả môn",
                isSelected: _selectedCourseId == null,
                onTap: () => setState(() => _selectedCourseId = null),
              ),
              const SizedBox(width: 8),
              ...courses.map((c) {
                final isSel = _selectedCourseId == c.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterPill(
                    context,
                    label: c.code,
                    dotColor: Color(c.colorValue),
                    isSelected: isSel,
                    onTap: () => setState(() => _selectedCourseId = isSel ? null : c.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String label,
    Color? dotColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tappable(
      borderRadius: 20,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
          : getColor(context, "lightDarkAccentHeavyLight"),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              CircleAvatar(backgroundColor: dotColor, radius: 5),
              const SizedBox(width: 6),
            ],
            TextFont(
              text: label,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              textColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentListSliver(BuildContext context) {
    final currentType = _getCurrentTabType();

    return StreamBuilder<List<StudyDocument>>(
      stream: _documentDao.watchAll(type: currentType, courseId: _selectedCourseId),
      initialData: _documentDao.getAll(type: currentType, courseId: _selectedCourseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final documents = snapshot.data ?? [];
        if (documents.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: NoResults(
                message: "Chưa có tài liệu nào trong danh mục này",
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doc = documents[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudyDocumentCard(
                  document: doc,
                  onStatusChanged: (newStatus) async {
                    await _documentDao.update(doc.copyWith(status: newStatus));
                  },
                  onDelete: () async {
                    await _documentDao.delete(doc.id);
                  },
                ),
              );
            },
            childCount: documents.length,
          ),
        );
      },
    );
  }
}
