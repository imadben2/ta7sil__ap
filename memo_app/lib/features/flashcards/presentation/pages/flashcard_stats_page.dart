import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/stats/flashcard_stats_bloc.dart';
import '../bloc/stats/flashcard_stats_event.dart';
import '../bloc/stats/flashcard_stats_state.dart';
import '../widgets/stats_widgets.dart';

/// Page showing detailed flashcard statistics
class FlashcardStatsPage extends StatefulWidget {
  const FlashcardStatsPage({super.key});

  @override
  State<FlashcardStatsPage> createState() => _FlashcardStatsPageState();
}

class _FlashcardStatsPageState extends State<FlashcardStatsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FlashcardStatsBloc>().add(const LoadFlashcardStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'إحصائيات البطاقات',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<FlashcardStatsBloc, FlashcardStatsState>(
        builder: (context, state) {
          if (state is FlashcardStatsLoading) {
            return const LoadingWidget(
              message: 'جاري تحميل الإحصائيات...',
            );
          }

          if (state is FlashcardStatsError) {
            return app_error.AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<FlashcardStatsBloc>()
                  .add(const LoadFlashcardStats()),
            );
          }

          if (state is FlashcardStatsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FlashcardStatsBloc>().add(const RefreshStats());
              },
              color: const Color(0xFF8B5CF6),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Today's summary
                    if (state.todaySummary != null) ...[
                      TodayStatsCard(summary: state.todaySummary!),
                      const SizedBox(height: 20),
                    ],

                    // Overall stats
                    if (state.stats != null) ...[
                      OverallStatsWidget(stats: state.stats!),
                      const SizedBox(height: 20),
                    ],

                    // Forecast
                    if (state.forecast != null && state.forecast!.isNotEmpty) ...[
                      ForecastWidget(forecast: state.forecast!),
                      const SizedBox(height: 20),
                    ],

                    // Deck breakdown
                    if (state.stats != null &&
                        state.stats!.deckStats.isNotEmpty) ...[
                      _buildDeckStatsSection(state),
                      const SizedBox(height: 20),
                    ],

                    // Tips section
                    _buildTipsSection(state),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDeckStatsSection(FlashcardStatsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إحصائيات المجموعات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Deck cards
          ...state.stats!.deckStats.map(
            (deckStat) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ModernDeckStatCard(deckStat: deckStat),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(FlashcardStatsLoaded state) {
    final tips = _generateTips(state);
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'نصائح للتحسين',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tips
          ...tips.map((tip) => _ModernTipCard(tip: tip)),
        ],
      ),
    );
  }

  List<String> _generateTips(FlashcardStatsLoaded state) {
    final tips = <String>[];

    // Check retention rate
    if (state.stats != null && state.stats!.averageRetention < 70) {
      tips.add('نسبة الاحتفاظ منخفضة. حاول المراجعة بشكل يومي لتحسينها.');
    }

    // Check if there are due cards
    if (state.todaySummary != null && state.todaySummary!.cardsDue > 20) {
      tips.add('لديك العديد من البطاقات للمراجعة. حاول تقسيمها على عدة جلسات.');
    }

    // Check streak
    if (state.todaySummary != null && state.todaySummary!.streakDays == 0) {
      tips.add('ابدأ سلسلة مراجعة يومية للحفاظ على ذاكرتك نشطة!');
    }

    // General tips if no specific ones
    if (tips.isEmpty) {
      tips.add('استمر في المراجعة اليومية للحفاظ على مستواك الممتاز!');
    }

    return tips;
  }
}

class _ModernDeckStatCard extends StatelessWidget {
  final dynamic deckStat;

  const _ModernDeckStatCard({required this.deckStat});

  @override
  Widget build(BuildContext context) {
    final masteryPercentage = (deckStat.masteryPercentage ?? 0.0) as double;
    final color = _getColorFromMastery(masteryPercentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deckStat.deckTitle ?? 'مجموعة',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${masteryPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: masteryPercentage / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Stats chips
          Row(
            children: [
              _ModernMiniStatChip(
                label: 'للمراجعة',
                value: '${deckStat.cardsDue ?? 0}',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _ModernMiniStatChip(
                label: 'متقنة',
                value: '${deckStat.cardsMastered ?? 0}',
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorFromMastery(double percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFF0EA5E9);
    if (percentage >= 25) return const Color(0xFFF59E0B);
    return const Color(0xFF8B5CF6);
  }
}

class _ModernMiniStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ModernMiniStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTipCard extends StatelessWidget {
  final String tip;

  const _ModernTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFEF3C7).withValues(alpha: 0.8),
            const Color(0xFFFDE68A).withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: Color(0xFFD97706),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF92400E),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
