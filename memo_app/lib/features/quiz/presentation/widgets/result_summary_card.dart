import 'package:flutter/material.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../../../core/constants/app_colors.dart';

/// Result summary card showing quiz score and stats
class ResultSummaryCard extends StatelessWidget {
  final QuizResultEntity result;

  const ResultSummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_getResultColor(), _getResultColor().withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            // Pass/Fail Icon + Status + Performance in row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  result.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 58,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.passed ? 'نجحت!' : 'لم تنجح',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      result.performanceLevelAr,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Score Circle + Stats in row
            Row(
              children: [
                // Score Circle
                _buildScoreCircle(),
                const SizedBox(width: 16),
                // Stats Grid
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          label: 'صحيح',
                          value: '${result.correctAnswers}',
                          icon: Icons.check_circle_outline,
                        ),
                        _buildStat(
                          label: 'خطأ',
                          value: '${result.incorrectAnswers}',
                          icon: Icons.cancel_outlined,
                        ),
                        _buildStat(
                          label: 'متروك',
                          value: '${result.skippedAnswers}',
                          icon: Icons.remove_circle_outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Points
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${result.earnedPoints.toInt()} من ${result.totalPoints.toInt()} نقطة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle() {
    return Container(
      width: 115,
      height: 115,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
        border: Border.all(color: Colors.white, width: 6),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${result.percentage.toInt()}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'النتيجة',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Color _getResultColor() {
    if (result.percentage >= 80) return AppColors.success;
    if (result.percentage >= 60) return AppColors.primary;
    if (result.percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
