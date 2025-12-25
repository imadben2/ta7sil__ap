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

  /// Update study hours (local only - call saveSettings to persist)
  void updateStudyHours({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      studyStartTime: startTime,
      studyEndTime: endTime,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update sleep schedule (local only - call saveSettings to persist)
  void updateSleepSchedule({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      sleepStartTime: startTime,
      sleepEndTime: endTime,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update energy levels (local only - call saveSettings to persist)
  void updateEnergyLevels({
    int? morning,
    int? afternoon,
    int? evening,
    int? night,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      morningEnergyLevel: morning,
      afternoonEnergyLevel: afternoon,
      eveningEnergyLevel: evening,
      nightEnergyLevel: night,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Toggle Pomodoro technique (local only - call saveSettings to persist)
  void togglePomodoro(bool enabled) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      usePomodoroTechnique: enabled,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update Pomodoro durations (local only - call saveSettings to persist)
  void updatePomodoroDurations({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? pomodorosBeforeLongBreak,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      pomodoroDurationMinutes: workMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      pomodorosBeforeLongBreak: pomodorosBeforeLongBreak,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Toggle prayer times (local only - call saveSettings to persist)
  void togglePrayerTimes(bool enabled) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      enablePrayerTimes: enabled,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update prayer settings (local only - call saveSettings to persist)
  void updatePrayerSettings({
    String? city,
    int? durationMinutes,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      cityForPrayer: city,
      prayerDurationMinutes: durationMinutes,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Toggle exercise (local only - call saveSettings to persist)
  void toggleExercise(bool enabled) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(exerciseEnabled: enabled);

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update exercise settings (local only - call saveSettings to persist)
  void updateExerciseSettings({
    List<int>? days,
    TimeOfDay? time,
    int? durationMinutes,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      exerciseDays: days,
      exerciseTime: time,
      exerciseDurationMinutes: durationMinutes,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update priority algorithm weights (local only - call saveSettings to persist)
  void updatePriorityWeights({
    int? coefficient,
    int? examProximity,
    int? difficulty,
    int? inactivity,
    int? performanceGap,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      coefficientWeight: coefficient,
      examProximityWeight: examProximity,
      difficultyWeight: difficulty,
      inactivityWeight: inactivity,
      performanceGapWeight: performanceGap,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update adaptation settings (local only - call saveSettings to persist)
  void updateAdaptationSettings({
    bool? autoReschedule,
    bool? adaptToPerformance,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      autoRescheduleEnabled: autoReschedule,
      adaptToPerformanceEnabled: adaptToPerformance,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update limits (local only - call saveSettings to persist)
  void updateLimits({
    int? maxStudyHoursPerDay,
    int? minBreakBetweenSessions,
  }) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      maxStudyHoursPerDay: maxStudyHoursPerDay,
      minBreakBetweenSessions: minBreakBetweenSessions,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update max study hours per day (local only - call saveSettings to persist)
  void updateMaxStudyHours(int hours) {
    updateLimits(maxStudyHoursPerDay: hours);
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

    await _saveToApi(
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

    await _saveToApi(
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

  /// Update view mode (local only - call saveSettings to persist)
  void updateViewMode(String viewMode) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      viewMode: viewMode,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update selected subject IDs for schedule generation (local only - call saveSettings to persist)
  void updateSelectedSubjectIds(List<String> subjectIds) {
    if (!state.hasSettings) return;

    final updatedSettings = state.settings!.copyWith(
      selectedSubjectIds: subjectIds,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Update session duration for a specific coefficient (local only - call saveSettings to persist)
  void updateCoefficientDuration({
    required int coefficient,
    required int durationMinutes,
  }) {
    if (!state.hasSettings) return;

    final updatedDurations = Map<int, int>.from(state.settings!.coefficientDurations);
    updatedDurations[coefficient] = durationMinutes;

    final updatedSettings = state.settings!.copyWith(
      coefficientDurations: updatedDurations,
    );

    emit(state.updatedLocally(updatedSettings));
  }

  /// Reset a specific coefficient duration to default (local only - call saveSettings to persist)
  void resetCoefficientDuration(int coefficient) {
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

    emit(state.updatedLocally(updatedSettings));
  }

  /// Reset all coefficient durations to defaults (local only - call saveSettings to persist)
  void resetAllCoefficientDurations() {
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

    emit(state.updatedLocally(updatedSettings));
  }

  /// Reset settings to defaults (local only - call saveSettings to persist)
  void resetToDefaults() {
    if (!state.hasSettings) return;

    // Create default settings with same userId
    final defaultSettings = PlannerSettings(
      userId: state.settings!.userId,
      studyStartTime: const TimeOfDay(hour: 8, minute: 0),
      studyEndTime: const TimeOfDay(hour: 22, minute: 0),
      sleepStartTime: const TimeOfDay(hour: 23, minute: 0),
      sleepEndTime: const TimeOfDay(hour: 7, minute: 0),
    );

    emit(state.updatedLocally(defaultSettings));
  }

  /// Save all pending settings changes to the API
  /// Call this when user clicks "حفظ الإعدادات" button
  Future<void> saveSettings() async {
    if (!state.hasSettings) return;
    if (!state.hasUnsavedChanges) return;

    await _saveToApi(state.settings!, 'تم حفظ الإعدادات بنجاح');
  }

  /// Internal method to save settings to API
  Future<void> _saveToApi(
    PlannerSettings settings,
    String successMessage,
  ) async {
    debugPrint('[SettingsCubit] _saveToApi called');

    emit(state.saving());

    final result = await updateSettingsUseCase(settings);

    result.fold(
      (failure) {
        debugPrint('[SettingsCubit] ✗ Save failed: ${failure.message}');
        emit(
          state.error(
            'فشل في حفظ الإعدادات: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) {
        debugPrint('[SettingsCubit] ✓ Save successful: $successMessage');
        emit(state.saved(settings, successMessage));
      },
    );
  }

  /// Discard unsaved changes and reload from server
  Future<void> discardChanges() async {
    await loadSettings();
  }

  /// Refresh settings (reload from repository)
  Future<void> refreshSettings() async {
    await loadSettings();
  }
}
