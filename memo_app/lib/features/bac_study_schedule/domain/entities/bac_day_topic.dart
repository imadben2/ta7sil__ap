import 'package:equatable/equatable.dart';

/// Entity representing a single topic/task within a day's subject
class BacDayTopic extends Equatable {
  final int id;
  final String topicAr;
  final String? descriptionAr;
  final String taskType; // study, memorize, solve, review, exercise
  final int order;
  final bool isCompleted;

  const BacDayTopic({
    required this.id,
    required this.topicAr,
    this.descriptionAr,
    required this.taskType,
    required this.order,
    this.isCompleted = false,
  });

  /// Get task type display name in Arabic
  String get taskTypeDisplayAr {
    switch (taskType) {
      case 'study':
        return 'دراسة';
      case 'memorize':
        return 'حفظ';
      case 'solve':
        return 'حل';
      case 'review':
        return 'مراجعة';
      case 'exercise':
        return 'تمرين';
      default:
        return taskType;
    }
  }

  BacDayTopic copyWith({
    int? id,
    String? topicAr,
    String? descriptionAr,
    String? taskType,
    int? order,
    bool? isCompleted,
  }) {
    return BacDayTopic(
      id: id ?? this.id,
      topicAr: topicAr ?? this.topicAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      taskType: taskType ?? this.taskType,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, topicAr, descriptionAr, taskType, order, isCompleted];
}
