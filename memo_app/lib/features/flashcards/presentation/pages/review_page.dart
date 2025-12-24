import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../bloc/review/review_bloc.dart';
import '../bloc/review/review_event.dart';
import '../bloc/review/review_state.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/review_buttons.dart';
import '../widgets/review_progress_bar.dart';

/// Page for reviewing flashcards in a session
class ReviewPage extends StatefulWidget {
  final int deckId;
  final int? cardLimit;
  final bool shuffle;
  final bool browseMode;

  const ReviewPage({
    super.key,
    required this.deckId,
    this.cardLimit,
    this.shuffle = false,
    this.browseMode = false,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(StartReviewSession(
          deckId: widget.deckId,
          cardLimit: widget.cardLimit,
          browseMode: widget.browseMode,
          shuffle: widget.shuffle,
        ));
  }

  void _submitAnswer(String response, int cardId) {
    context.read<ReviewBloc>().add(SubmitCardAnswer(
          cardId: cardId,
          response: response,
        ));
  }

  Future<bool> _onWillPop() async {
    final state = context.read<ReviewBloc>().state;
    // In browse mode, no confirmation needed
    if (state is ReviewActive && state.browseMode) {
      return true;
    }
    if (state is ReviewActive && state.cardsReviewed > 0) {
      return await _showExitConfirmation() ?? false;
    }
    return true;
  }

  Future<bool?> _showExitConfirmation() {
    final reviewBloc = context.read<ReviewBloc>();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إنهاء المراجعة؟'),
        content: const Text(
          'سيتم حفظ تقدمك الحالي. هل تريد الخروج؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('متابعة'),
          ),
          TextButton(
            onPressed: () {
              reviewBloc.add(const AbandonReview());
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocConsumer<ReviewBloc, ReviewState>(
          listener: (context, state) {
            // In browse mode, don't navigate to summary
            if (state is ReviewCompleted && !widget.browseMode) {
              context.pushReplacement(
                '/flashcards/${widget.deckId}/summary',
                extra: state,
              );
            }
          },
          builder: (context, state) {
            if (state is ReviewLoading) {
              return const LoadingWidget(
                message: 'جاري تحميل البطاقات...',
              );
            }

            if (state is ReviewError) {
              return app_error.AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<ReviewBloc>().add(
                      StartReviewSession(deckId: widget.deckId),
                    ),
              );
            }

            if (state is ReviewActive) {
              return _buildReviewContent(state);
            }

            if (state is ReviewSubmitting) {
              return _buildReviewContent(state.previousState, isSubmitting: true);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () async {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        },
      ),
      title: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state is ReviewActive) {
            if (state.browseMode) {
              return Text(
                'استعراض البطاقات (${state.currentCardIndex + 1}/${state.totalCards})',
                style: const TextStyle(fontSize: 16),
              );
            }
            return ReviewProgressBar(
              currentCard: state.cardsReviewed + 1,
              totalCards: state.totalCards,
              correctCount: state.correctCount,
              incorrectCount: state.incorrectCount,
              elapsedTime: Duration(seconds: state.elapsedSeconds),
            );
          }
          return const Text('مراجعة');
        },
      ),
    );
  }

  Widget _buildReviewContent(ReviewActive state, {bool isSubmitting = false}) {
    final currentCard = state.currentCard;
    final isAnswered = state.answers.containsKey(currentCard.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          children: [
            // Card display
            Expanded(
              child: FlashcardWidget(
                card: currentCard,
                isFlipped: state.isCardFlipped,
                onFlip: () => context.read<ReviewBloc>().add(const FlipCard()),
              ),
            ),

            const SizedBox(height: AppSizes.spacingLG),

            // Answer buttons or explanation
            if (state.browseMode)
              _buildBrowseNavigation(state)
            else if (state.isCardFlipped && !isAnswered)
              _buildAnswerSection(currentCard, isSubmitting)
            else if (!state.isCardFlipped)
              _buildFlipHint()
            else if (isAnswered)
              _buildAnsweredState(state),

            const SizedBox(height: AppSizes.spacingMD),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(FlashcardEntity card, bool isSubmitting) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Explanation if available
        if (card.explanationAr != null && card.explanationAr!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            margin: const EdgeInsets.only(bottom: AppSizes.spacingMD),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'شرح',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingSM),
                Text(
                  card.explanationAr!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Review buttons - Correct maps to 'good', Wrong maps to 'again'
        ReviewButtons(
          onCorrect: () => _submitAnswer('good', card.id),
          onWrong: () => _submitAnswer('again', card.id),
          enabled: !isSubmitting,
        ),
      ],
    );
  }

  Widget _buildFlipHint() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: AppColors.textSecondary,
            size: AppSizes.iconMD,
          ),
          const SizedBox(width: AppSizes.spacingSM),
          Text(
            'اضغط على البطاقة لرؤية الإجابة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseNavigation(ReviewActive state) {
    final canGoPrevious = state.currentCardIndex > 0;
    final canGoNext = state.currentCardIndex < state.cards.length - 1;

    return Column(
      children: [
        // Card counter
        Text(
          '${state.currentCardIndex + 1} / ${state.cards.length}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMD),
        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canGoPrevious
                    ? () => context.read<ReviewBloc>().add(const PreviousCard())
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('السابقة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: canGoPrevious ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingMD),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canGoNext
                    ? () => context.read<ReviewBloc>().add(const NextCard())
                    : () => context.pop(),
                icon: Icon(canGoNext ? Icons.arrow_back_rounded : Icons.check_rounded),
                label: Text(canGoNext ? 'التالية' : 'إنهاء'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnsweredState(ReviewActive state) {
    final answer = state.answers[state.currentCard.id];
    final isCorrect = answer?.wasCorrect ?? false;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSizes.spacingSM),
          Text(
            isCorrect ? 'أحسنت!' : 'حاول مرة أخرى',
            style: TextStyle(
              color: isCorrect ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
