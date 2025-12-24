import 'package:flutter/material.dart';
import 'achievement_badge.dart';

/// Achievements grid layout widget
///
/// Displays achievements in a responsive grid:
/// - 2 columns on mobile
/// - 3 columns on tablets
/// - 4 columns on desktop
/// - Sorted: unlocked first, then by progress
/// - Tap badge to show detail dialog
/// - Empty state handling
///
/// Usage:
/// ```dart
/// AchievementsGrid(
///   achievements: [
///     AchievementModel(...),
///     AchievementModel(...),
///   ],
/// )
/// ```
class AchievementsGrid extends StatelessWidget {
  /// List of achievements to display
  final List<AchievementModel> achievements;

  /// Number of columns (null = auto-responsive)
  final int? crossAxisCount;

  /// Spacing between grid items
  final double spacing;

  /// Whether to show section headers (unlocked/locked)
  final bool showHeaders;

  const AchievementsGrid({
    Key? key,
    required this.achievements,
    this.crossAxisCount,
    this.spacing = 16,
    this.showHeaders = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if achievements list is empty
    if (achievements.isEmpty) {
      return _buildEmptyState();
    }

    // Sort achievements: unlocked first, then by progress
    final sortedAchievements = _sortAchievements(achievements);

    // Determine responsive column count
    final columns = crossAxisCount ?? _getResponsiveColumns(context);

    if (showHeaders) {
      return _buildWithHeaders(sortedAchievements, columns);
    }

    return _buildGrid(sortedAchievements, columns);
  }

  /// Sort achievements by unlock status and progress
  List<AchievementModel> _sortAchievements(List<AchievementModel> list) {
    final sorted = List<AchievementModel>.from(list);

    sorted.sort((a, b) {
      // Unlocked first
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;

      // Among unlocked: sort by unlock date (most recent first)
      if (a.isUnlocked && b.isUnlocked) {
        if (a.unlockedAt != null && b.unlockedAt != null) {
          return b.unlockedAt!.compareTo(a.unlockedAt!);
        }
        return 0;
      }

      // Among locked: sort by progress percentage (highest first)
      final aProgress = a.progressPercentage;
      final bProgress = b.progressPercentage;
      return bProgress.compareTo(aProgress);
    });

    return sorted;
  }

  /// Get responsive column count based on screen width
  int _getResponsiveColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) return 4; // Desktop
    if (width > 600) return 3; // Tablet
    return 2; // Mobile
  }

  /// Build grid without section headers
  Widget _buildGrid(List<AchievementModel> achievements, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.85, // Slightly taller than square
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementBadge(
          achievement: achievement,
          onTap: () => _showAchievementDetails(context, achievement),
        );
      },
    );
  }

  /// Build grid with section headers (Unlocked / Locked)
  Widget _buildWithHeaders(List<AchievementModel> achievements, int columns) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Unlocked section
          if (unlocked.isNotEmpty) ...[
            _buildSectionHeader(
              title: 'الإنجازات المفتوحة',
              count: unlocked.length,
              icon: Icons.emoji_events,
            ),
            _buildGrid(unlocked, columns),
          ],

          // Locked section
          if (locked.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              title: 'الإنجازات المقفلة',
              count: locked.length,
              icon: Icons.lock_outline,
            ),
            _buildGrid(locked, columns),
          ],
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show achievement details dialog
  void _showAchievementDetails(BuildContext context, AchievementModel achievement) {
    showDialog(
      context: context,
      builder: (context) => AchievementDetailsDialog(achievement: achievement),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إنجازات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'استمر في التعلم لفتح إنجازات جديدة',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Achievement details dialog
class AchievementDetailsDialog extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementDetailsDialog({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large badge icon
              CompactAchievementBadge(
                achievement: achievement,
                size: 100,
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Progress or unlock date
              if (achievement.isUnlocked) ...[
                _buildUnlockInfo(),
              ] else if (achievement.progress != null && achievement.goal != null) ...[
                _buildProgressInfo(),
              ],

              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build unlock information (date and congratulations)
  Widget _buildUnlockInfo() {
    final date = achievement.unlockedAt!;
    final formattedDate = '${date.year}/${date.month}/${date.day}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'تم الإنجاز!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'بتاريخ: $formattedDate',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress information
  Widget _buildProgressInfo() {
    final progress = achievement.progress!;
    final goal = achievement.goal!;
    final percentage = achievement.progressPercentage;
    final remaining = goal - progress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Text(
            'التقدم',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$progress / $goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / goal,
              minHeight: 8,
              backgroundColor: Colors.blue[100],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% مكتمل',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
              color: Colors.blue[600],
            ),
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 4),
            Text(
              'باقي: $remaining',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Cairo',
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal scrollable achievements row (for dashboard preview)
class HorizontalAchievementsRow extends StatelessWidget {
  final List<AchievementModel> achievements;
  final VoidCallback? onSeeAll;

  const HorizontalAchievementsRow({
    Key? key,
    required this.achievements,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with "See All" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإنجازات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Horizontal scrollable list
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return SizedBox(
                width: 100,
                child: AchievementBadge(
                  achievement: achievement,
                  onTap: () => _showDetails(context, achievement),
                  showProgress: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, AchievementModel achievement) {
    showDialog(
      context: context,
      builder: (context) => AchievementDetailsDialog(achievement: achievement),
    );
  }
}
