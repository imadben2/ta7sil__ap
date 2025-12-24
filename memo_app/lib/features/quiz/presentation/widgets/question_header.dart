import 'package:flutter/material.dart';
import '../../domain/entities/question_entity.dart';
import '../../../../core/constants/app_colors.dart';

/// Header widget for question display
class QuestionHeader extends StatelessWidget {
  final QuestionEntity question;
  final int questionNumber;
  final int totalQuestions;
  final bool isFlagged;
  final VoidCallback onToggleFlag;

  const QuestionHeader({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.isFlagged,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question number and flag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'سؤال $questionNumber من $totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  // Question type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      question.questionTypeAr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Flag button
                  IconButton(
                    onPressed: onToggleFlag,
                    icon: Icon(
                      isFlagged ? Icons.flag : Icons.flag_outlined,
                      color: isFlagged
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Question text
          Text(
            question.questionTextAr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          // Points indicator
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
              const SizedBox(width: 6),
              Text(
                '${question.points.toInt()} ${question.points == 1 ? 'نقطة' : 'نقاط'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
