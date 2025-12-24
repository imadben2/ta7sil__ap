import '../../domain/entities/bac_study_day.dart';
import '../../domain/entities/bac_day_subject.dart';
import 'bac_day_subject_model.dart';

/// Data model for BacStudyDay that extends BacStudyDay entity
class BacStudyDayModel extends BacStudyDay {
  const BacStudyDayModel({
    required super.id,
    required super.dayNumber,
    required super.dayType,
    super.titleAr,
    required super.weekNumber,
    super.subjects = const [],
  });

  /// Create BacStudyDayModel from JSON
  factory BacStudyDayModel.fromJson(Map<String, dynamic> json) {
    // Parse subjects list (from day_subjects relation)
    List<BacDaySubject> subjects = [];
    final daySubjects = json['day_subjects'] ?? json['subjects'];
    if (daySubjects != null) {
      subjects = (daySubjects as List)
          .map((subjectJson) =>
              BacDaySubjectModel.fromJson(subjectJson as Map<String, dynamic>))
          .toList();
    }

    // Safely parse id - handle null, int, or string
    final idValue = json['id'];
    final id = idValue != null
        ? (idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0)
        : 0;

    // Safely parse day_number - handle null, int, or string
    final dayNumberValue = json['day_number'];
    final dayNumber = dayNumberValue != null
        ? (dayNumberValue is int ? dayNumberValue : int.tryParse(dayNumberValue.toString()) ?? 0)
        : 0;

    // Parse week_number safely - handle null, int, or string
    final weekNumberValue = json['week_number'];
    final weekNumber = weekNumberValue != null
        ? (weekNumberValue is int ? weekNumberValue : int.tryParse(weekNumberValue.toString()) ?? 0)
        : 0;

    return BacStudyDayModel(
      id: id,
      dayNumber: dayNumber,
      dayType: json['day_type'] as String? ?? 'study',
      titleAr: json['title_ar'] as String?,
      weekNumber: weekNumber,
      subjects: subjects,
    );
  }

  /// Convert BacStudyDayModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_number': dayNumber,
      'day_type': dayType,
      'title_ar': titleAr,
      'week_number': weekNumber,
      'subjects': subjects
          .map((subject) => BacDaySubjectModel.fromEntity(subject).toJson())
          .toList(),
    };
  }

  /// Create BacStudyDayModel from BacStudyDay entity
  factory BacStudyDayModel.fromEntity(BacStudyDay entity) {
    return BacStudyDayModel(
      id: entity.id,
      dayNumber: entity.dayNumber,
      dayType: entity.dayType,
      titleAr: entity.titleAr,
      weekNumber: entity.weekNumber,
      subjects: entity.subjects,
    );
  }

  /// Create a copy with updated fields
  @override
  BacStudyDayModel copyWith({
    int? id,
    int? dayNumber,
    String? dayType,
    String? titleAr,
    int? weekNumber,
    List<BacDaySubject>? subjects,
  }) {
    return BacStudyDayModel(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      dayType: dayType ?? this.dayType,
      titleAr: titleAr ?? this.titleAr,
      weekNumber: weekNumber ?? this.weekNumber,
      subjects: subjects ?? this.subjects,
    );
  }
}
