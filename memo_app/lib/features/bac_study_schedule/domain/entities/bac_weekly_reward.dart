import 'package:equatable/equatable.dart';

/// Entity representing a weekly movie reward
class BacWeeklyReward extends Equatable {
  final int id;
  final int weekNumber;
  final String titleAr;
  final String? descriptionAr;
  final String? movieTitle;
  final String? movieImage;
  final bool isUnlocked;

  const BacWeeklyReward({
    required this.id,
    required this.weekNumber,
    required this.titleAr,
    this.descriptionAr,
    this.movieTitle,
    this.movieImage,
    this.isUnlocked = false,
  });

  /// Get the day range for this week (e.g., "أيام 1-7")
  String get dayRangeAr {
    final startDay = ((weekNumber - 1) * 7) + 1;
    final endDay = weekNumber * 7;
    return 'أيام $startDay-$endDay';
  }

  BacWeeklyReward copyWith({
    int? id,
    int? weekNumber,
    String? titleAr,
    String? descriptionAr,
    String? movieTitle,
    String? movieImage,
    bool? isUnlocked,
  }) {
    return BacWeeklyReward(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      titleAr: titleAr ?? this.titleAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      movieTitle: movieTitle ?? this.movieTitle,
      movieImage: movieImage ?? this.movieImage,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => [id, weekNumber, titleAr, descriptionAr, movieTitle, movieImage, isUnlocked];
}
