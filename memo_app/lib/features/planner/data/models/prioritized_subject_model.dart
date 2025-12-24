import '../../domain/entities/prioritized_subject.dart';
import 'subject_model.dart';
import 'exam_model.dart';

/// Data model for PrioritizedSubject with JSON serialization
/// Used by the priority algorithm to rank subjects
class PrioritizedSubjectModel {
  final SubjectModel subject;
  final double priorityScore;
  final ExamModel? upcomingExam;
  final Map<String, double> scoreBreakdown;

  PrioritizedSubjectModel({
    required this.subject,
    required this.priorityScore,
    this.upcomingExam,
    required this.scoreBreakdown,
  });

  factory PrioritizedSubjectModel.fromJson(Map<String, dynamic> json) {
    return PrioritizedSubjectModel(
      subject: SubjectModel.fromJson(json['subject'] as Map<String, dynamic>),
      priorityScore: (json['priority_score'] as num).toDouble(),
      upcomingExam: json['upcoming_exam'] != null
          ? ExamModel.fromJson(json['upcoming_exam'] as Map<String, dynamic>)
          : null,
      scoreBreakdown: (json['score_breakdown'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject.toJson(),
      'priority_score': priorityScore,
      'upcoming_exam': upcomingExam?.toJson(),
      'score_breakdown': scoreBreakdown,
    };
  }

  PrioritizedSubject toEntity() {
    return PrioritizedSubject(
      subject: subject.toEntity(),
      priorityScore: priorityScore,
      upcomingExam: upcomingExam?.toEntity(),
      scoreBreakdown: scoreBreakdown,
    );
  }

  factory PrioritizedSubjectModel.fromEntity(PrioritizedSubject entity) {
    return PrioritizedSubjectModel(
      subject: SubjectModel.fromEntity(entity.subject),
      priorityScore: entity.priorityScore,
      upcomingExam: entity.upcomingExam != null
          ? ExamModel.fromEntity(entity.upcomingExam!)
          : null,
      scoreBreakdown: entity.scoreBreakdown,
    );
  }

  /// Create from subject with calculated priority
  factory PrioritizedSubjectModel.calculate({
    required SubjectModel subject,
    required Map<String, int> weights,
    ExamModel? upcomingExam,
  }) {
    // Extract weights
    final coefficientWeight = weights['coefficient'] ?? 40;
    final examProximityWeight = weights['examProximity'] ?? 25;
    final difficultyWeight = weights['difficulty'] ?? 15;
    final inactivityWeight = weights['inactivity'] ?? 10;
    final performanceGapWeight = weights['performanceGap'] ?? 10;

    // Calculate individual scores (0-10 scale)
    final coefficientScore = (subject.coefficient / 7.0 * 10)
        .clamp(0, 10)
        .toDouble();
    final difficultyScore = (subject.difficultyLevel / 10.0 * 10)
        .clamp(0, 10)
        .toDouble();

    double examProximityScore = 0;
    if (upcomingExam != null) {
      final urgency = upcomingExam.urgencyScore;
      examProximityScore = (urgency / 10.0).clamp(0, 10).toDouble();
    }

    final daysSinceStudy = subject.daysSinceLastStudy ?? 30;
    final inactivityScore = (daysSinceStudy / 30.0 * 10)
        .clamp(0, 10)
        .toDouble();

    final performanceGap = subject.performanceGap;
    final performanceGapScore = (performanceGap * 10).clamp(0, 10).toDouble();

    // Calculate weighted total (normalized to 0-100)
    final totalWeight =
        coefficientWeight +
        examProximityWeight +
        difficultyWeight +
        inactivityWeight +
        performanceGapWeight;

    final weightedScore =
        (coefficientScore * coefficientWeight +
            examProximityScore * examProximityWeight +
            difficultyScore * difficultyWeight +
            inactivityScore * inactivityWeight +
            performanceGapScore * performanceGapWeight) /
        totalWeight *
        10;

    final scoreBreakdown = <String, double>{
      'coefficient': coefficientScore,
      'examProximity': examProximityScore,
      'difficulty': difficultyScore,
      'inactivity': inactivityScore,
      'performanceGap': performanceGapScore,
    };

    return PrioritizedSubjectModel(
      subject: subject,
      priorityScore: weightedScore.clamp(0, 100),
      upcomingExam: upcomingExam,
      scoreBreakdown: scoreBreakdown,
    );
  }

  /// Get human-readable priority level
  String get priorityLevel {
    if (priorityScore >= 80) return 'critical';
    if (priorityScore >= 60) return 'high';
    if (priorityScore >= 40) return 'medium';
    return 'low';
  }

  /// Get color for priority level
  String get priorityColor {
    if (priorityScore >= 80) return '#E53E3E'; // red
    if (priorityScore >= 60) return '#DD6B20'; // orange
    if (priorityScore >= 40) return '#D69E2E'; // yellow
    return '#38A169'; // green
  }
}
