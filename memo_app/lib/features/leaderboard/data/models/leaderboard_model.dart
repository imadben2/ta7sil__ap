import '../../domain/entities/leaderboard_entity.dart';

/// Model for LeaderboardEntry from API
class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.name,
    super.avatar,
    required super.averageScore,
    required super.bestScore,
    required super.totalAttempts,
    required super.totalPoints,
    required super.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['best_score'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: json['total_attempts'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'name': name,
      'avatar': avatar,
      'average_score': averageScore,
      'best_score': bestScore,
      'total_attempts': totalAttempts,
      'total_points': totalPoints,
      'is_current_user': isCurrentUser,
    };
  }
}

/// Model for CurrentUserRank from API
class CurrentUserRankModel extends CurrentUserRank {
  const CurrentUserRankModel({
    super.rank,
    super.entry,
    required super.inList,
  });

  factory CurrentUserRankModel.fromJson(Map<String, dynamic> json) {
    LeaderboardEntryModel? entry;
    if (json['entry'] != null) {
      entry = LeaderboardEntryModel.fromJson(json['entry'] as Map<String, dynamic>);
    }

    return CurrentUserRankModel(
      rank: json['rank'] as int?,
      entry: entry,
      inList: json['in_list'] as bool? ?? false,
    );
  }
}

/// Model for LeaderboardSubject from API
class LeaderboardSubjectModel extends LeaderboardSubject {
  const LeaderboardSubjectModel({
    required super.id,
    required super.nameAr,
    super.color,
    super.icon,
  });

  factory LeaderboardSubjectModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardSubjectModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String? ?? '',
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

/// Model for LeaderboardData from API
class LeaderboardDataModel extends LeaderboardData {
  const LeaderboardDataModel({
    required super.type,
    required super.podium,
    required super.rankings,
    required super.currentUser,
    required super.totalParticipants,
    super.subject,
  });

  factory LeaderboardDataModel.fromJson(Map<String, dynamic> json) {
    // Parse podium list
    final podiumList = (json['podium'] as List<dynamic>?)
            ?.map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse rankings list
    final rankingsList = (json['rankings'] as List<dynamic>?)
            ?.map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse current user
    final currentUserJson = json['current_user'] as Map<String, dynamic>?;
    final currentUser = currentUserJson != null
        ? CurrentUserRankModel.fromJson(currentUserJson)
        : const CurrentUserRankModel(inList: false);

    // Parse subject (if present)
    LeaderboardSubjectModel? subject;
    if (json['subject'] != null) {
      subject = LeaderboardSubjectModel.fromJson(json['subject'] as Map<String, dynamic>);
    }

    return LeaderboardDataModel(
      type: json['type'] as String? ?? 'stream',
      podium: podiumList,
      rankings: rankingsList,
      currentUser: currentUser,
      totalParticipants: json['total_participants'] as int? ?? 0,
      subject: subject,
    );
  }
}
