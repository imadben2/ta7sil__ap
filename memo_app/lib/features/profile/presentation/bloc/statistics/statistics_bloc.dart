import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_statistics_usecase.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

/// BLoC إدارة حالة الإحصائيات
///
/// مسؤول عن:
/// - تحميل الإحصائيات من API
/// - تحديث الإحصائيات (pull to refresh)
/// - إدارة حالات التحميل والنجاح والخطأ
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatisticsUseCase getStatistics;

  StatisticsBloc({required this.getStatistics})
    : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<RefreshStatistics>(_onRefreshStatistics);
  }

  /// معالج حدث تحميل الإحصائيات
  ///
  /// يعرض حالة تحميل أثناء جلب البيانات
  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final result = await getStatistics();

    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (statistics) => emit(StatisticsLoaded(statistics)),
    );
  }

  /// معالج حدث تحديث الإحصائيات
  ///
  /// لا يعرض حالة تحميل (للحفاظ على البيانات الحالية أثناء التحديث)
  Future<void> _onRefreshStatistics(
    RefreshStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    final result = await getStatistics();

    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (statistics) => emit(StatisticsLoaded(statistics)),
    );
  }
}
