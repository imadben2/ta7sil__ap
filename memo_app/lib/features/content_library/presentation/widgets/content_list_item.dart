import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../data/datasources/content_library_remote_datasource.dart';
import '../../data/repositories/content_library_repository_impl.dart';
import '../bloc/content_viewer/content_viewer_bloc.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
import '../pages/content_viewer_page.dart';

/// List item widget for displaying individual content
class ContentListItem extends StatelessWidget {
  final ContentEntity content;
  final SubjectEntity subject;
  final Color subjectColor;
  final VoidCallback? onTap;
  final VoidCallback? onRefreshNeeded; // Called when content progress may have changed
  final List<ContentEntity>? allContents; // All contents in the chapter
  final int? currentIndex; // Current content index

  const ContentListItem({
    super.key,
    required this.content,
    required this.subject,
    required this.subjectColor,
    this.onTap,
    this.onRefreshNeeded,
    this.allContents,
    this.currentIndex,
  });

  Color get _difficultyColor {
    if (content.difficultyLevel == null) return AppColors.textSecondary;
    switch (content.difficultyLevel!) {
      case DifficultyLevel.easy:
        return const Color(0xFF10B981); // Green
      case DifficultyLevel.medium:
        return const Color(0xFFF59E0B); // Orange
      case DifficultyLevel.hard:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get _contentIcon {
    if (content.hasVideo) return Icons.play_circle_outline;
    if (content.hasFile) return Icons.description_outlined;
    return Icons.article_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = content.isCompleted;

    return InkWell(
      onTap:
          onTap ??
          () async {
            // Create repository and bloc for content viewer
            final dio = sl<Dio>();
            final dataSource = ContentLibraryRemoteDataSource(dio: dio);
            final repository = ContentLibraryRepositoryImpl(remoteDataSource: dataSource);

            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => ContentViewerBloc(repository: repository),
                    ),
                    BlocProvider(
                      create: (context) => sl<BookmarkBloc>(),
                    ),
                  ],
                  child: ContentViewerPage(
                    content: content,
                    subject: subject,
                    subjectColor: subjectColor,
                    allContents: allContents,
                    currentIndex: currentIndex,
                  ),
                ),
              ),
            );

            // If result is true, content was viewed/modified, trigger refresh
            if (result == true && onRefreshNeeded != null) {
              onRefreshNeeded!();
            }
          },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF10B981).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF10B981).withOpacity(0.3)
                : content.isInProgress
                    ? subjectColor.withOpacity(0.5)
                    : AppColors.border.withOpacity(0.5),
            width: isCompleted ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Content type icon with completion overlay
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _contentIcon,
                    color: isCompleted ? const Color(0xFF10B981) : subjectColor,
                    size: 20,
                  ),
                ),
                // Completion checkmark badge
                if (isCompleted)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Content info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    content.titleAr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Meta info row
                  Row(
                    children: [
                      // Completion status badge (replaces difficulty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 10,
                              color: isCompleted ? const Color(0xFF10B981) : Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isCompleted ? 'مكتمل' : 'غير مكتمل',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? const Color(0xFF10B981) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Duration/Size
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.hasVideo
                            ? content.formattedVideoDuration
                            : content.formattedDuration,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),

                      // File size
                      if (content.hasFile && content.fileSizeBytes != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.file_download_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.formattedFileSize,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Progress bar (if has any progress > 0)
                  if (content.progressPercentage != null &&
                      content.progressPercentage! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              // Ensure value is between 0.0 and 1.0
                              value: (content.progressPercentage! > 1
                                  ? content.progressPercentage! / 100
                                  : content.progressPercentage!)
                                  .clamp(0.0, 1.0),
                              backgroundColor: subjectColor.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(content.progressPercentage! > 1 ? content.progressPercentage! : content.progressPercentage! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subjectColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status indicator
            _buildStatusIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (content.isCompleted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF10B981),
              size: 16,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'مكتمل',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      );
    } else if (content.isInProgress) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: subjectColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.play_arrow_rounded, color: subjectColor, size: 16),
      );
    } else {
      return Icon(
        Icons.chevron_left_rounded,
        color: AppColors.textTertiary,
        size: 20,
      );
    }
  }
}
