import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/study_session_entity.dart';

part 'study_session_model.g.dart';

@JsonSerializable()
class StudySessionModel {
  final int id;
  @JsonKey(name: 'subject_id')
  final int subjectId;
  @JsonKey(name: 'subject_name')
  final String subjectName;
  @JsonKey(name: 'subject_color')
  final String subjectColor;
  final String type; // 'lesson', 'review', 'quiz', 'homework'
  final String status; // 'pending', 'in_progress', 'completed', 'missed'
  @JsonKey(name: 'start_time')
  final String startTime; // ISO 8601
  @JsonKey(name: 'end_time')
  final String endTime; // ISO 8601
  final String? topic;
  final String? notes;

  const StudySessionModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.topic,
    this.notes,
  });

  factory StudySessionModel.fromJson(Map<String, dynamic> json) =>
      _$StudySessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudySessionModelToJson(this);

  StudySessionEntity toEntity() {
    return StudySessionEntity(
      id: id,
      subjectId: subjectId,
      subjectName: subjectName,
      subjectColor: subjectColor,
      type: _parseSessionType(type),
      status: _parseSessionStatus(status),
      startTime: DateTime.parse(startTime),
      endTime: DateTime.parse(endTime),
      topic: topic,
      notes: notes,
    );
  }

  SessionType _parseSessionType(String type) {
    switch (type.toLowerCase()) {
      case 'lesson':
        return SessionType.lesson;
      case 'review':
        return SessionType.review;
      case 'quiz':
        return SessionType.quiz;
      case 'homework':
        return SessionType.homework;
      default:
        return SessionType.lesson;
    }
  }

  SessionStatus _parseSessionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return SessionStatus.pending;
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'missed':
        return SessionStatus.missed;
      default:
        return SessionStatus.pending;
    }
  }
}
