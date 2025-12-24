import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for triggering schedule adaptation
class TriggerAdaptation implements UseCase<AdaptationResult, NoParams> {
  final PlannerRepository repository;

  TriggerAdaptation(this.repository);

  @override
  Future<Either<Failure, AdaptationResult>> call(NoParams params) async {
    return await repository.triggerAdaptation();
  }
}

/// Result of a schedule adaptation
class AdaptationResult extends Equatable {
  /// Message describing what was done
  final String message;

  /// List of adaptations that were made
  final List<AdaptationChange> adaptations;

  /// Whether adaptation was successful
  final bool success;

  /// Number of sessions affected
  final int sessionsAffected;

  const AdaptationResult({
    required this.message,
    required this.adaptations,
    required this.success,
    this.sessionsAffected = 0,
  });

  @override
  List<Object?> get props => [message, adaptations, success, sessionsAffected];
}

/// A single adaptation change
class AdaptationChange extends Equatable {
  /// Type of change (e.g., 'rescheduled', 'duration_changed', 'priority_adjusted')
  final String type;

  /// Description of the change
  final String description;

  /// Arabic description
  final String descriptionAr;

  /// Subject name affected (if applicable)
  final String? subjectName;

  /// Session ID affected (if applicable)
  final String? sessionId;

  /// Old value (if applicable)
  final String? oldValue;

  /// New value (if applicable)
  final String? newValue;

  const AdaptationChange({
    required this.type,
    required this.description,
    required this.descriptionAr,
    this.subjectName,
    this.sessionId,
    this.oldValue,
    this.newValue,
  });

  @override
  List<Object?> get props => [
    type,
    description,
    descriptionAr,
    subjectName,
    sessionId,
    oldValue,
    newValue,
  ];
}

/// Model for parsing adaptation result from JSON
class AdaptationResultModel extends AdaptationResult {
  const AdaptationResultModel({
    required super.message,
    required super.adaptations,
    required super.success,
    super.sessionsAffected,
  });

  factory AdaptationResultModel.fromJson(Map<String, dynamic> json) {
    return AdaptationResultModel(
      message: json['message'] as String? ?? 'Adaptation completed',
      adaptations: (json['adaptations'] as List<dynamic>?)
          ?.map((item) => AdaptationChangeModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      success: json['success'] as bool? ?? true,
      sessionsAffected: json['sessions_affected'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'adaptations': adaptations
          .map((a) => AdaptationChangeModel.fromEntity(a).toJson())
          .toList(),
      'success': success,
      'sessions_affected': sessionsAffected,
    };
  }

  AdaptationResult toEntity() => this;
}

/// Model for parsing adaptation change from JSON
class AdaptationChangeModel extends AdaptationChange {
  const AdaptationChangeModel({
    required super.type,
    required super.description,
    required super.descriptionAr,
    super.subjectName,
    super.sessionId,
    super.oldValue,
    super.newValue,
  });

  factory AdaptationChangeModel.fromJson(Map<String, dynamic> json) {
    return AdaptationChangeModel(
      type: json['type'] as String,
      description: json['description'] as String,
      descriptionAr: json['description_ar'] as String? ?? json['description'] as String,
      subjectName: json['subject_name'] as String?,
      sessionId: json['session_id'] as String?,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
    );
  }

  factory AdaptationChangeModel.fromEntity(AdaptationChange entity) {
    return AdaptationChangeModel(
      type: entity.type,
      description: entity.description,
      descriptionAr: entity.descriptionAr,
      subjectName: entity.subjectName,
      sessionId: entity.sessionId,
      oldValue: entity.oldValue,
      newValue: entity.newValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'description_ar': descriptionAr,
      if (subjectName != null) 'subject_name': subjectName,
      if (sessionId != null) 'session_id': sessionId,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
    };
  }

  AdaptationChange toEntity() => this;
}
