import '../../domain/entities/bac_weekly_reward.dart';

/// Data model for BacWeeklyReward that extends BacWeeklyReward entity
class BacWeeklyRewardModel extends BacWeeklyReward {
  const BacWeeklyRewardModel({
    required super.id,
    required super.weekNumber,
    required super.titleAr,
    super.descriptionAr,
    super.movieTitle,
    super.movieImage,
    super.isUnlocked = false,
  });

  /// Create BacWeeklyRewardModel from JSON
  factory BacWeeklyRewardModel.fromJson(Map<String, dynamic> json) {
    // Safely parse id - handle null, int, or string
    final idValue = json['id'];
    final id = idValue != null
        ? (idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0)
        : 0;

    // Safely parse week_number - handle null, int, or string
    final weekNumberValue = json['week_number'];
    final weekNumber = weekNumberValue != null
        ? (weekNumberValue is int ? weekNumberValue : int.tryParse(weekNumberValue.toString()) ?? 0)
        : 0;

    return BacWeeklyRewardModel(
      id: id,
      weekNumber: weekNumber,
      titleAr: json['title_ar'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      movieTitle: json['movie_title'] as String?,
      movieImage: json['movie_image'] as String?,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
    );
  }

  /// Convert BacWeeklyRewardModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_number': weekNumber,
      'title_ar': titleAr,
      'description_ar': descriptionAr,
      'movie_title': movieTitle,
      'movie_image': movieImage,
      'is_unlocked': isUnlocked,
    };
  }

  /// Create BacWeeklyRewardModel from BacWeeklyReward entity
  factory BacWeeklyRewardModel.fromEntity(BacWeeklyReward entity) {
    return BacWeeklyRewardModel(
      id: entity.id,
      weekNumber: entity.weekNumber,
      titleAr: entity.titleAr,
      descriptionAr: entity.descriptionAr,
      movieTitle: entity.movieTitle,
      movieImage: entity.movieImage,
      isUnlocked: entity.isUnlocked,
    );
  }

  /// Create a copy with updated fields
  @override
  BacWeeklyRewardModel copyWith({
    int? id,
    int? weekNumber,
    String? titleAr,
    String? descriptionAr,
    String? movieTitle,
    String? movieImage,
    bool? isUnlocked,
  }) {
    return BacWeeklyRewardModel(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      titleAr: titleAr ?? this.titleAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      movieTitle: movieTitle ?? this.movieTitle,
      movieImage: movieImage ?? this.movieImage,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
