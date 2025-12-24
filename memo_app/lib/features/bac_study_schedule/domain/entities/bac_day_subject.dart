import 'package:equatable/equatable.dart';
import 'bac_day_topic.dart';

/// Entity representing a subject within a study day
class BacDaySubject extends Equatable {
  final int id;
  final int subjectId;
  final String subjectNameAr;
  final String? subjectColor;
  final String? subjectIcon;
  final int order;
  final List<BacDayTopic> topics;

  const BacDaySubject({
    required this.id,
    required this.subjectId,
    required this.subjectNameAr,
    this.subjectColor,
    this.subjectIcon,
    required this.order,
    this.topics = const [],
  });

  /// Get count of completed topics
  int get completedTopicsCount => topics.where((t) => t.isCompleted).length;

  /// Get total topics count
  int get totalTopicsCount => topics.length;

  /// Check if all topics are completed
  bool get isFullyCompleted =>
      topics.isNotEmpty && completedTopicsCount == totalTopicsCount;

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage =>
      totalTopicsCount > 0 ? completedTopicsCount / totalTopicsCount : 0.0;

  BacDaySubject copyWith({
    int? id,
    int? subjectId,
    String? subjectNameAr,
    String? subjectColor,
    String? subjectIcon,
    int? order,
    List<BacDayTopic>? topics,
  }) {
    return BacDaySubject(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectNameAr: subjectNameAr ?? this.subjectNameAr,
      subjectColor: subjectColor ?? this.subjectColor,
      subjectIcon: subjectIcon ?? this.subjectIcon,
      order: order ?? this.order,
      topics: topics ?? this.topics,
    );
  }

  @override
  List<Object?> get props => [id, subjectId, subjectNameAr, subjectColor, subjectIcon, order, topics];
}
