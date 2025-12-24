import 'package:equatable/equatable.dart';
import 'subject.dart';
import 'exam.dart';

/// Priority level enum for subjects and sessions
enum PriorityLevel {
  critical, // Extremely urgent - exam very soon or very weak subject
  high, // Important - needs significant attention
  medium, // Moderate priority - regular study needed
  low, // Low priority - comfortable with current performance
}

/// Helper class for priority calculation
class PrioritizedSubject extends Equatable {
  final Subject subject;
  final double priorityScore;
  final Exam? upcomingExam;
  final Map<String, double> scoreBreakdown;

  const PrioritizedSubject({
    required this.subject,
    required this.priorityScore,
    this.upcomingExam,
    required this.scoreBreakdown,
  });

  @override
  List<Object?> get props => [subject.id, priorityScore];
}
