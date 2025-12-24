import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/quiz_results/quiz_results_bloc.dart';
import '../bloc/quiz_results/quiz_results_event.dart';
import '../bloc/quiz_results/quiz_results_state.dart';
import '../widgets/question_header.dart';
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

/// Quiz review page - answer review with explanations
class QuizReviewPage extends StatefulWidget {
  final int attemptId;

  const QuizReviewPage({super.key, required this.attemptId});

  @override
  State<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends State<QuizReviewPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<QuizResultsBloc>().add(
      LoadQuizReview(attemptId: widget.attemptId),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<QuizResultsBloc, QuizResultsState>(
          builder: (context, state) {
            if (state is QuizResultsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuizResultsError) {
              return _buildErrorState(state.message);
            }

            if (state is QuizReviewLoaded) {
              return _buildReview(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReview(QuizReviewLoaded state) {
    final result = state.result;
    final questions = result.questionResults;

    return Column(
      children: [
        _buildAppBar(questions.length),
        _buildProgress(questions.length),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final questionFeedback = questions[index];
              return _buildQuestionReview(questionFeedback, index, questions.length);
            },
          ),
        ),
        _buildBottomBar(questions.length),
      ],
    );
  }

  Widget _buildAppBar(int totalQuestions) {
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
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(width: AppDesignTokens.spacingMD),
          Expanded(
            child: Text(
              'مراجعة السؤال ${_currentIndex + 1} من $totalQuestions',
              style: TextStyle(fontSize: AppDesignTokens.fontSizeH5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(int totalQuestions) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXL, vertical: AppDesignTokens.spacingMD),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        child: LinearProgressIndicator(
          value: (_currentIndex + 1) / totalQuestions,
          backgroundColor: AppColors.divider,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 8,
        ),
      ),
    );
  }

  Widget _buildQuestionReview(questionFeedback, int index, int totalQuestions) {
    final question = questionFeedback.question;
    final userAnswer = questionFeedback.userAnswer;
    final correctAnswer = questionFeedback.correctAnswer;
    final isCorrect = questionFeedback.isCorrect;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultBadge(
            isCorrect,
            questionFeedback.pointsEarned,
            question.points,
          ),
          SizedBox(height: AppDesignTokens.spacingXL),
          QuestionHeader(
            question: question,
            questionNumber: index + 1,
            totalQuestions: totalQuestions,
            isFlagged: false,
            onToggleFlag: () {},
          ),
          SizedBox(height: AppDesignTokens.spacingXXL),
          _buildQuestionWidget(question, userAnswer, correctAnswer, isCorrect),
          if (question.explanationAr?.isNotEmpty ?? false) ...[
            SizedBox(height: AppDesignTokens.spacingXXL),
            _buildExplanation(question.explanationAr!),
          ],
        ],
      ),
    );
  }

  Widget _buildResultBadge(
    bool isCorrect,
    double pointsEarned,
    double totalPoints,
  ) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingLG),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.successGreen.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        border: Border.all(
          color: isCorrect ? AppColors.successGreen : AppColors.error,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? AppColors.successGreen : AppColors.error,
            size: 32,
          ),
          SizedBox(width: AppDesignTokens.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'إجابة صحيحة' : 'إجابة خاطئة',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSizeBody,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? AppColors.successGreen : AppColors.error,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingXXS),
                Text(
                  'حصلت على ${pointsEarned.toStringAsFixed(1)} من ${totalPoints.toStringAsFixed(1)} نقطة',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSizeCaption,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(
    question,
    userAnswer,
    correctAnswer,
    bool isCorrect,
  ) {
    if (question is SingleChoiceQuestion) {
      // Handle userAnswer - can be int or Map with 'answer' key
      int? selectedAnswer;
      if (userAnswer is int) {
        selectedAnswer = userAnswer;
      } else if (userAnswer is Map && userAnswer['answer'] != null) {
        selectedAnswer = userAnswer['answer'] as int?;
      }

      // Handle correctAnswer - can be int, Map with 'answer' key, or List of indices
      int? correctAnswerInt;
      if (correctAnswer is int) {
        correctAnswerInt = correctAnswer;
      } else if (correctAnswer is Map && correctAnswer['answer'] != null) {
        final val = correctAnswer['answer'];
        correctAnswerInt = val is int ? val : int.tryParse(val.toString());
      } else if (correctAnswer is List && correctAnswer.isNotEmpty) {
        // Array format: [0] or [0, 2] - take first element for single choice
        final first = correctAnswer[0];
        correctAnswerInt = first is int ? first : int.tryParse(first.toString());
      }

      // Debug: Print values to diagnose review mode issue
      debugPrint('Quiz Review - SingleChoice: userAnswer=$userAnswer (type: ${userAnswer.runtimeType}), '
          'correctAnswer=$correctAnswer (type: ${correctAnswer.runtimeType}), '
          'selectedAnswer=$selectedAnswer, correctAnswerInt=$correctAnswerInt, isCorrect=$isCorrect');

      return SingleChoiceWidget(
        question: question,
        selectedAnswer: selectedAnswer,
        onAnswerSelected: (_) {},
        isReviewMode: true,
        correctAnswer: correctAnswerInt,
      );
    } else if (question is MultipleChoiceQuestion) {
      // Handle userAnswer - can be List or Map with 'answers' key
      List<int>? selectedAnswers;
      if (userAnswer is List) {
        selectedAnswers = List<int>.from(userAnswer.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0));
      } else if (userAnswer is Map && userAnswer['answers'] != null) {
        selectedAnswers = List<int>.from((userAnswer['answers'] as List).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0));
      }

      // Handle correctAnswer - can be List or Map with 'answers' key
      List<int>? correctAnswers;
      if (correctAnswer is List) {
        correctAnswers = List<int>.from(correctAnswer.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0));
      } else if (correctAnswer is Map && correctAnswer['answers'] != null) {
        correctAnswers = List<int>.from((correctAnswer['answers'] as List).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0));
      }

      return MultipleChoiceWidget(
        question: question,
        selectedAnswers: selectedAnswers,
        onAnswersSelected: (_) {},
        isReviewMode: true,
        correctAnswers: correctAnswers,
      );
    } else if (question is TrueFalseQuestion) {
      // Handle userAnswer - can be bool, Map with 'answer' key, or null
      bool? selectedAnswer;
      if (userAnswer is bool) {
        selectedAnswer = userAnswer;
      } else if (userAnswer is Map && userAnswer['answer'] != null) {
        final val = userAnswer['answer'];
        if (val is bool) {
          selectedAnswer = val;
        } else if (val is String) {
          selectedAnswer = val.toLowerCase() == 'true';
        }
      }

      // Handle correctAnswer - can be bool, Map with 'answer' key, or null
      bool? correctAnswerBool;
      if (correctAnswer is bool) {
        correctAnswerBool = correctAnswer;
      } else if (correctAnswer is Map && correctAnswer['answer'] != null) {
        final val = correctAnswer['answer'];
        if (val is bool) {
          correctAnswerBool = val;
        } else if (val is String) {
          correctAnswerBool = val.toLowerCase() == 'true';
        }
      }

      return TrueFalseWidget(
        question: question,
        selectedAnswer: selectedAnswer,
        onAnswerSelected: (_) {},
        isReviewMode: true,
        correctAnswer: correctAnswerBool,
      );
    } else if (question is FillBlankQuestion) {
      // Handle userAnswer - can be List or single value
      List<String>? answers;
      if (userAnswer is List) {
        answers = userAnswer.map((e) => e.toString()).toList();
      } else if (userAnswer != null) {
        answers = [userAnswer.toString()];
      }

      // Handle correctAnswer - array of arrays for fill_blank
      List<String>? correctAnswers;
      if (correctAnswer is List && correctAnswer.isNotEmpty) {
        // Get first answer from each blank's accepted answers
        correctAnswers = correctAnswer.map((e) {
          if (e is List && e.isNotEmpty) {
            return e.first.toString();
          }
          return e.toString();
        }).toList();
      }

      return FillBlankWidget(
        question: question,
        answers: answers,
        onAnswersChanged: (_) {},
        isReviewMode: true,
        correctAnswers: correctAnswers,
      );
    } else if (question is ShortAnswerQuestion) {
      // Handle userAnswer - can be String or Map
      String? answerStr;
      if (userAnswer is String) {
        answerStr = userAnswer;
      } else if (userAnswer is Map && userAnswer['answer'] != null) {
        answerStr = userAnswer['answer'].toString();
      }

      // Handle correctAnswer - can have 'model_answer' or 'answer' key
      String? correctStr;
      if (correctAnswer is String) {
        correctStr = correctAnswer;
      } else if (correctAnswer is Map) {
        correctStr = (correctAnswer['model_answer'] ?? correctAnswer['answer'])?.toString();
      }

      return ShortAnswerWidget(
        question: question,
        answer: answerStr,
        onAnswerChanged: (_) {},
        isReviewMode: true,
        correctAnswer: correctStr,
        isCorrect: isCorrect,
      );
    } else if (question is NumericQuestion) {
      // Handle userAnswer - can be num, String, or Map
      double? answerDouble;
      if (userAnswer is num) {
        answerDouble = userAnswer.toDouble();
      } else if (userAnswer is String) {
        answerDouble = double.tryParse(userAnswer);
      } else if (userAnswer is Map && userAnswer['answer'] != null) {
        final val = userAnswer['answer'];
        if (val is num) {
          answerDouble = val.toDouble();
        } else if (val is String) {
          answerDouble = double.tryParse(val);
        }
      }

      // Handle correctAnswer - can have 'answer' key
      double? correctDouble;
      if (correctAnswer is num) {
        correctDouble = correctAnswer.toDouble();
      } else if (correctAnswer is String) {
        correctDouble = double.tryParse(correctAnswer);
      } else if (correctAnswer is Map && correctAnswer['answer'] != null) {
        final val = correctAnswer['answer'];
        if (val is num) {
          correctDouble = val.toDouble();
        } else if (val is String) {
          correctDouble = double.tryParse(val);
        }
      }

      return NumericWidget(
        question: question,
        answer: answerDouble,
        onAnswerChanged: (_) {},
        isReviewMode: true,
        correctAnswer: correctDouble,
      );
    } else if (question is MatchingQuestion) {
      // Handle userAnswer - can be Map or List of pairs
      Map<String, String>? pairs;
      if (userAnswer is Map) {
        pairs = Map<String, String>.from(
          userAnswer.map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      } else if (userAnswer is List) {
        pairs = {};
        for (var pair in userAnswer) {
          if (pair is Map && pair['left'] != null && pair['right'] != null) {
            pairs[pair['left'].toString()] = pair['right'].toString();
          }
        }
      }

      // Handle correctAnswer - can have 'pairs' key
      Map<String, String>? correctPairs;
      if (correctAnswer is Map && correctAnswer['pairs'] != null) {
        correctPairs = {};
        for (var pair in correctAnswer['pairs']) {
          if (pair is Map && pair['left'] != null && pair['right'] != null) {
            correctPairs[pair['left'].toString()] = pair['right'].toString();
          }
        }
      } else if (correctAnswer is List) {
        correctPairs = {};
        for (var pair in correctAnswer) {
          if (pair is Map && pair['left'] != null && pair['right'] != null) {
            correctPairs[pair['left'].toString()] = pair['right'].toString();
          }
        }
      }

      return MatchingWidget(
        question: question,
        pairs: pairs,
        onPairsChanged: (_) {},
        isReviewMode: true,
        correctPairs: correctPairs,
      );
    } else if (question is OrderingQuestion) {
      // Handle userAnswer - can be List
      List<String>? orderedItems;
      if (userAnswer is List) {
        orderedItems = userAnswer.map((e) => e.toString()).toList();
      }

      // Handle correctAnswer - can have 'order' key
      List<String>? correctOrder;
      if (correctAnswer is List) {
        correctOrder = correctAnswer.map((e) => e.toString()).toList();
      } else if (correctAnswer is Map && correctAnswer['order'] != null) {
        correctOrder = List<String>.from(
          (correctAnswer['order'] as List).map((e) => e.toString()),
        );
      }

      return OrderingWidget(
        question: question,
        orderedItems: orderedItems,
        onOrderChanged: (_) {},
        isReviewMode: true,
        correctOrder: correctOrder,
      );
    }

    return const Text('نوع سؤال غير مدعوم');
  }

  Widget _buildExplanation(String explanation) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 20),
              SizedBox(width: AppDesignTokens.spacingMD),
              Text(
                'الشرح',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeBody,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingMD),
          Text(
            explanation,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeBody,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int totalQuestions) {
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
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
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
          if (_currentIndex > 0) SizedBox(width: AppDesignTokens.spacingMD),
          Expanded(
            flex: 2,
            child: _currentIndex < totalQuestions - 1
                ? ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingLG),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                      ),
                    ),
                    child: Text(
                      'إنهاء المراجعة',
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
    );
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
              onPressed: () {
                context.read<QuizResultsBloc>().add(
                  LoadQuizReview(attemptId: widget.attemptId),
                );
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
