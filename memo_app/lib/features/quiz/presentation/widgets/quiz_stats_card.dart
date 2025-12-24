import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../../../core/constants/app_colors.dart';

/// Stats card showing quiz information before starting
class QuizStatsCard extends StatelessWidget {
  final QuizEntity quiz;

  const QuizStatsCard({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الاختبار',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.quiz_rounded,
              label: 'عدد الأسئلة',
              value: '${quiz.totalQuestions} سؤال',
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.star_rounded,
              label: 'إجمالي النقاط',
              value: '${quiz.totalPoints.toInt()} نقطة',
            ),
            if (quiz.isTimed) ...[
              const SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.timer_outlined,
                label: 'الوقت المحدد',
                value: '${quiz.timeLimitMinutes} دقيقة',
                valueColor: AppColors.warning,
              ),
            ],
            const SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.verified_rounded,
              label: 'نقطة النجاح',
              value: '${quiz.passingScore.toInt()}%',
              valueColor: AppColors.success,
            ),
            if (quiz.userStats != null && quiz.userStats!.attempts > 0) ...[
              const Divider(height: 32),
              const Text(
                'سجلك السابق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.repeat_rounded,
                label: 'المحاولات السابقة',
                value: '${quiz.userStats!.attempts}',
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                icon: Icons.emoji_events_rounded,
                label: 'أفضل نتيجة',
                value: '${quiz.userStats!.bestScore?.toInt() ?? 0}%',
                valueColor: _getScoreColor(quiz.userStats!.bestScore ?? 0.0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
