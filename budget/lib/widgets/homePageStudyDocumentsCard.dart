import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import '../struct/studyDocument.dart';
import '../database/study_document_dao.dart';

class HomePageStudyDocumentsCard extends StatelessWidget {
  const HomePageStudyDocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final documentDao = DocumentDao();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      child: StreamBuilder<List<StudyDocument>>(
        stream: documentDao.watchAll(),
        initialData: documentDao.getAll(),
        builder: (context, snapshot) {
          final docs = snapshot.data ?? [];
          final totalCount = docs.length;
          final inProgressCount = docs.where((d) => d.status == DocumentStatus.inProgress).length;

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
                pageNavigationFrameworkKey.currentState?.changePage(18, switchNavbar: true);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextFont(
                            text: "Kho Tài liệu Học tập",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 3),
                          TextFont(
                            text: "$totalCount tài liệu  •  $inProgressCount tài liệu đang học",
                            fontSize: 12,
                            textColor: getColor(context, "textLight"),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: getColor(context, "textLight"),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
