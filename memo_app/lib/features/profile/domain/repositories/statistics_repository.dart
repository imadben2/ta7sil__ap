import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/statistics_entity.dart';

/// واجهة مستودع الإحصائيات
///
/// تحدد العمليات المتاحة للإحصائيات:
/// - جلب الإحصائيات الشاملة
/// - جلب بيانات الرسم البياني الأسبوعي
/// - تحديث الإحصائيات
abstract class StatisticsRepository {
  /// جلب الإحصائيات الشاملة
  ///
  /// يحاول الجلب من Cache أولًا (TTL: 15 دقيقة)
  /// إذا لم يكن موجود أو منتهي الصلاحية، يجلب من API
  ///
  /// Returns: [StatisticsEntity] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, StatisticsEntity>> getStatistics();

  /// جلب بيانات الرسم البياني الأسبوعي
  ///
  /// Parameters:
  /// - [startDate]: تاريخ البداية (اختياري - افتراضي: آخر 7 أيام)
  /// - [endDate]: تاريخ النهاية (اختياري - افتراضي: اليوم)
  ///
  /// Returns: قائمة [WeeklyDataPoint] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, List<WeeklyDataPoint>>> getWeeklyChart({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// إعادة تحميل الإحصائيات (تجاوز Cache)
  ///
  /// Returns: [StatisticsEntity] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, StatisticsEntity>> refreshStatistics();
}
