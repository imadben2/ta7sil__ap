import '../../domain/entities/bac_day_topic.dart';

/// Data model for BacDayTopic that extends BacDayTopic entity
class BacDayTopicModel extends BacDayTopic {
  const BacDayTopicModel({
    required super.id,
    required super.topicAr,
    super.descriptionAr,
    required super.taskType,
    required super.order,
    super.isCompleted = false,
  });

  /// Create BacDayTopicModel from JSON
  factory BacDayTopicModel.fromJson(Map<String, dynamic> json) {
    // Safely parse id - handle null, int, or string
    final idValue = json['id'];
    final id = idValue != null
        ? (idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0)
        : 0;

    // Safely parse order - handle null, int, or string
    final orderValue = json['order'];
    final order = orderValue != null
        ? (orderValue is int ? orderValue : int.tryParse(orderValue.toString()) ?? 0)
        : 0;

    return BacDayTopicModel(
      id: id,
      topicAr: json['topic_ar'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      taskType: json['task_type'] as String? ?? 'study',
      order: order,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  /// Convert BacDayTopicModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_ar': topicAr,
      'description_ar': descriptionAr,
      'task_type': taskType,
      'order': order,
      'is_completed': isCompleted,
    };
  }

  /// Create BacDayTopicModel from BacDayTopic entity
  factory BacDayTopicModel.fromEntity(BacDayTopic entity) {
    return BacDayTopicModel(
      id: entity.id,
      topicAr: entity.topicAr,
      descriptionAr: entity.descriptionAr,
      taskType: entity.taskType,
      order: entity.order,
      isCompleted: entity.isCompleted,
    );
  }

  /// Create a copy with updated fields
  @override
  BacDayTopicModel copyWith({
    int? id,
    String? topicAr,
    String? descriptionAr,
    String? taskType,
    int? order,
    bool? isCompleted,
  }) {
    return BacDayTopicModel(
      id: id ?? this.id,
      topicAr: topicAr ?? this.topicAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      taskType: taskType ?? this.taskType,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
