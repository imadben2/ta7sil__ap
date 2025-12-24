import '../../domain/entities/bac_user_stats.dart';

/// Data model for BacUserStats that extends BacUserStats entity
class BacUserStatsModel extends BacUserStats {
  const BacUserStatsModel({
    required super.totalDays,
    required super.completedDays,
    required super.totalTopics,
    required super.completedTopics,
    required super.progressPercentage,
    required super.currentDay,
  });

  /// Create BacUserStatsModel from JSON
  factory BacUserStatsModel.fromJson(Map<String, dynamic> json) {
    return BacUserStatsModel(
      totalDays: json['total_days'] as int? ?? 98,
      completedDays: json['completed_days'] as int? ?? 0,
      totalTopics: json['total_topics'] as int? ?? 0,
      completedTopics: json['completed_topics'] as int? ?? 0,
      progressPercentage: _parseDouble(json['progress_percentage']) ?? 0.0,
      currentDay: json['current_day'] as int? ?? 1,
    );
  }

  /// Convert BacUserStatsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'completed_days': completedDays,
      'total_topics': totalTopics,
      'completed_topics': completedTopics,
      'progress_percentage': progressPercentage,
      'current_day': currentDay,
    };
  }

  /// Create BacUserStatsModel from BacUserStats entity
  factory BacUserStatsModel.fromEntity(BacUserStats entity) {
    return BacUserStatsModel(
      totalDays: entity.totalDays,
      completedDays: entity.completedDays,
      totalTopics: entity.totalTopics,
      completedTopics: entity.completedTopics,
      progressPercentage: entity.progressPercentage,
      currentDay: entity.currentDay,
    );
  }

  /// Create an empty stats model
  const BacUserStatsModel.empty()
      : super(
          totalDays: 98,
          completedDays: 0,
          totalTopics: 0,
          completedTopics: 0,
          progressPercentage: 0.0,
          currentDay: 1,
        );

  /// Create a copy with updated fields
  @override
  BacUserStatsModel copyWith({
    int? totalDays,
    int? completedDays,
    int? totalTopics,
    int? completedTopics,
    double? progressPercentage,
    int? currentDay,
  }) {
    return BacUserStatsModel(
      totalDays: totalDays ?? this.totalDays,
      completedDays: completedDays ?? this.completedDays,
      totalTopics: totalTopics ?? this.totalTopics,
      completedTopics: completedTopics ?? this.completedTopics,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentDay: currentDay ?? this.currentDay,
    );
  }

  /// Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
