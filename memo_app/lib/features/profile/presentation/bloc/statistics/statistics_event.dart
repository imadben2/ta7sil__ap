import 'package:equatable/equatable.dart';

/// أحداث الإحصائيات
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// حدث تحميل الإحصائيات
///
/// يستخدم عند أول دخول للصفحة لتحميل البيانات
class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

/// حدث تحديث الإحصائيات
///
/// يستخدم عند سحب الصفحة للأسفل (pull to refresh)
class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}
