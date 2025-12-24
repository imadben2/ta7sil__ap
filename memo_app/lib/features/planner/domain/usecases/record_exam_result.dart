import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/exam.dart';
import '../repositories/planner_repository.dart';

/// Response from recording exam result
class ExamResultResponse {
  final Exam exam;
  final bool adaptationTriggered;
  final String? message;

  const ExamResultResponse({
    required this.exam,
    this.adaptationTriggered = false,
    this.message,
  });
}

/// Use case for recording exam results
class RecordExamResult implements UseCase<ExamResultResponse, ExamResultParams> {
  final PlannerRepository repository;

  RecordExamResult(this.repository);

  @override
  Future<Either<Failure, ExamResultResponse>> call(ExamResultParams params) async {
    return await repository.recordExamResult(
      examId: params.examId,
      score: params.score,
      maxScore: params.maxScore,
      notes: params.notes,
    );
  }
}

/// Parameters for recording exam result
class ExamResultParams {
  final String examId;
  final double score;
  final double maxScore;
  final String? notes;

  const ExamResultParams({
    required this.examId,
    required this.score,
    required this.maxScore,
    this.notes,
  });

  /// Calculate percentage score
  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  /// Calculate grade based on Algerian grading system
  String get grade {
    final pct = percentage;
    if (pct >= 16) return 'Excellent';
    if (pct >= 14) return 'Very Good';
    if (pct >= 12) return 'Good';
    if (pct >= 10) return 'Pass';
    return 'Fail';
  }

  /// Calculate grade in Arabic
  String get gradeAr {
    final pct = percentage;
    if (pct >= 16) return 'ممتاز';
    if (pct >= 14) return 'جيد جداً';
    if (pct >= 12) return 'جيد';
    if (pct >= 10) return 'مقبول';
    return 'راسب';
  }
}
