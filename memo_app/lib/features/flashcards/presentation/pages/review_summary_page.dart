import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../bloc/review/review_state.dart';

/// Page showing summary after completing a review session
class ReviewSummaryPage extends StatelessWidget {
  final ReviewCompleted result;
  final int deckId;

  const ReviewSummaryPage({
    super.key,
    required this.result,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/flashcards'),
        ),
        title: const Text('نتيجة المراجعة'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.spacingLG),

              // Result card
              _buildResultCard(),

              const SizedBox(height: AppSizes.spacingLG),

              // Stats breakdown
              _buildStatsBreakdown(),

              const SizedBox(height: AppSizes.spacingLG),

              // Performance message
              _buildPerformanceMessage(),

              const SizedBox(height: AppSizes.spacingXL),

              // Action buttons
              _buildActionButtons(context),

              const SizedBox(height: AppSizes.spacingLG),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final accuracy = result.accuracy;
    final color = _getColorForAccuracy(accuracy);
    final emoji = _getEmojiForAccuracy(accuracy);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: AppSizes.spacingMD),
          Text(
            '${accuracy.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSM),
          Text(
            _getPerformanceTitle(accuracy),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBreakdown() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.style_rounded,
            label: 'إجمالي البطاقات',
            value: '${result.totalCards}',
            color: AppColors.primary,
          ),
          const Divider(height: 24),
          _StatRow(
            icon: Icons.check_circle_rounded,
            label: 'إجابات صحيحة',
            value: '${result.correctCount}',
            color: AppColors.success,
          ),
          const Divider(height: 24),
          _StatRow(
            icon: Icons.cancel_rounded,
            label: 'إجابات خاطئة',
            value: '${result.incorrectCount}',
            color: AppColors.error,
          ),
          const Divider(height: 24),
          _StatRow(
            icon: Icons.timer_outlined,
            label: 'وقت المراجعة',
            value: _formatDuration(result.duration),
            color: AppColors.info,
          ),
          const Divider(height: 24),
          _StatRow(
            icon: Icons.speed_rounded,
            label: 'متوسط الوقت للبطاقة',
            value: _formatAverageTime(),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMessage() {
    final accuracy = result.accuracy;
    final message = _getPerformanceMessage(accuracy);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: AppColors.info,
            size: AppSizes.iconMD,
          ),
          const SizedBox(width: AppSizes.spacingMD),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Review again button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.pushReplacement(
              '/flashcards/$deckId/review',
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('مراجعة أخرى'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.spacingMD),

        // Back to decks button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/flashcards'),
            icon: const Icon(Icons.home_rounded),
            label: const Text('العودة للمجموعات'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForAccuracy(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.primary;
    if (accuracy >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _getEmojiForAccuracy(double accuracy) {
    if (accuracy >= 90) return '🌟';
    if (accuracy >= 80) return '🎉';
    if (accuracy >= 60) return '👍';
    if (accuracy >= 40) return '💪';
    return '📚';
  }

  String _getPerformanceTitle(double accuracy) {
    if (accuracy >= 90) return 'ممتاز!';
    if (accuracy >= 80) return 'رائع جداً!';
    if (accuracy >= 60) return 'أداء جيد!';
    if (accuracy >= 40) return 'تحتاج مراجعة أكثر';
    return 'استمر في التعلم';
  }

  String _getPerformanceMessage(double accuracy) {
    if (accuracy >= 90) {
      return 'أداء مذهل! أنت تتقن هذه المادة بشكل ممتاز. استمر في المراجعة للحفاظ على هذا المستوى.';
    }
    if (accuracy >= 80) {
      return 'عمل رائع! أنت في الطريق الصحيح. ركز على البطاقات التي أخطأت فيها.';
    }
    if (accuracy >= 60) {
      return 'أداء جيد! حاول مراجعة البطاقات الصعبة بشكل متكرر لتحسين مستواك.';
    }
    if (accuracy >= 40) {
      return 'لا تقلق! التعلم يحتاج وقتاً. راجع البطاقات يومياً لتحسين ذاكرتك.';
    }
    return 'كل خبير كان مبتدئاً يوماً ما. استمر في المراجعة وستلاحظ تحسناً ملحوظاً!';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes د $seconds ث';
    }
    return '$seconds ثانية';
  }

  String _formatAverageTime() {
    if (result.totalCards == 0) return '-';
    final avgSeconds = result.duration.inSeconds / result.totalCards;
    if (avgSeconds >= 60) {
      final mins = (avgSeconds / 60).floor();
      final secs = (avgSeconds % 60).round();
      return '$mins د $secs ث';
    }
    return '${avgSeconds.round()} ث';
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(icon, color: color, size: AppSizes.iconSM),
        ),
        const SizedBox(width: AppSizes.spacingMD),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
