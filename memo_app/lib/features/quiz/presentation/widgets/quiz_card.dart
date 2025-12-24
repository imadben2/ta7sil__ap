import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../../../core/constants/app_colors.dart';

/// Modern quiz card widget matching lesson item design
class QuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.quiz, required this.onTap});

  Color get _quizColor {
    final colorHex = quiz.difficultyColor;
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final hasAttempts = quiz.userStats != null && quiz.userStats!.attempts > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _quizColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: hasAttempts ? _quizColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Modern Status Icon
                _buildModernStatusIcon(hasAttempts),
                const SizedBox(width: 16),

                // Quiz Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with gradient text effect
                      Text(
                        quiz.titleAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: hasAttempts ? _quizColor : AppColors.slate900,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Modern stats row with pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildModernPill(
                            icon: Icons.quiz_rounded,
                            label: '${quiz.totalQuestions} سؤال',
                            color: AppColors.primary,
                          ),
                          if (quiz.isTimed)
                            _buildModernPill(
                              icon: Icons.schedule_rounded,
                              label: _formatTime(quiz.timeLimitMinutes!),
                              color: AppColors.amber500,
                            ),
                          _buildDifficultyPill(),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right side - Modern score badge or arrow
                if (hasAttempts)
                  _buildModernScoreBadge()
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _quizColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: _quizColor,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatusIcon(bool hasAttempts) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasAttempts
              ? [_quizColor, _quizColor.withOpacity(0.7)]
              : [_quizColor.withOpacity(0.15), _quizColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: hasAttempts
            ? [
                BoxShadow(
                  color: _quizColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: hasAttempts
            ? const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              )
            : Icon(
                _getQuizIcon(),
                color: _quizColor,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildModernPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_quizColor.withOpacity(0.15), _quizColor.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _quizColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_cellular_alt_rounded, size: 14, color: _quizColor),
          const SizedBox(width: 4),
          Text(
            quiz.difficultyLevelAr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _quizColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernScoreBadge() {
    final bestScore = quiz.userStats?.bestScore?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _quizColor.withOpacity(0.15),
            _quizColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _quizColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 18,
            color: _quizColor,
          ),
          const SizedBox(height: 2),
          Text(
            '$bestScore%',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _quizColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient() {
    final colorHex = quiz.difficultyColor;
    final color = Color(
      int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
    );
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withOpacity(0.8)],
    );
  }

  IconData _getQuizIcon() {
    if (quiz.isPractice) return Icons.edit_note_rounded;
    if (quiz.quizType == 'exam') return Icons.assignment_rounded;
    return Icons.timer_rounded;
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ساعة';
      } else {
        return '$hours:${mins.toString().padLeft(2, '0')} ساعة';
      }
    }
  }
}
