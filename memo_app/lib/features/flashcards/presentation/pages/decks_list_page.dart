import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/decks/decks_bloc.dart';
import '../bloc/decks/decks_event.dart';
import '../bloc/decks/decks_state.dart';
import '../bloc/stats/flashcard_stats_bloc.dart';
import '../bloc/stats/flashcard_stats_event.dart';
import '../bloc/stats/flashcard_stats_state.dart';
import '../widgets/deck_card.dart';
import '../widgets/stats_widgets.dart';

/// Main page showing all flashcard decks
class DecksListPage extends StatefulWidget {
  const DecksListPage({super.key});

  @override
  State<DecksListPage> createState() => _DecksListPageState();
}

class _DecksListPageState extends State<DecksListPage> {
  @override
  void initState() {
    super.initState();
    context.read<DecksBloc>().add(const LoadDecks());
    context.read<FlashcardStatsBloc>().add(const LoadFlashcardStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('البطاقات التعليمية'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/flashcards/stats'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DecksBloc>().add(const RefreshDecks());
          context.read<FlashcardStatsBloc>().add(const RefreshStats());
        },
        child: CustomScrollView(
          slivers: [
            // Stats header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: _buildStatsSection(),
              ),
            ),

            // Decks section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'مجموعات البطاقات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    BlocBuilder<DecksBloc, DecksState>(
                      builder: (context, state) {
                        if (state is DecksLoaded) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingSM,
                              vertical: AppSizes.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                            ),
                            child: Text(
                              '${state.decks.length} مجموعة',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.spacingMD),
            ),

            // Decks list
            BlocBuilder<DecksBloc, DecksState>(
              builder: (context, state) {
                if (state is DecksLoading) {
                  return const SliverFillRemaining(
                    child: LoadingWidget(message: 'جاري تحميل البطاقات...'),
                  );
                }

                if (state is DecksError) {
                  return SliverFillRemaining(
                    child: app_error.AppErrorWidget(
                      message: state.message,
                      onRetry: () =>
                          context.read<DecksBloc>().add(const LoadDecks()),
                    ),
                  );
                }

                if (state is DecksLoaded) {
                  if (state.decks.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMD,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final deck = state.decks[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.spacingMD,
                            ),
                            child: DeckCard(
                              deck: deck,
                              onTap: () =>
                                  context.push('/flashcards/${deck.id}'),
                              onStartReview: () => context.push(
                                '/flashcards/${deck.id}/review',
                              ),
                            ),
                          );
                        },
                        childCount: state.decks.length,
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.spacingXL),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<FlashcardStatsBloc, FlashcardStatsState>(
      builder: (context, state) {
        // Only show the card when data is loaded
        if (state is FlashcardStatsLoaded && state.todaySummary != null) {
          return TodayStatsCard(summary: state.todaySummary!);
        }
        // Don't show anything while loading
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFFA78BFA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.today,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'إحصائيات اليوم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Loading shimmer placeholders
            Row(
              children: [
                Expanded(child: _buildLoadingStatItem()),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(child: _buildLoadingStatItem()),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(child: _buildLoadingStatItem()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatItem() {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 50,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.style_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.spacingMD),
            const Text(
              'لا توجد مجموعات بطاقات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Text(
              'ستظهر هنا مجموعات البطاقات المتاحة للدراسة',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
