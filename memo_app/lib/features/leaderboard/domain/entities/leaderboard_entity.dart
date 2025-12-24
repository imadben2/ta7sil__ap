import 'package:equatable/equatable.dart';

/// Represents a single entry in the leaderboard
class LeaderboardEntry extends Equatable {
  final int rank;
  final int userId;
  final String name;
  final String? avatar;
  final double averageScore;
  final double bestScore;
  final int totalAttempts;
  final int totalPoints;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatar,
    required this.averageScore,
    required this.bestScore,
    required this.totalAttempts,
    required this.totalPoints,
    required this.isCurrentUser,
  });

  /// Get display name (first letter for avatar placeholder)
  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  /// Get formatted score string
  String get formattedScore => '${averageScore.toInt()}%';

  /// Get formatted best score string
  String get formattedBestScore => '${bestScore.toInt()}%';

  @override
  List<Object?> get props => [
        rank,
        userId,
        name,
        avatar,
        averageScore,
        bestScore,
        totalAttempts,
        totalPoints,
        isCurrentUser,
      ];
}

/// Current user's rank information
class CurrentUserRank extends Equatable {
  final int? rank;
  final LeaderboardEntry? entry;
  final bool inList;

  const CurrentUserRank({
    this.rank,
    this.entry,
    required this.inList,
  });

  @override
  List<Object?> get props => [rank, entry, inList];
}

/// Subject information for subject leaderboard
class LeaderboardSubject extends Equatable {
  final int id;
  final String nameAr;
  final String? color;
  final String? icon;

  const LeaderboardSubject({
    required this.id,
    required this.nameAr,
    this.color,
    this.icon,
  });

  @override
  List<Object?> get props => [id, nameAr, color, icon];
}

/// Complete leaderboard data
class LeaderboardData extends Equatable {
  final String type; // 'stream' or 'subject'
  final List<LeaderboardEntry> podium;
  final List<LeaderboardEntry> rankings;
  final CurrentUserRank currentUser;
  final int totalParticipants;
  final LeaderboardSubject? subject; // Only for subject leaderboard

  const LeaderboardData({
    required this.type,
    required this.podium,
    required this.rankings,
    required this.currentUser,
    required this.totalParticipants,
    this.subject,
  });

  /// Check if leaderboard is empty
  bool get isEmpty => rankings.isEmpty;

  /// Check if this is a subject leaderboard
  bool get isSubjectLeaderboard => type == 'subject';

  /// Check if this is a stream leaderboard
  bool get isStreamLeaderboard => type == 'stream';

  /// Get rankings excluding podium (4th place and below)
  List<LeaderboardEntry> get rankingsAfterPodium {
    if (rankings.length <= 3) return [];
    return rankings.sublist(3);
  }

  @override
  List<Object?> get props => [
        type,
        podium,
        rankings,
        currentUser,
        totalParticipants,
        subject,
      ];
}

/// Leaderboard period filter
enum LeaderboardPeriod {
  week,
  month,
  all;

  String get value {
    switch (this) {
      case LeaderboardPeriod.week:
        return 'week';
      case LeaderboardPeriod.month:
        return 'month';
      case LeaderboardPeriod.all:
        return 'all';
    }
  }

  String get labelAr {
    switch (this) {
      case LeaderboardPeriod.week:
        return 'هذا الأسبوع';
      case LeaderboardPeriod.month:
        return 'هذا الشهر';
      case LeaderboardPeriod.all:
        return 'الكل';
    }
  }
}

/// Leaderboard scope filter
enum LeaderboardScope {
  subject,
  stream;

  String get labelAr {
    switch (this) {
      case LeaderboardScope.subject:
        return 'المادة';
      case LeaderboardScope.stream:
        return 'الشعبة';
    }
  }
}
