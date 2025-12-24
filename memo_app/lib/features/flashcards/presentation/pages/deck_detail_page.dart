import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/flashcard_deck_entity.dart';
import '../bloc/decks/decks_bloc.dart';
import '../bloc/decks/decks_event.dart';
import '../bloc/decks/decks_state.dart';

/// Detail page for a single flashcard deck
class DeckDetailPage extends StatefulWidget {
  final int deckId;

  const DeckDetailPage({
    super.key,
    required this.deckId,
  });

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DecksBloc>().add(LoadDeckDetails(widget.deckId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DecksBloc, DecksState>(
      builder: (context, state) {
        FlashcardDeckEntity? deck;

        if (state is DeckDetailsLoaded) {
          deck = state.deck;
        } else if (state is DeckDetailsLoading) {
          // Loading state handled below
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App bar with deck info
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: _parseColor(deck?.color),
                foregroundColor: AppColors.textOnPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(right: 56, left: 16, bottom: 16),
                  title: Text(
                    deck?.titleAr ?? 'تفاصيل المجموعة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: _buildHeaderBackground(deck),
                ),
              ),

              // Content
              if (state is DeckDetailsLoading)
                const SliverFillRemaining(
                  child: LoadingWidget(message: 'جاري التحميل...'),
                )
              else if (state is DecksError)
                SliverFillRemaining(
                  child: app_error.AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<DecksBloc>().add(
                          LoadDeckDetails(widget.deckId),
                        ),
                  ),
                )
              else if (deck != null)
                SliverToBoxAdapter(
                  child: _buildDeckContent(deck),
                ),
            ],
          ),
          bottomNavigationBar: deck != null
              ? _buildBottomBar(deck)
              : null,
        );
      },
    );
  }

  Widget _buildHeaderBackground(FlashcardDeckEntity? deck) {
    final color = _parseColor(deck?.color);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color, color.withOpacity(0.7)],
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, __) => const Icon(
                  Icons.style_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Subject badge
          if (deck?.subject != null)
            Positioned(
              bottom: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSM,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.overlayWhite20,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Text(
                  deck!.subject!.nameAr,
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeckContent(FlashcardDeckEntity deck) {
    final progress = deck.userProgress;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (deck.descriptionAr != null && deck.descriptionAr!.isNotEmpty) ...[
            const Text(
              'الوصف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Text(
              deck.descriptionAr!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLG),
          ],

          // Stats grid
          const Text(
            'إحصائيات المجموعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMD),
          _buildStatsGrid(deck, progress),

          const SizedBox(height: AppSizes.spacingLG),

          // Progress section
          if (progress != null) ...[
            const Text(
              'تقدمك',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMD),
            _buildProgressSection(progress),
          ],

          const SizedBox(height: AppSizes.spacingLG),

          // Quick actions
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMD),
          _buildQuickActions(deck),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildStatsGrid(FlashcardDeckEntity deck, UserDeckProgress? progress) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.style_rounded,
            label: 'إجمالي البطاقات',
            value: '${deck.totalCards}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule_rounded,
            label: 'للمراجعة',
            value: '${progress?.cardsDue ?? 0}',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSizes.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_awesome_rounded,
            label: 'جديدة',
            value: '${progress?.cardsNew ?? 0}',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(UserDeckProgress progress) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Mastery progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'نسبة الإتقان',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${progress.masteryPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSM),
          LinearProgressIndicator(
            value: progress.masteryPercentage / 100,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),

          const SizedBox(height: AppSizes.spacingMD),
          const Divider(),
          const SizedBox(height: AppSizes.spacingMD),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'تمت دراستها',
                  value: '${progress.cardsStudied}',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'تم إتقانها',
                  value: '${progress.cardsMastered}',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'نسبة الاحتفاظ',
                  value: '${progress.averageRetention.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),

          if (progress.lastStudiedAt != null) ...[
            const SizedBox(height: AppSizes.spacingMD),
            Text(
              'آخر دراسة: ${_formatDate(progress.lastStudiedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(FlashcardDeckEntity deck) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.library_books_outlined,
            label: 'استعراض الكل',
            onTap: () => context.push('/flashcards/${deck.id}/review?mode=browse'),
          ),
        ),
        const SizedBox(width: AppSizes.spacingMD),
        Expanded(
          child: _ActionButton(
            icon: Icons.shuffle_rounded,
            label: 'مراجعة عشوائية',
            onTap: () => context.push('/flashcards/${deck.id}/review?shuffle=true'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(FlashcardDeckEntity deck) {
    final cardsDue = deck.userProgress?.cardsDue ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => context.push('/flashcards/${deck.id}/review'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            cardsDue > 0 ? 'ابدأ المراجعة ($cardsDue بطاقة)' : 'ابدأ التعلم',
          ),
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
    );
  }

  Color _parseColor(String? colorString) {
    try {
      if (colorString != null && colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
    } catch (_) {}
    return AppColors.primary;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconMD),
          const SizedBox(height: AppSizes.spacingSM),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: AppSizes.spacingSM),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
