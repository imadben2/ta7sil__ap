import '../../domain/entities/bac_day_subject.dart';
import '../../domain/entities/bac_day_topic.dart';
import 'bac_day_topic_model.dart';

/// Data model for BacDaySubject that extends BacDaySubject entity
class BacDaySubjectModel extends BacDaySubject {
  const BacDaySubjectModel({
    required super.id,
    required super.subjectId,
    required super.subjectNameAr,
    super.subjectColor,
    super.subjectIcon,
    required super.order,
    super.topics = const [],
  });

  /// Create BacDaySubjectModel from JSON
  factory BacDaySubjectModel.fromJson(Map<String, dynamic> json) {
    // Parse topics list
    List<BacDayTopic> topics = [];
    if (json['topics'] != null) {
      topics = (json['topics'] as List)
          .map((topicJson) =>
              BacDayTopicModel.fromJson(topicJson as Map<String, dynamic>))
          .toList();
    }

    // Handle nested subject object from API
    final subject = json['subject'] as Map<String, dynamic>?;

    // Safely parse id - handle null, int, or string
    final idValue = json['id'];
    final id = idValue != null
        ? (idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0)
        : 0;

    // Safely parse subject_id from nested subject or direct field
    final subjectIdValue = subject?['id'] ?? json['subject_id'];
    final subjectId = subjectIdValue != null
        ? (subjectIdValue is int ? subjectIdValue : int.tryParse(subjectIdValue.toString()) ?? 0)
        : 0;

    // Safely parse order - handle null, int, or string
    final orderValue = json['order'];
    final order = orderValue != null
        ? (orderValue is int ? orderValue : int.tryParse(orderValue.toString()) ?? 0)
        : 0;

    return BacDaySubjectModel(
      id: id,
      subjectId: subjectId,
      subjectNameAr:
          subject?['name_ar'] as String? ?? json['subject_name_ar'] as String? ?? '',
      subjectColor: subject?['color'] as String? ?? json['subject_color'] as String?,
      subjectIcon: subject?['icon'] as String? ?? json['subject_icon'] as String?,
      order: order,
      topics: topics,
    );
  }

  /// Convert BacDaySubjectModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'subject_name_ar': subjectNameAr,
      'subject_color': subjectColor,
      'subject_icon': subjectIcon,
      'order': order,
      'topics': topics
          .map((topic) => BacDayTopicModel.fromEntity(topic).toJson())
          .toList(),
    };
  }

  /// Create BacDaySubjectModel from BacDaySubject entity
  factory BacDaySubjectModel.fromEntity(BacDaySubject entity) {
    return BacDaySubjectModel(
      id: entity.id,
      subjectId: entity.subjectId,
      subjectNameAr: entity.subjectNameAr,
      subjectColor: entity.subjectColor,
      subjectIcon: entity.subjectIcon,
      order: entity.order,
      topics: entity.topics,
    );
  }

  /// Create a copy with updated fields
  @override
  BacDaySubjectModel copyWith({
    int? id,
    int? subjectId,
    String? subjectNameAr,
    String? subjectColor,
    String? subjectIcon,
    int? order,
    List<BacDayTopic>? topics,
  }) {
    return BacDaySubjectModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectNameAr: subjectNameAr ?? this.subjectNameAr,
      subjectColor: subjectColor ?? this.subjectColor,
      subjectIcon: subjectIcon ?? this.subjectIcon,
      order: order ?? this.order,
      topics: topics ?? this.topics,
    );
  }
}
