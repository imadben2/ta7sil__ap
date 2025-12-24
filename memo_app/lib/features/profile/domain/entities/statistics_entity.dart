import 'package:equatable/equatable.dart';

/// كيان الإحصائيات المفصلة
///
/// يحتوي على جميع الإحصائيات التفصيلية للمستخدم:
/// - نظرة عامة (سلسلة، نقاط، جلسات، ساعات)
/// - بيانات الرسم البياني الأسبوعي
/// - توزيع المواد الدراسية
/// - الإنجازات والشارات
/// - تقويم السلسلة
class StatisticsEntity extends Equatable {
  // === نظرة عامة (Overview) ===

  /// السلسلة الحالية (عدد الأيام المتتالية)
  final int currentStreak;

  /// أطول سلسلة تم تحقيقها
  final int longestStreak;

  /// مجموع النقاط الكلي
  final int totalPoints;

  /// عدد الجلسات المكتملة
  final int completedSessions;

  /// مجموع ساعات الدراسة
  final double totalStudyHours;

  /// متوسط نتائج الاختبارات (من 20)
  final double? averageQuizScore;

  /// عدد الشارات المفتوحة
  final int unlockedBadges;

  /// عدد الشارات الكلي
  final int totalBadges;

  // === بيانات الرسم البياني الأسبوعي ===

  /// بيانات ساعات الدراسة الأسبوعية (آخر 7 أيام)
  final List<WeeklyDataPoint> weeklyHours;

  // === توزيع المواد الدراسية ===

  /// توزيع الوقت والنسب لكل مادة
  final List<SubjectBreakdown> subjectBreakdown;

  // === الإنجازات ===

  /// قائمة الإنجازات (مفتوحة ومقفلة)
  final List<Achievement> achievements;

  // === تقويم السلسلة ===

  /// بيانات تقويم السلسلة (أيام نشطة)
  final StreakCalendar streakCalendar;

  const StatisticsEntity({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.completedSessions,
    required this.totalStudyHours,
    this.averageQuizScore,
    required this.unlockedBadges,
    required this.totalBadges,
    required this.weeklyHours,
    required this.subjectBreakdown,
    required this.achievements,
    required this.streakCalendar,
  });

  /// نسبة الشارات المفتوحة
  double get badgesProgress =>
      totalBadges > 0 ? (unlockedBadges / totalBadges) * 100 : 0.0;

  /// متوسط ساعات الدراسة اليومية (آخر 7 أيام)
  double get averageDailyHours {
    if (weeklyHours.isEmpty) return 0.0;
    final totalHours = weeklyHours.fold<double>(
      0.0,
      (sum, data) => sum + data.hours,
    );
    return totalHours / weeklyHours.length;
  }

  /// هل هناك نتائج اختبارات؟
  bool get hasQuizScores => averageQuizScore != null;

  /// المادة الأكثر دراسة
  SubjectBreakdown? get mostStudiedSubject {
    if (subjectBreakdown.isEmpty) return null;
    return subjectBreakdown.reduce(
      (curr, next) => curr.hours > next.hours ? curr : next,
    );
  }

  /// عدد الإنجازات المفتوحة
  int get unlockedAchievementsCount =>
      achievements.where((a) => a.isUnlocked).length;

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    totalPoints,
    completedSessions,
    totalStudyHours,
    averageQuizScore,
    unlockedBadges,
    totalBadges,
    weeklyHours,
    subjectBreakdown,
    achievements,
    streakCalendar,
  ];
}

/// نقطة بيانات في الرسم البياني الأسبوعي
class WeeklyDataPoint extends Equatable {
  /// التاريخ
  final DateTime date;

  /// عدد الساعات في هذا اليوم
  final double hours;

  /// عدد الجلسات في هذا اليوم
  final int sessions;

  const WeeklyDataPoint({
    required this.date,
    required this.hours,
    required this.sessions,
  });

  /// اسم اليوم بالعربية (السبت، الأحد، ...)
  String get dayNameAr {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }

  /// اسم اليوم مختصر (سب، أح، ...)
  String get dayNameShortAr {
    const days = ['اث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
    return days[date.weekday - 1];
  }

  @override
  List<Object?> get props => [date, hours, sessions];
}

/// توزيع مادة دراسية
class SubjectBreakdown extends Equatable {
  /// معرف المادة
  final int subjectId;

  /// اسم المادة
  final String subjectName;

  /// اسم المادة بالعربية
  final String subjectNameAr;

  /// لون المادة
  final String color;

  /// عدد الساعات المدروسة
  final double hours;

  /// عدد الجلسات
  final int sessions;

  /// النسبة المئوية من مجموع الوقت
  final double percentage;

  const SubjectBreakdown({
    required this.subjectId,
    required this.subjectName,
    required this.subjectNameAr,
    required this.color,
    required this.hours,
    required this.sessions,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
    subjectId,
    subjectName,
    subjectNameAr,
    color,
    hours,
    sessions,
    percentage,
  ];
}

/// إنجاز (Achievement/Badge)
class Achievement extends Equatable {
  /// معرف الإنجاز
  final int id;

  /// عنوان الإنجاز
  final String title;

  /// عنوان الإنجاز بالعربية
  final String titleAr;

  /// الوصف
  final String description;

  /// الوصف بالعربية
  final String descriptionAr;

  /// أيقونة/رمز الإنجاز
  final String icon;

  /// هل مفتوح؟
  final bool isUnlocked;

  /// تاريخ الفتح
  final DateTime? unlockedAt;

  /// النقاط المكتسبة
  final int points;

  const Achievement({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
    required this.points,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    titleAr,
    description,
    descriptionAr,
    icon,
    isUnlocked,
    unlockedAt,
    points,
  ];
}

/// تقويم السلسلة (Streak Calendar)
class StreakCalendar extends Equatable {
  /// الشهر الحالي
  final int month;

  /// السنة الحالية
  final int year;

  /// قائمة الأيام النشطة في الشهر (1-31)
  final List<int> activeDays;

  /// عدد الأيام النشطة في الشهر
  final int activeDaysCount;

  const StreakCalendar({
    required this.month,
    required this.year,
    required this.activeDays,
    required this.activeDaysCount,
  });

  /// هل اليوم نشط؟
  bool isActiveDayActive(int day) => activeDays.contains(day);

  /// نسبة الأيام النشطة في الشهر
  double get activityPercentage {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return (activeDaysCount / daysInMonth) * 100;
  }

  @override
  List<Object?> get props => [month, year, activeDays, activeDaysCount];
}
