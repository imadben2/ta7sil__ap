import 'package:flutter/material.dart';
import '../../domain/entities/session_content.dart';

/// Widget to display session content items in a simplified list
///
/// Shows content titles grouped by parent with phase indicator
class SessionContentList extends StatelessWidget {
  final List<SessionContent> contents;
  final SessionContentMeta meta;
  final bool isLoading;
  final String? errorMessage;
  final void Function(String contentId, String phase)? onPhaseComplete;

  const SessionContentList({
    super.key,
    required this.contents,
    required this.meta,
    this.isLoading = false,
    this.errorMessage,
    this.onPhaseComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (errorMessage != null) {
      return _buildErrorState(context, errorMessage!);
    }

    if (contents.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildContentList(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'جاري تحميل المحتوى...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'لا يوجد محتوى متاح',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(BuildContext context) {
    // Check if first item is a unit (parent with children in the list)
    // In this case, show the unit as header and children as content items
    final firstContent = contents.first;
    final bool firstIsParentUnit = firstContent.level == 'unit' &&
        firstContent.parentTitle == null &&
        contents.length > 1;

    if (firstIsParentUnit) {
      // Show unit-based content: unit as header, children as items
      final unitTitle = firstContent.titleAr;
      final children = contents.skip(1).toList(); // Skip the unit itself

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with phase indicator
            _buildHeader(context),

            const Divider(height: 1),

            // Single group: unit as parent, children as items
            _buildContentGroup(context, unitTitle, children),
          ],
        ),
      );
    }

    // Default: Group contents by parent title (for non-unit content)
    final groupedContents = <String?, List<SessionContent>>{};
    for (final content in contents) {
      final parentKey = content.parentTitle ?? 'محتوى عام';
      groupedContents.putIfAbsent(parentKey, () => []).add(content);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with phase indicator
          _buildHeader(context),

          const Divider(height: 1),

          // Content groups
          ...groupedContents.entries.map((entry) => _buildContentGroup(
            context,
            entry.key ?? 'محتوى عام',
            entry.value,
          )),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'محتوى الجلسة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Phase badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getPhaseColor(context).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              meta.phaseNameAr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getPhaseColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGroup(
    BuildContext context,
    String parentTitle,
    List<SessionContent> items,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent title (unit/topic name)
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  parentTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final content = entry.value;
            final isLast = index == items.length - 1;

            return _buildContentItem(context, content, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildContentItem(
    BuildContext context,
    SessionContent content,
    bool isLast,
  ) {
    final isCompleted = content.isPhaseCompleted(meta.phaseToComplete);

    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tree connector
          Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 6, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 12,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content title
          Expanded(
            child: Text(
              content.titleAr,
              style: TextStyle(
                fontSize: 14,
                color: isCompleted
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(BuildContext context) {
    return switch (meta.phaseToComplete) {
      'understanding' => Colors.blue,
      'review' => Colors.green,
      'theory_practice' => Colors.orange,
      'exercise_practice' => Colors.purple,
      _ => Theme.of(context).colorScheme.primary,
    };
  }
}

/// Compact version of session content list for preview
class SessionContentPreview extends StatelessWidget {
  final List<SessionContent> contents;
  final int maxItems;

  const SessionContentPreview({
    super.key,
    required this.contents,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayContents = contents.take(maxItems).toList();
    final remaining = contents.length - maxItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayContents.map((content) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content.titleAr,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ $remaining عناصر أخرى',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
