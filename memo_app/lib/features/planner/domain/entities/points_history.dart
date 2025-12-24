import 'package:equatable/equatable.dart';

/// Points History Entity for the planner gamification system
class PointsHistory extends Equatable {
  /// List of daily points records
  final List<DailyPoints> dailyPoints;

  /// Total points earned across all time
  final int totalPoints;

  /// Period in days for the history
  final int periodDays;

  const PointsHistory({
    required this.dailyPoints,
    required this.totalPoints,
    required this.periodDays,
  });

  /// Get total points earned in the period
  int get periodPoints =>
      dailyPoints.fold(0, (sum, dp) => sum + dp.totalPoints);

  /// Get total sessions in the period
  int get periodSessions =>
      dailyPoints.fold(0, (sum, dp) => sum + dp.sessionsCount);

  /// Get average points per day in the period
  double get averagePointsPerDay =>
      dailyPoints.isNotEmpty ? periodPoints / dailyPoints.length : 0;

  /// Get current level based on total points
  int get currentLevel => _calculateLevel(totalPoints);

  /// Get points needed for next level
  int get pointsToNextLevel {
    final nextLevel = currentLevel + 1;
    final pointsForNextLevel = _pointsForLevel(nextLevel);
    return pointsForNextLevel - totalPoints;
  }

  /// Get progress percentage towards next level (0-100)
  double get levelProgress {
    final currentLevelPoints = _pointsForLevel(currentLevel);
    final nextLevelPoints = _pointsForLevel(currentLevel + 1);
    final pointsInLevel = totalPoints - currentLevelPoints;
    final pointsNeeded = nextLevelPoints - currentLevelPoints;
    return pointsNeeded > 0 ? (pointsInLevel / pointsNeeded) * 100 : 100;
  }

  static int _calculateLevel(int points) {
    // Level thresholds: 0, 100, 250, 500, 1000, 2000, 4000, 8000, etc.
    if (points < 100) return 1;
    if (points < 250) return 2;
    if (points < 500) return 3;
    if (points < 1000) return 4;
    if (points < 2000) return 5;
    if (points < 4000) return 6;
    if (points < 8000) return 7;
    if (points < 16000) return 8;
    if (points < 32000) return 9;
    return 10;
  }

  static int _pointsForLevel(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 100;
      case 3: return 250;
      case 4: return 500;
      case 5: return 1000;
      case 6: return 2000;
      case 7: return 4000;
      case 8: return 8000;
      case 9: return 16000;
      case 10: return 32000;
      default: return 32000;
    }
  }

  @override
  List<Object?> get props => [dailyPoints, totalPoints, periodDays];
}

/// Daily Points record
class DailyPoints extends Equatable {
  /// Date of the record
  final DateTime date;

  /// Total points earned on this day
  final int totalPoints;

  /// Number of sessions completed on this day
  final int sessionsCount;

  const DailyPoints({
    required this.date,
    required this.totalPoints,
    required this.sessionsCount,
  });

  /// Get average points per session
  double get averagePointsPerSession =>
      sessionsCount > 0 ? totalPoints / sessionsCount : 0;

  @override
  List<Object?> get props => [date, totalPoints, sessionsCount];
}

/// Points transaction for detailed history
class PointsTransaction extends Equatable {
  /// Unique identifier
  final String id;

  /// Points amount (positive or negative)
  final int points;

  /// Reason for the transaction
  final PointsTransactionType type;

  /// Description of the transaction
  final String description;

  /// When the transaction occurred
  final DateTime createdAt;

  /// Related session ID if applicable
  final String? sessionId;

  const PointsTransaction({
    required this.id,
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
    this.sessionId,
  });

  /// Check if this is a positive transaction
  bool get isPositive => points > 0;

  @override
  List<Object?> get props => [id, points, type, description, createdAt, sessionId];
}

/// Types of points transactions
enum PointsTransactionType {
  sessionCompleted,    // +10 points
  sessionSkipped,      // -5 points
  perfectSession,      // +3 bonus
  streakBonus,         // +5 per 3-day streak
  achievementUnlocked, // varies
  dailyBonus,          // +2 for logging in
  examBonus,           // varies based on score
}

extension PointsTransactionTypeExtension on PointsTransactionType {
  String get displayName {
    switch (this) {
      case PointsTransactionType.sessionCompleted:
        return 'Session Completed';
      case PointsTransactionType.sessionSkipped:
        return 'Session Skipped';
      case PointsTransactionType.perfectSession:
        return 'Perfect Session';
      case PointsTransactionType.streakBonus:
        return 'Streak Bonus';
      case PointsTransactionType.achievementUnlocked:
        return 'Achievement Unlocked';
      case PointsTransactionType.dailyBonus:
        return 'Daily Bonus';
      case PointsTransactionType.examBonus:
        return 'Exam Bonus';
    }
  }

  String get displayNameAr {
    switch (this) {
      case PointsTransactionType.sessionCompleted:
        return 'اكتملت الجلسة';
      case PointsTransactionType.sessionSkipped:
        return 'تم تخطي الجلسة';
      case PointsTransactionType.perfectSession:
        return 'جلسة مثالية';
      case PointsTransactionType.streakBonus:
        return 'مكافأة السلسلة';
      case PointsTransactionType.achievementUnlocked:
        return 'إنجاز جديد';
      case PointsTransactionType.dailyBonus:
        return 'مكافأة يومية';
      case PointsTransactionType.examBonus:
        return 'مكافأة الامتحان';
    }
  }

  int get defaultPoints {
    switch (this) {
      case PointsTransactionType.sessionCompleted:
        return 10;
      case PointsTransactionType.sessionSkipped:
        return -5;
      case PointsTransactionType.perfectSession:
        return 3;
      case PointsTransactionType.streakBonus:
        return 5;
      case PointsTransactionType.achievementUnlocked:
        return 20;
      case PointsTransactionType.dailyBonus:
        return 2;
      case PointsTransactionType.examBonus:
        return 15;
    }
  }
}
