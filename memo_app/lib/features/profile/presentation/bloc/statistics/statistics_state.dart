import 'package:equatable/equatable.dart';
import '../../../domain/entities/statistics_entity.dart';

/// حالات الإحصائيات
abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

/// حالة التحميل
class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

/// حالة تحميل البيانات بنجاح
class StatisticsLoaded extends StatisticsState {
  /// كيان الإحصائيات المحملة
  final StatisticsEntity statistics;

  const StatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

/// حالة خطأ
class StatisticsError extends StatisticsState {
  /// رسالة الخطأ
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
