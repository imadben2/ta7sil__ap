import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/quiz_attempt/quiz_attempt_bloc.dart';
import '../bloc/quiz_attempt/quiz_attempt_event.dart';
import '../bloc/quiz_attempt/quiz_attempt_state.dart';
import '../bloc/quiz_timer/quiz_timer_cubit.dart';
import '../bloc/quiz_timer/quiz_timer_state.dart';
import '../widgets/question_header.dart';
import '../widgets/quiz_timer_widget.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/question_navigation.dart';
import '../widgets/questions/single_choice_widget.dart';
import '../widgets/questions/multiple_choice_widget.dart';
import '../widgets/questions/true_false_widget.dart';
import '../widgets/questions/fill_blank_widget.dart';
import '../widgets/questions/short_answer_widget.dart';
import '../widgets/questions/numeric_widget.dart';
import '../widgets/questions/matching_widget.dart';
import '../widgets/questions/ordering_widget.dart';
import '../../domain/entities/single_choice_question.dart';
import '../../domain/entities/multiple_choice_question.dart';
import '../../domain/entities/true_false_question.dart';
import '../../domain/entities/fill_blank_question.dart';
import '../../domain/entities/short_answer_question.dart';
import '../../domain/entities/numeric_question.dart';
import '../../domain/entities/matching_question.dart';
import '../../domain/entities/ordering_question.dart';

/// Quiz taking page - active quiz interface
class QuizTakingPage extends StatefulWidget {
  final int attemptId;

  const QuizTakingPage({super.key, required this.attemptId});

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  @override
  void initState() {
    super.initState();
    context.read<QuizAttemptBloc>().add(const LoadCurrentAttempt());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizAttemptBloc, QuizAttemptState>(
      listener: (context, state) {
        if (state is QuizAttemptSubmitted) {
          context.go('/quiz/results/${state.result.attemptId}');
        } else if (state is QuizAttemptAbandoned) {
          // Navigate back to quiz detail page
          context.go('/quiz/${state.quizId}');
          // Show snackbar after a short delay to ensure the new page is mounted
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إلغاء الاختبار')),
              );
            }
          });
        } else if (state is QuizAttemptError) {
          // Show error message for any failures
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: BlocListener<QuizTimerCubit, QuizTimerState>(
        listener: (context, state) {
          if (state is QuizTimerExpired) {
            _showTimeExpiredDialog();
          }
        },
        child: WillPopScope(
          onWillPop: () => _onWillPop(),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: BlocBuilder<QuizAttemptBloc, QuizAttemptState>(
                builder: (context, state) {
                  if (state is QuizAttemptLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is QuizAttemptError) {
                    // If we have a previous state, show quiz and let listener handle error
                    if (state.previousState != null) {
                      return _buildActiveQuiz(state.previousState!, false);
                    }
                    return _buildErrorState(state.message);
                  }

                  if (state is NoActiveAttempt) {
                    return _buildNoAttemptState();
                  }

                  if (state is QuizAttemptActive ||
                      state is QuizAttemptSavingAnswer ||
                      state is QuizAttemptSubmitting ||
                      state is QuizAttemptAbandoning) {
                    QuizAttemptActive? activeState;
                    if (state is QuizAttemptActive) {
                      activeState = state;
                    } else if (state is QuizAttemptSavingAnswer) {
                      activeState = state.previousState;
                    } else if (state is QuizAttemptSubmitting) {
                      activeState = state.previousState;
                    }

                    // For abandoning state, show loading indicator
                    if (state is QuizAttemptAbandoning || activeState == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return _buildActiveQuiz(
                      activeState,
                      state is QuizAttemptSubmitting,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQuiz(QuizAttemptActive state, bool isSubmitting) {
    final question = state.currentQuestion;
    final questionNumber = state.currentQuestionIndex + 1;

    return Column(
      children: [
        _buildAppBar(state),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDesignTokens.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuestionHeader(
                  question: question,
                  questionNumber: questionNumber,
                  totalQuestions: state.attempt.questions.length,
                  isFlagged: state.flaggedQuestions.contains(question.id),
                  onToggleFlag: () {
                    context.read<QuizAttemptBloc>().add(
                      ToggleQuestionFlag(questionId: question.id),
                    );
                  },
                ),
                SizedBox(height: AppDesignTokens.spacingXXL),
                _buildQuestionWidget(question, state),
              ],
            ),
          ),
        ),
        _buildBottomBar(state, isSubmitting),
      ],
    );
  }

  Widget _buildAppBar(QuizAttemptActive state) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showExitDialog,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.error,
          ),
          SizedBox(width: AppDesignTokens.spacingMD),
          Expanded(
            child: QuizProgressBar(
              answeredCount: state.answeredCount,
              totalQuestions: state.attempt.questions.length,
              showLabel: false,
            ),
          ),
          SizedBox(width: AppDesignTokens.spacingMD),
          if (state.attempt.timeLimitSeconds != null)
            const CompactTimerWidget(),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(question, QuizAttemptActive state) {
    if (question is SingleChoiceQuestion) {
      final answer = state.answers[question.id];
      int? selectedAnswer;
      if (answer is int) {
        selectedAnswer = answer;
      } else if (answer is Map && answer['answer'] != null) {
        selectedAnswer = answer['answer'] is int ? answer['answer'] : int.tryParse(answer['answer'].toString());
      }
      return SingleChoiceWidget(
        question: question,
        selectedAnswer: selectedAnswer,
        onAnswerSelected: (answer) => _saveAnswer(question.id, answer),
      );
    } else if (question is MultipleChoiceQuestion) {
      final answer = state.answers[question.id];
      List<int>? selectedAnswers;
      if (answer is List) {
        selectedAnswers = List<int>.from(answer);
      } else if (answer is Map && answer['answer'] != null) {
        selectedAnswers = answer['answer'] is List ? List<int>.from(answer['answer']) : null;
      }
      return MultipleChoiceWidget(
        question: question,
        selectedAnswers: selectedAnswers,
        onAnswersSelected: (answers) => _saveAnswer(question.id, answers),
      );
    } else if (question is TrueFalseQuestion) {
      final answer = state.answers[question.id];
      bool? selectedAnswer;
      if (answer is bool) {
        selectedAnswer = answer;
      } else if (answer is Map && answer['answer'] != null) {
        final val = answer['answer'];
        if (val is bool) {
          selectedAnswer = val;
        } else if (val is String) {
          selectedAnswer = val.toLowerCase() == 'true';
        }
      }
      return TrueFalseWidget(
        question: question,
        selectedAnswer: selectedAnswer,
        onAnswerSelected: (answer) => _saveAnswer(question.id, answer),
      );
    } else if (question is FillBlankQuestion) {
      final answer = state.answers[question.id];
      List<String>? answers;
      if (answer is List) {
        answers = List<String>.from(answer);
      } else if (answer is Map && answer['answer'] != null) {
        answers = answer['answer'] is List ? List<String>.from(answer['answer']) : null;
      }
      return FillBlankWidget(
        question: question,
        answers: answers,
        onAnswersChanged: (answers) => _saveAnswer(question.id, answers),
      );
    } else if (question is ShortAnswerQuestion) {
      final answer = state.answers[question.id];
      String? answerText;
      if (answer is String) {
        answerText = answer;
      } else if (answer is Map && answer['answer'] != null) {
        answerText = answer['answer'].toString();
      }
      return ShortAnswerWidget(
        question: question,
        answer: answerText,
        onAnswerChanged: (answer) => _saveAnswer(question.id, answer),
      );
    } else if (question is NumericQuestion) {
      final answer = state.answers[question.id];
      double? answerValue;
      if (answer is num) {
        answerValue = answer.toDouble();
      } else if (answer is String) {
        answerValue = double.tryParse(answer);
      } else if (answer is Map && answer['answer'] != null) {
        final val = answer['answer'];
        if (val is num) {
          answerValue = val.toDouble();
        } else {
          answerValue = double.tryParse(val.toString());
        }
      }
      return NumericWidget(
        question: question,
        answer: answerValue,
        onAnswerChanged: (answer) => _saveAnswer(question.id, answer),
      );
    } else if (question is MatchingQuestion) {
      final answer = state.answers[question.id];
      Map<String, String>? pairs;
      if (answer is Map) {
        if (answer['answer'] != null && answer['answer'] is Map) {
          pairs = Map<String, String>.from(answer['answer']);
        } else if (!answer.containsKey('answer')) {
          pairs = Map<String, String>.from(answer);
        }
      }
      return MatchingWidget(
        question: question,
        pairs: pairs,
        onPairsChanged: (pairs) => _saveAnswer(question.id, pairs),
      );
    } else if (question is OrderingQuestion) {
      final answer = state.answers[question.id];
      List<String>? orderedItems;
      if (answer is List) {
        orderedItems = List<String>.from(answer);
      } else if (answer is Map && answer['answer'] != null) {
        orderedItems = answer['answer'] is List ? List<String>.from(answer['answer']) : null;
      }
      return OrderingWidget(
        question: question,
        orderedItems: orderedItems,
        onOrderChanged: (order) => _saveAnswer(question.id, order),
      );
    }

    return const Text('نوع سؤال غير مدعوم');
  }

  Widget _buildBottomBar(QuizAttemptActive state, bool isSubmitting) {
    final currentQuestion = state.currentQuestion;
    final hasAnswered = state.answers.containsKey(currentQuestion.id);

    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showNavigationSheet(state),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: Text(
                    'السؤال ${state.currentQuestionIndex + 1} من ${state.attempt.questions.length}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingMD),
          Row(
            children: [
              if (state.canNavigatePrevious)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<QuizAttemptBloc>().add(
                        const NavigateToPreviousQuestion(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                      ),
                    ),
                    child: const Text('السابق'),
                  ),
                ),
              if (state.canNavigatePrevious) SizedBox(width: AppDesignTokens.spacingMD),
              Expanded(
                flex: 2,
                child: state.canNavigateNext
                    ? ElevatedButton(
                        onPressed: () {
                          if (!hasAnswered) {
                            _showAnswerRequiredDialog();
                            return;
                          }
                          context.read<QuizAttemptBloc>().add(
                            const NavigateToNextQuestion(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasAnswered ? AppColors.primary : AppColors.primary.withOpacity(0.6),
                          padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                          ),
                        ),
                        child: Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeBody,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => _showSubmitDialog(state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'إنهاء الاختبار',
                                style: TextStyle(
                                  fontSize: AppDesignTokens.fontSizeBody,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAnswerRequiredDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warningYellow),
            SizedBox(width: AppDesignTokens.spacingSM),
            const Text('تنبيه'),
          ],
        ),
        content: const Text('يرجى اختيار إجابة قبل الانتقال للسؤال التالي'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('حسناً', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveAnswer(int questionId, dynamic answer) {
    context.read<QuizAttemptBloc>().add(
      SaveAnswer(questionId: questionId, answer: answer),
    );
  }

  void _showNavigationSheet(QuizAttemptActive state) {
    final bloc = context.read<QuizAttemptBloc>();
    final currentQuestion = state.currentQuestion;
    final hasAnsweredCurrent = state.answers.containsKey(currentQuestion.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesignTokens.borderRadiusCard)),
      ),
      builder: (dialogContext) => Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuestionNavigation(
              totalQuestions: state.attempt.questions.length,
              currentQuestionIndex: state.currentQuestionIndex,
              answeredQuestions: state.answers.keys.toSet(),
              flaggedQuestions: state.flaggedQuestions,
              onQuestionTap: (index) {
                // Allow navigating to previous questions or current question
                // But require answer to go to next questions
                if (index > state.currentQuestionIndex && !hasAnsweredCurrent) {
                  Navigator.pop(dialogContext);
                  _showAnswerRequiredDialog();
                  return;
                }
                bloc.add(NavigateToQuestion(questionIndex: index));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitDialog(QuizAttemptActive state) {
    final bloc = context.read<QuizAttemptBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إنهاء الاختبار'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أجبت على ${state.answeredCount} من ${state.attempt.questions.length} سؤال',
            ),
            if (state.unansweredCount > 0) ...[
              SizedBox(height: AppDesignTokens.spacingXS),
              Text(
                'هناك ${state.unansweredCount} أسئلة لم تجب عليها',
                style: const TextStyle(color: AppColors.warningYellow),
              ),
            ],
            SizedBox(height: AppDesignTokens.spacingMD),
            const Text('هل تريد إنهاء الاختبار؟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(const SubmitQuiz());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            child: const Text('إنهاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTimeExpiredDialog() {
    final bloc = context.read<QuizAttemptBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('انتهى الوقت'),
        content: const Text(
          'انتهى الوقت المحدد للاختبار. سيتم إرسال إجاباتك تلقائياً.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(const SubmitQuiz(autoSubmit: true));
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    final bloc = context.read<QuizAttemptBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الاختبار'),
        content: const Text('هل تريد إلغاء الاختبار؟ سيتم فقدان جميع إجاباتك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(const AbandonQuiz());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'إلغاء الاختبار',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    _showExitDialog();
    return false;
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppDesignTokens.spacingLG),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppDesignTokens.spacingXXL),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAttemptState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: AppColors.info),
          SizedBox(height: AppDesignTokens.spacingLG),
          const Text('لا توجد محاولة نشطة'),
          SizedBox(height: AppDesignTokens.spacingXXL),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('العودة'),
          ),
        ],
      ),
    );
  }
}
