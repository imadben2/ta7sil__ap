import 'package:flutter/material.dart';

/// Widget for displaying user points and level
/// Supports two modes: compact (header) and full (dashboard)
class PointsDisplayWidget extends StatelessWidget {
  final int totalPoints;
  final int currentLevel;
  final int pointsToNextLevel;
  final bool isCompact;
  final VoidCallback? onTap;

  const PointsDisplayWidget({
    Key? key,
    required this.totalPoints,
    required this.currentLevel,
    required this.pointsToNextLevel,
    this.isCompact = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCompact ? _buildCompactMode(context) : _buildFullMode(context);
  }

  /// Compact mode for app bar / header
  Widget _buildCompactMode(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: colorScheme.primary, size: 18),
            const SizedBox(width: 4),
            Text(
              '$totalPoints',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color: colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            Text(
              'المستوى $currentLevel',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  /// Full mode for dashboard with progress bar
  Widget _buildFullMode(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate points in current level
    final int pointsInLevel = _calculatePointsInCurrentLevel();
    final int pointsNeededForLevel = _calculatePointsNeededForLevel(
      currentLevel,
    );
    final double progress = pointsInLevel / pointsNeededForLevel;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي النقاط',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            '$totalPoints',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildLevelBadge(context),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'التقدم إلى المستوى ${currentLevel + 1}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getLevelColor(currentLevel),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$pointsToNextLevel',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'تحتاج $pointsToNextLevel نقطة للمستوى التالي',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = _getLevelColor(currentLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor.withOpacity(0.8), levelColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getLevelIcon(currentLevel), color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            'المستوى $currentLevel',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return const Color(0xFF9C27B0); // Purple
    if (level >= 15) return const Color(0xFFFF5722); // Deep Orange
    if (level >= 10) return const Color(0xFFF44336); // Red
    if (level >= 5) return const Color(0xFFFF9800); // Orange
    return const Color(0xFF4CAF50); // Green
  }

  IconData _getLevelIcon(int level) {
    if (level >= 20) return Icons.emoji_events; // Trophy
    if (level >= 15) return Icons.local_fire_department; // Fire
    if (level >= 10) return Icons.diamond; // Diamond
    if (level >= 5) return Icons.bolt; // Bolt
    return Icons.star; // Star
  }

  int _calculatePointsInCurrentLevel() {
    int totalNeededForCurrentLevel = 0;
    for (int i = 1; i < currentLevel; i++) {
      totalNeededForCurrentLevel += _calculatePointsNeededForLevel(i);
    }
    return totalPoints - totalNeededForCurrentLevel;
  }

  int _calculatePointsNeededForLevel(int level) {
    // Formula: 100 * level (matches backend logic)
    return 100 * level;
  }
}

/// Animated points counter widget
class AnimatedPointsCounter extends StatefulWidget {
  final int points;
  final Duration duration;
  final TextStyle? textStyle;

  const AnimatedPointsCounter({
    Key? key,
    required this.points,
    this.duration = const Duration(milliseconds: 1500),
    this.textStyle,
  }) : super(key: key);

  @override
  State<AnimatedPointsCounter> createState() => _AnimatedPointsCounterState();
}

class _AnimatedPointsCounterState extends State<AnimatedPointsCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(
      begin: 0,
      end: widget.points,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPointsCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _animation = IntTween(begin: _animation.value, end: widget.points)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}', style: widget.textStyle);
      },
    );
  }
}
