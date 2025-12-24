import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/entities/subject_entity.dart';
import 'content_list_item.dart';

/// Expandable accordion widget for displaying chapter contents
class ChapterAccordion extends StatefulWidget {
  final ChapterEntity chapter;
  final SubjectEntity subject;
  final ContentType contentType;
  final Color subjectColor;

  const ChapterAccordion({
    super.key,
    required this.chapter,
    required this.subject,
    required this.contentType,
    required this.subjectColor,
  });

  @override
  State<ChapterAccordion> createState() => _ChapterAccordionState();
}

class _ChapterAccordionState extends State<ChapterAccordion> {
  bool _isExpanded = false;

  // TODO: Replace with actual content from API
  List<ContentEntity> get _mockContents {
    final count = widget.chapter.getCountForType(_getTypeSlug());
    return List.generate(
      count,
      (index) => ContentEntity(
        id: index + 1,
        subjectId: widget.chapter.subjectId,
        chapterId: widget.chapter.id,
        contentTypeId: widget.contentType.index + 1,
        titleAr: '${_getTypeLabel()} ${index + 1}: ${_getTitleExample(index)}',
        slug: 'content-${index + 1}',
        type: widget.contentType,
        difficultyLevel: _getDifficulty(index),
        estimatedDurationMinutes: 30 + (index * 10),
        hasVideo: widget.contentType == ContentType.lesson,
        videoDurationSeconds: widget.contentType == ContentType.lesson
            ? 1800
            : null,
        hasFile: widget.contentType != ContentType.lesson,
        fileSizeBytes: widget.contentType != ContentType.lesson
            ? 2500000
            : null,
        isPublished: true,
        progressPercentage: index == 0 ? 0.65 : null,
        progressStatus: index == 0 ? 'in_progress' : null,
      ),
    );
  }

  String _getTypeSlug() {
    switch (widget.contentType) {
      case ContentType.lesson:
        return 'lesson';
      case ContentType.summary:
        return 'summary';
      case ContentType.exercise:
        return 'exercise';
      case ContentType.test:
        return 'test';
    }
  }

  String _getTypeLabel() {
    switch (widget.contentType) {
      case ContentType.lesson:
        return 'درس';
      case ContentType.summary:
        return 'ملخص';
      case ContentType.exercise:
        return 'تمارين';
      case ContentType.test:
        return 'فرض';
    }
  }

  String _getTitleExample(int index) {
    switch (widget.contentType) {
      case ContentType.lesson:
        return [
          'المفاهيم الأساسية',
          'التطبيقات العملية',
          'الحالات الخاصة',
          'المراجعة الشاملة',
        ][index % 4];
      case ContentType.summary:
        return ['ملخص شامل', 'النقاط الأساسية', 'المفاهيم المهمة'][index % 3];
      case ContentType.exercise:
        return ['تمارين محلولة', 'تمارين للتطبيق', 'تمارين متنوعة'][index % 3];
      case ContentType.test:
        return ['اختبار تقييمي', 'فرض محروس'][index % 2];
    }
  }

  DifficultyLevel _getDifficulty(int index) {
    return [
      DifficultyLevel.easy,
      DifficultyLevel.medium,
      DifficultyLevel.hard,
    ][index % 3];
  }

  @override
  Widget build(BuildContext context) {
    final contentCount = widget.chapter.getCountForType(_getTypeSlug());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          // Chapter header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Expand icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_left,
                    color: widget.subjectColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),

                  // Chapter info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chapter.titleAr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$contentCount ${_getTypeLabel()}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.subjectColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(widget.chapter.completionPercentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.subjectColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content list (shown when expanded)
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _mockContents.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final content = _mockContents[index];
                      return ContentListItem(
                        content: content,
                        subject: widget.subject,
                        subjectColor: widget.subjectColor,
                        allContents: _mockContents,
                        currentIndex: index,
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
