import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

/// Widget for displaying a single achievement in a card format
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Card(
      elevation: achievement.unlocked ? 4 : 1,
      color: achievement.unlocked
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Achievement Icon
              _buildIcon(theme),
              const SizedBox(height: 12),

              // Achievement Title
              Text(
                isRtl ? achievement.titleAr : achievement.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: achievement.unlocked
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Progress Indicator
              if (!achievement.unlocked) ...[
                LinearProgressIndicator(
                  value: achievement.progress / 100,
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement.progress.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ] else ...[
                // Unlocked Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRtl ? 'مفتوح' : 'Unlocked',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    final iconData = _getIconData(achievement.icon);

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: achievement.unlocked
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.3),
        boxShadow: achievement.unlocked
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        iconData,
        size: 32,
        color: achievement.unlocked
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withOpacity(0.4),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'school':
        return Icons.school;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'verified':
        return Icons.verified;
      case 'military_tech':
        return Icons.military_tech;
      case 'psychology':
        return Icons.psychology;
      case 'timer':
        return Icons.timer;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.emoji_events;
    }
  }
}

/// Detailed achievement dialog
class AchievementDetailDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailDialog({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.unlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
            child: Icon(
              _getIconData(achievement.icon),
              size: 40,
              color: achievement.unlocked
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isRtl ? achievement.titleAr : achievement.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            isRtl ? achievement.descriptionAr : achievement.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Progress
          if (!achievement.unlocked) ...[
            LinearProgressIndicator(
              value: achievement.progress / 100,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl
                  ? 'التقدم: ${achievement.progress.toStringAsFixed(0)}%'
                  : 'Progress: ${achievement.progress.toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isRtl ? '🎉 تم الفتح!' : '🎉 Unlocked!',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                isRtl
                    ? 'تم الفتح في: ${_formatDate(achievement.unlockedAt!)}'
                    : 'Unlocked on: ${_formatDate(achievement.unlockedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(isRtl ? 'إغلاق' : 'Close'),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'school':
        return Icons.school;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'verified':
        return Icons.verified;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
