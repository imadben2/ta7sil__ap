import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/planner_settings.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/usecases/get_planner_settings.dart';
import '../../domain/usecases/update_planner_settings.dart';
import '../../services/session_notification_service.dart';
import 'planner_bloc.dart';
import 'planner_state.dart';
import '../../../../core/usecase/usecase.dart';
import 'settings_state.dart';

/// Cubit for managing Planner Settings
///
/// Handles loading and updating all planner configuration
class SettingsCubit extends Cubit<SettingsState> {
  final GetPlannerSettings getSettingsUseCase;
  final UpdatePlannerSettings updateSettingsUseCase;
  final SessionNotificationService sessionNotificationService;
  final PlannerBloc plannerBloc;

  SettingsCubit({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
    required this.sessionNotificationService,
    required this.plannerBloc,
  }) : super(SettingsState.initial());

  /// Load planner settings
  Future<void> loadSettings() async {
    emit(state.loading());

    final result = await getSettingsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(
          state.error(
            'فشل في تحميل الإعدادات: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (settings) {
        emit(state.loaded(settings));
      },
    );
  }

  /// Update study hours
  Future<void> updateStudyHours({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      studyStartTime: startTime,
      studyEndTime: endTime,
    );

    await _saveSettings(updatedSettings, 'تم تحديث ساعات الدراسة');
  }

  /// Update sleep schedule
  Future<void> updateSleepSchedule({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      sleepStartTime: startTime,
      sleepEndTime: endTime,
    );

    await _saveSettings(updatedSettings, 'تم تحديث جدول النوم');
  }

  /// Update energy levels
  Future<void> updateEnergyLevels({
    int? morning,
    int? afternoon,
    int? evening,
    int? night,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      morningEnergyLevel: morning,
      afternoonEnergyLevel: afternoon,
      eveningEnergyLevel: evening,
      nightEnergyLevel: night,
    );

    await _saveSettings(updatedSettings, 'تم تحديث مستويات الطاقة');
  }

  /// Toggle Pomodoro technique
  Future<void> togglePomodoro(bool enabled) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      usePomodoroTechnique: enabled,
    );

    await _saveSettings(
      updatedSettings,
      enabled ? 'تم تفعيل تقنية بومودورو' : 'تم تعطيل تقنية بومودورو',
    );
  }

  /// Update Pomodoro durations
  Future<void> updatePomodoroDurations({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? pomodorosBeforeLongBreak,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      pomodoroDurationMinutes: workMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      pomodorosBeforeLongBreak: pomodorosBeforeLongBreak,
    );

    await _saveSettings(updatedSettings, 'تم تحديث إعدادات بومودورو');
  }

  /// Toggle prayer times
  Future<void> togglePrayerTimes(bool enabled) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      enablePrayerTimes: enabled,
    );

    await _saveSettings(
      updatedSettings,
      enabled ? 'تم تفعيل أوقات الصلاة' : 'تم تعطيل أوقات الصلاة',
    );
  }

  /// Update prayer settings
  Future<void> updatePrayerSettings({
    String? city,
    int? durationMinutes,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      cityForPrayer: city,
      prayerDurationMinutes: durationMinutes,
    );

    await _saveSettings(updatedSettings, 'تم تحديث إعدادات الصلاة');
  }

  /// Toggle exercise
  Future<void> toggleExercise(bool enabled) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(exerciseEnabled: enabled);

    await _saveSettings(
      updatedSettings,
      enabled ? 'تم تفعيل التمارين الرياضية' : 'تم تعطيل التمارين الرياضية',
    );
  }

  /// Update exercise settings
  Future<void> updateExerciseSettings({
    List<int>? days,
    TimeOfDay? time,
    int? durationMinutes,
  }) async {
    if (!state.hasSettings) return;

    print('[SettingsCubit] updateExerciseSettings called:');
    print('  - days: $days');
    print('  - time: $time');
    print('  - durationMinutes: $durationMinutes');
    print('  - Current exerciseDurationMinutes: ${state.settings!.exerciseDurationMinutes}');

    final updatedSettings = state.settings!.copyWith(
      exerciseDays: days,
      exerciseTime: time,
      exerciseDurationMinutes: durationMinutes,
    );

    print('[SettingsCubit] Updated exerciseDurationMinutes: ${updatedSettings.exerciseDurationMinutes}');

    await _saveSettings(updatedSettings, 'تم تحديث إعدادات التمارين');
  }

  /// Update priority algorithm weights
  Future<void> updatePriorityWeights({
    int? coefficient,
    int? examProximity,
    int? difficulty,
    int? inactivity,
    int? performanceGap,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      coefficientWeight: coefficient,
      examProximityWeight: examProximity,
      difficultyWeight: difficulty,
      inactivityWeight: inactivity,
      performanceGapWeight: performanceGap,
    );

    await _saveSettings(updatedSettings, 'تم تحديث أوزان الأولويات');
  }

  /// Update adaptation settings
  Future<void> updateAdaptationSettings({
    bool? autoReschedule,
    bool? adaptToPerformance,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      autoRescheduleEnabled: autoReschedule,
      adaptToPerformanceEnabled: adaptToPerformance,
    );

    await _saveSettings(updatedSettings, 'تم تحديث إعدادات التكيف');
  }

  /// Update limits
  Future<void> updateLimits({
    int? maxStudyHoursPerDay,
    int? minBreakBetweenSessions,
  }) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      maxStudyHoursPerDay: maxStudyHoursPerDay,
      minBreakBetweenSessions: minBreakBetweenSessions,
    );

    await _saveSettings(updatedSettings, 'تم تحديث الحدود');
  }

  /// Update max study hours per day
  Future<void> updateMaxStudyHours(int hours) async {
    await updateLimits(maxStudyHoursPerDay: hours);
  }

  /// Toggle session reminders
  Future<void> toggleSessionReminders(bool enabled) async {
    if (!state.hasSettings) return;

    final oldSettings = state.settings!;
    final updatedSettings = oldSettings.copyWith(sessionReminders: enabled);

    // Handle notification scheduling based on toggle state
    if (!enabled) {
      // Cancel all notifications when disabled
      await sessionNotificationService.cancelAllNotifications();
      debugPrint('[SettingsCubit] Session reminders disabled - cancelled all notifications');
    } else {
      // Schedule notifications for all upcoming sessions when enabled
      try {
        final sessions = _getUpcomingSessions(limit: 64);
        await sessionNotificationService.scheduleMultipleSessions(
          sessions,
          updatedSettings.reminderMinutesBefore,
        );
        debugPrint('[SettingsCubit] Session reminders enabled - scheduled ${sessions.length} notifications');
      } catch (e) {
        debugPrint('[SettingsCubit] Error scheduling notifications: $e');
      }
    }

    await _saveSettings(
      updatedSettings,
      enabled ? 'تم تفعيل تذكيرات الجلسات' : 'تم تعطيل تذكيرات الجلسات',
    );
  }

  /// Update reminder minutes before session
  Future<void> updateReminderMinutes(int minutes) async {
    if (!state.hasSettings) return;

    final oldSettings = state.settings!;
    final updatedSettings = oldSettings.copyWith(reminderMinutesBefore: minutes);

    // Re-schedule notifications if reminders are enabled and time changed
    if (updatedSettings.sessionReminders && oldSettings.reminderMinutesBefore != minutes) {
      try {
        final sessions = _getUpcomingSessions(limit: 64);
        await sessionNotificationService.syncScheduledNotifications(
          sessions,
          minutes,
        );
        debugPrint('[SettingsCubit] Reminder time updated - rescheduled ${sessions.length} notifications');
      } catch (e) {
        debugPrint('[SettingsCubit] Error rescheduling notifications: $e');
      }
    }

    await _saveSettings(
      updatedSettings,
      'تم تحديث وقت التذكير إلى $minutes دقيقة قبل الجلسة',
    );
  }

  /// Get upcoming scheduled sessions from planner state
  List<StudySession> _getUpcomingSessions({int limit = 64}) {
    final plannerState = plannerBloc.state;

    if (plannerState is! ScheduleLoaded) {
      return [];
    }

    final now = DateTime.now();
    final upcomingSessions = plannerState.sessions
        .where((s) => s.status.name == 'scheduled')
        .where((s) {
          final sessionStart = DateTime(
            s.scheduledDate.year,
            s.scheduledDate.month,
            s.scheduledDate.day,
            s.scheduledStartTime.hour,
            s.scheduledStartTime.minute,
          );
          return sessionStart.isAfter(now);
        })
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return upcomingSessions.take(limit).toList();
  }

  /// Update view mode
  Future<void> updateViewMode(String viewMode) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      viewMode: viewMode,
    );

    final modeLabels = {
      'list': 'قائمة',
      'grid': 'شبكة',
      'calendar': 'تقويم',
      'timeline': 'خط زمني',
    };

    await _saveSettings(
      updatedSettings,
      'تم تغيير وضع العرض إلى ${modeLabels[viewMode] ?? viewMode}',
    );
  }

  /// Update selected subject IDs for schedule generation
  Future<void> updateSelectedSubjectIds(List<String> subjectIds) async {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      selectedSubjectIds: subjectIds,
    );

    await _saveSettings(
      updatedSettings,
      'تم حفظ اختيار المواد (${subjectIds.length} ${subjectIds.length == 1 ? 'مادة' : 'مواد'})',
    );
  }

  /// Update session duration for a specific coefficient
  Future<void> updateCoefficientDuration({
    required int coefficient,
    required int durationMinutes,
  }) async {
    if (!state.hasSettings) return;

    final updatedDurations = Map<int, int>.from(state.settings!.coefficientDurations);
    updatedDurations[coefficient] = durationMinutes;

    final updatedSettings = state.settings!.copyWith(
      coefficientDurations: updatedDurations,
    );

    await _saveSettings(updatedSettings, 'تم تحديث مدة الجلسة للمعامل $coefficient');
  }

  /// Reset a specific coefficient duration to default
  Future<void> resetCoefficientDuration(int coefficient) async {
    if (!state.hasSettings) return;

    // Get default duration for this coefficient
    final defaultSettings = PlannerSettings(
      userId: state.settings!.userId,
      studyStartTime: const TimeOfDay(hour: 8, minute: 0),
      studyEndTime: const TimeOfDay(hour: 22, minute: 0),
      sleepStartTime: const TimeOfDay(hour: 23, minute: 0),
      sleepEndTime: const TimeOfDay(hour: 7, minute: 0),
    );

    final defaultDuration = defaultSettings.coefficientDurations[coefficient] ??
                            defaultSettings.sessionDurationMinutes;

    final updatedDurations = Map<int, int>.from(state.settings!.coefficientDurations);
    updatedDurations[coefficient] = defaultDuration;

    final updatedSettings = state.settings!.copyWith(
      coefficientDurations: updatedDurations,
    );

    await _saveSettings(
      updatedSettings,
      'تم إعادة تعيين مدة المعامل $coefficient إلى القيمة الافتراضية ($defaultDuration دقيقة)',
    );
  }

  /// Reset all coefficient durations to defaults
  Future<void> resetAllCoefficientDurations() async {
    if (!state.hasSettings) return;

    final defaultSettings = PlannerSettings(
      userId: state.settings!.userId,
      studyStartTime: const TimeOfDay(hour: 8, minute: 0),
      studyEndTime: const TimeOfDay(hour: 22, minute: 0),
      sleepStartTime: const TimeOfDay(hour: 23, minute: 0),
      sleepEndTime: const TimeOfDay(hour: 7, minute: 0),
    );

    final updatedSettings = state.settings!.copyWith(
      coefficientDurations: defaultSettings.coefficientDurations,
    );

    await _saveSettings(
      updatedSettings,
      'تم إعادة تعيين جميع مدد المعاملات إلى القيم الافتراضية',
    );
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    if (!state.hasSettings) return;

    // Create default settings with same userId
    final defaultSettings = PlannerSettings(
      userId: state.settings!.userId,
      studyStartTime: const TimeOfDay(hour: 8, minute: 0),
      studyEndTime: const TimeOfDay(hour: 22, minute: 0),
      sleepStartTime: const TimeOfDay(hour: 23, minute: 0),
      sleepEndTime: const TimeOfDay(hour: 7, minute: 0),
    );

    await _saveSettings(
      defaultSettings,
      'تم إعادة تعيين الإعدادات إلى الافتراضية',
    );
  }

  /// Internal method to save settings
  Future<void> _saveSettings(
    PlannerSettings settings,
    String successMessage,
  ) async {
    print('[SettingsCubit] _saveSettings called');
    print('[SettingsCubit] Settings to save:');
    print('  - exerciseEnabled: ${settings.exerciseEnabled}');
    print('  - exerciseDurationMinutes: ${settings.exerciseDurationMinutes}');

    emit(state.saving());

    final result = await updateSettingsUseCase(settings);

    result.fold(
      (failure) {
        print('[SettingsCubit] ✗ Save failed: ${failure.message}');
        emit(
          state.error(
            'فشل في حفظ الإعدادات: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) {
        print('[SettingsCubit] ✓ Save successful: $successMessage');
        emit(state.saved(settings, successMessage));
      },
    );
  }

  /// Refresh settings (reload from repository)
  Future<void> refreshSettings() async {
    await loadSettings();
  }
}
