import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/generate_schedule.dart';
import '../../domain/usecases/get_todays_sessions.dart';
import '../../domain/usecases/get_week_sessions.dart';
import '../../domain/usecases/start_session.dart';
import '../../domain/usecases/pause_session.dart';
import '../../domain/usecases/resume_session.dart';
import '../../domain/usecases/complete_session.dart';
import '../../domain/usecases/skip_session.dart';
import '../../domain/usecases/get_planner_settings.dart';
import '../../domain/usecases/update_planner_settings.dart';
import '../../domain/usecases/get_all_subjects.dart';
import '../../domain/usecases/delete_all_sessions.dart';
import '../../domain/usecases/mark_past_sessions_missed.dart';
import '../../domain/usecases/reschedule_missed_session.dart';
import '../../domain/usecases/reschedule_session.dart';
import '../../domain/usecases/pin_session.dart';
import '../../domain/usecases/trigger_sync.dart';
import '../../domain/usecases/trigger_adaptation.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/session_content.dart';
import '../../domain/repositories/planner_repository.dart';
import '../../data/datasources/planner_local_datasource.dart';
import '../../services/session_notification_service.dart';
import '../../../../core/usecase/usecase.dart';
import 'planner_event.dart';
import 'planner_state.dart';
import 'package:flutter/foundation.dart';

/// Main BLoC for Planner feature
///
/// Handles all schedule management and session operations
class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final GenerateSchedule generateScheduleUseCase;
  final GetTodaysSessions getTodaysSessionsUseCase;
  final GetWeekSessions getWeekSessionsUseCase;
  final StartSession startSessionUseCase;
  final PauseSession pauseSessionUseCase;
  final ResumeSession resumeSessionUseCase;
  final CompleteSession completeSessionUseCase;
  final SkipSession skipSessionUseCase;
  final GetPlannerSettings getSettingsUseCase;
  final UpdatePlannerSettings updateSettingsUseCase;
  final GetAllSubjects getAllSubjectsUseCase;
  final DeleteAllSessions deleteAllSessionsUseCase;
  final MarkPastSessionsMissed markPastSessionsMissedUseCase;
  final RescheduleMissedSession rescheduleMissedSessionUseCase;
  final RescheduleSession rescheduleSessionUseCase;
  final PinSession pinSessionUseCase;
  final TriggerSync triggerSyncUseCase;
  final GetMissedSessions getMissedSessionsUseCase;
  final GetOverdueSessions getOverdueSessionsUseCase;
  final TriggerAdaptation triggerAdaptationUseCase;
  final PlannerLocalDataSource localDataSource;
  final PlannerRepository? plannerRepository; // For session content operations
  final SessionNotificationService sessionNotificationService;

  PlannerBloc({
    required this.generateScheduleUseCase,
    required this.getTodaysSessionsUseCase,
    required this.getWeekSessionsUseCase,
    required this.startSessionUseCase,
    required this.pauseSessionUseCase,
    required this.resumeSessionUseCase,
    required this.completeSessionUseCase,
    required this.skipSessionUseCase,
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
    required this.getAllSubjectsUseCase,
    required this.deleteAllSessionsUseCase,
    required this.markPastSessionsMissedUseCase,
    required this.rescheduleMissedSessionUseCase,
    required this.rescheduleSessionUseCase,
    required this.pinSessionUseCase,
    required this.triggerSyncUseCase,
    required this.getMissedSessionsUseCase,
    required this.getOverdueSessionsUseCase,
    required this.triggerAdaptationUseCase,
    required this.localDataSource,
    required this.sessionNotificationService,
    this.plannerRepository,
  }) : super(const PlannerInitial()) {
    // Schedule Management
    on<GenerateScheduleEvent>(_onGenerateSchedule);
    on<LoadTodaysScheduleEvent>(_onLoadTodaysSchedule);
    on<LoadWeekScheduleEvent>(_onLoadWeekSchedule);
    on<RefreshScheduleEvent>(_onRefreshSchedule);
    on<ForceRefreshFromServerEvent>(_onForceRefreshFromServer);

    // Session Actions
    on<StartSessionEvent>(_onStartSession);
    on<PauseSessionEvent>(_onPauseSession);
    on<ResumeSessionEvent>(_onResumeSession);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<SkipSessionEvent>(_onSkipSession);
    on<RescheduleSessionEvent>(_onRescheduleSession);
    on<PinSessionEvent>(_onPinSession);

    // Settings
    on<SaveSettingsEvent>(_onSaveSettings);

    // Sync & Cache
    on<SyncOfflineChangesEvent>(_onSyncOfflineChanges);
    on<ClearCacheEvent>(_onClearCache);
    on<DeleteScheduleEvent>(_onDeleteSchedule);

    // Session Lifecycle
    on<CheckSessionLifecycleEvent>(_onCheckSessionLifecycle);
    on<RescheduleMissedSessionEvent>(_onRescheduleMissedSession);
    on<LoadMissedSessionsEvent>(_onLoadMissedSessions);
    on<LoadOverdueSessionsEvent>(_onLoadOverdueSessions);

    // Full Schedule
    on<LoadFullScheduleEvent>(_onLoadFullSchedule);
    on<LoadSessionsForDateEvent>(_onLoadSessionsForDate);

    // Adaptation
    on<TriggerAdaptationEvent>(_onTriggerAdaptation);

    // Session Content (Curriculum Integration)
    on<LoadSessionContentEvent>(_onLoadSessionContent);
    on<MarkContentPhaseCompleteEvent>(_onMarkContentPhaseComplete);
    on<MarkSessionContentCompleteEvent>(_onMarkSessionContentComplete);
  }

  // ==========================================================================
  // Schedule Management Handlers
  // ==========================================================================

  Future<void> _onGenerateSchedule(
    GenerateScheduleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const GeneratingSchedule(progress: 0));

    // Get settings first
    final settingsResult = await getSettingsUseCase(NoParams());

    await settingsResult.fold(
      (failure) async {
        emit(
          PlannerError(
            message: 'فشل في تحميل الإعدادات: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (settings) async {
        if (kDebugMode) print('[PlannerBloc] Starting schedule generation...');
        if (kDebugMode)
          print(
            '[PlannerBloc] Settings loaded: ${settings.studyStartTime} - ${settings.studyEndTime}',
          );
        emit(const GeneratingSchedule(progress: 30));

        // Load subjects from repository
        if (kDebugMode) print('[PlannerBloc] Loading subjects...');
        final subjectsResult = await getAllSubjectsUseCase(NoParams());

        List<Subject> allSubjects = [];
        await subjectsResult.fold(
          (failure) async {
            if (kDebugMode)
              print(
                '[PlannerBloc] Failed to load subjects: ${failure.message}',
              );
            emit(
              PlannerError(
                message: 'فشل في تحميل المواد: ${failure.message}',
                failure: failure,
              ),
            );
            return;
          },
          (loadedSubjects) async {
            allSubjects = loadedSubjects;
            if (kDebugMode)
              print('[PlannerBloc] Loaded ${allSubjects.length} subjects from API');
          },
        );

        // If we had an error loading subjects, return early
        if (allSubjects.isEmpty && state is PlannerError) {
          if (kDebugMode) print('[PlannerBloc] Returning early due to error');
          return;
        }

        // FILTER subjects by selectedSubjectIds if provided
        List<Subject> subjects = allSubjects;
        if (event.selectedSubjectIds != null && event.selectedSubjectIds!.isNotEmpty) {
          subjects = allSubjects.where((subject) {
            return event.selectedSubjectIds!.contains(subject.id.toString());
          }).toList();

          if (kDebugMode) {
            print('[PlannerBloc] ========== SUBJECT FILTERING ==========');
            print('[PlannerBloc] Total subjects loaded: ${allSubjects.length}');
            print('[PlannerBloc] Selected subject IDs: ${event.selectedSubjectIds}');
            print('[PlannerBloc] Filtered to ${subjects.length} subjects:');
            for (final subject in subjects) {
              print('  - ${subject.name} (ID: ${subject.id})');
            }
            print('[PlannerBloc] ========================================');
          }
        } else {
          if (kDebugMode) {
            print('[PlannerBloc] ⚠ No selectedSubjectIds provided, using ALL ${subjects.length} subjects');
          }
        }

        // For now, use empty exam list until exams feature is implemented
        final List<Exam> exams = [];

        // Check if subjects are available after filtering
        if (subjects.isEmpty) {
          if (kDebugMode) print('[PlannerBloc] No subjects available after filtering');
          emit(
            const PlannerError(
              message:
                  'لا توجد مواد مختارة! يرجى اختيار مواد دراسية لإنشاء الجدول.',
              canRetry: false,
            ),
          );
          return;
        }

        // Use settings for study times (always from planner settings)
        final effectiveSettings = settings;

        // Generate schedule with FILTERED subjects
        if (kDebugMode)
          print(
            '[PlannerBloc] Generating ${event.scheduleType.name} schedule with ${subjects.length} selected subjects',
          );
        final params = GenerateScheduleParams(
          settings: effectiveSettings,
          subjects: subjects,
          exams: exams,
          startDate: event.startDate,
          endDate: event.endDate,
          startFromNow: event.startFromNow,
          scheduleType: event.scheduleType,
          selectedSubjectIds: event.selectedSubjectIds,
        );

        emit(const GeneratingSchedule(progress: 60));

        final result = await generateScheduleUseCase(params);

        emit(const GeneratingSchedule(progress: 90));

        result.fold(
          (failure) {
            if (kDebugMode)
              print(
                '[PlannerBloc] Schedule generation failed: ${failure.message}',
              );
            emit(
              PlannerError(
                message: 'فشل في إنشاء الجدول: ${failure.message}',
                failure: failure,
              ),
            );
          },
          (schedule) async {
            if (kDebugMode)
              print(
                '[PlannerBloc] Schedule generated with ${schedule.sessions.length} sessions',
              );
            if (schedule.sessions.isEmpty) {
              emit(
                const PlannerError(
                  message:
                      'تم إنشاء الجدول ولكن لا توجد جلسات. يرجى التحقق من الإعدادات.',
                  canRetry: true,
                ),
              );
            } else {
              // First emit ScheduleGenerated for the snackbar
              emit(
                ScheduleGenerated(
                  schedule: schedule,
                  message:
                      'تم إنشاء جدول دراسي جديد بنجاح! (${schedule.sessions.length} جلسة)',
                ),
              );

              // Then emit ScheduleLoaded with today's sessions to display them
              final today = DateTime.now();
              final todaySessions = schedule.sessions.where((session) {
                return session.scheduledDate.year == today.year &&
                    session.scheduledDate.month == today.month &&
                    session.scheduledDate.day == today.day;
              }).toList();

              emit(ScheduleLoaded(sessions: todaySessions, date: today));

              // Schedule notifications for all generated sessions AFTER emitting
              if (settings.sessionReminders) {
                if (kDebugMode) print('[PlannerBloc] Scheduling notifications for ${schedule.sessions.length} sessions');
                // Don't await - fire and forget to avoid emit after completion
                sessionNotificationService.scheduleMultipleSessions(
                  schedule.sessions,
                  settings.reminderMinutesBefore,
                );
              }
            }
          },
        );
      },
    );
  }

  Future<void> _onLoadTodaysSchedule(
    LoadTodaysScheduleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Loading today\'s schedule...');
    emit(const PlannerLoading(message: 'جاري تحميل جدول اليوم...'));

    final result = await getTodaysSessionsUseCase(NoParams());

    // Handle result without using fold with async callback
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      if (kDebugMode) print('[PlannerBloc] Failed to load today\'s schedule: ${failure.message}');
      emit(
        PlannerError(
          message: 'فشل في تحميل جدول اليوم: ${failure.message}',
          failure: failure,
        ),
      );
      return;
    }

    // Success case
    final sessions = result.fold((l) => <StudySession>[], (r) => r);
    if (kDebugMode) print('[PlannerBloc] Loaded ${sessions.length} sessions for today');

    if (sessions.isEmpty) {
      // Check if there are any sessions at all (for better UX message)
      final allSessions = await localDataSource.getCachedSessions();

      if (allSessions.isEmpty) {
        // No schedule exists at all
        emit(
          const NoScheduleAvailable(
            message: 'لا يوجد جدول دراسي. قم بإنشاء جدول جديد.',
          ),
        );
      } else {
        // Schedule exists but no sessions for today - emit ScheduleLoaded with empty list
        emit(
          ScheduleLoaded(
            sessions: sessions,
            date: DateTime.now(),
            message: 'لا توجد جلسات لليوم',
          ),
        );
      }
    } else {
      emit(
        ScheduleLoaded(
          sessions: sessions,
          date: DateTime.now(),
          message: 'تم تحميل ${sessions.length} جلسة لليوم',
        ),
      );
    }
  }

  Future<void> _onLoadWeekSchedule(
    LoadWeekScheduleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري تحميل جدول الأسبوع...'));

    // Get the start of the current week (Saturday - السبت)
    final now = DateTime.now();
    // In Dart: Monday=1, ..., Saturday=6, Sunday=7
    // We want Saturday as first day
    final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceSaturday));

    final result = await getWeekSessionsUseCase(
      GetWeekSessionsParams(startDate: startOfWeek),
    );

    result.fold(
      (failure) => emit(
        PlannerError(
          message: 'فشل تحميل جدول الأسبوع: ${failure.message}',
          canRetry: true,
        ),
      ),
      (sessions) {
        if (sessions.isEmpty) {
          emit(const NoScheduleAvailable(
            message: 'لا توجد جلسات مجدولة لهذا الأسبوع.',
          ));
        } else {
          emit(
            WeekScheduleLoaded(
              sessions: sessions,
              weekStart: startOfWeek,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRefreshSchedule(
    RefreshScheduleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري تحديث الجدول...'));

    // Re-load today's schedule
    add(const LoadTodaysScheduleEvent());
  }

  /// Force refresh schedule from server (clears local cache)
  Future<void> _onForceRefreshFromServer(
    ForceRefreshFromServerEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) {
      print('[PlannerBloc] Force refreshing schedule from server...');
    }
    emit(const PlannerLoading(message: 'جاري تحديث الجدول من الخادم...'));

    if (plannerRepository == null) {
      emit(const PlannerError(
        message: 'خدمة الجدول غير متوفرة',
        canRetry: true,
      ));
      return;
    }

    final result = await plannerRepository!.forceRefreshFromServer();

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Force refresh failed: ${failure.message}');
        }
        emit(PlannerError(
          message: failure.message,
          failure: failure,
          canRetry: true,
        ));
      },
      (sessions) {
        if (kDebugMode) {
          print('[PlannerBloc] Force refresh successful: ${sessions.length} sessions for today');
        }

        if (sessions.isEmpty) {
          emit(const NoScheduleAvailable(
            message: 'لا توجد جلسات مجدولة على الخادم. قم بإنشاء جدول جديد.',
          ));
        } else {
          emit(ScheduleLoaded(
            sessions: sessions,
            date: DateTime.now(),
            message: 'تم تحديث الجدول من الخادم بنجاح (${sessions.length} جلسة)',
          ));
        }
      },
    );
  }

  // ==========================================================================
  // Session Action Handlers
  // ==========================================================================

  Future<void> _onStartSession(
    StartSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري بدء الجلسة...'));

    final result = await startSessionUseCase(event.sessionId);

    result.fold(
      (failure) {
        emit(
          PlannerError(
            message: 'فشل في بدء الجلسة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) async {
        // Reload today's schedule to reflect changes
        add(const LoadTodaysScheduleEvent());
      },
    );
  }

  Future<void> _onPauseSession(
    PauseSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري إيقاف الجلسة مؤقتاً...'));

    final result = await pauseSessionUseCase(event.sessionId);

    result.fold(
      (failure) {
        emit(
          PlannerError(
            message: 'فشل في إيقاف الجلسة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) async {
        // Reload today's schedule to reflect changes
        add(const LoadTodaysScheduleEvent());
      },
    );
  }

  Future<void> _onResumeSession(
    ResumeSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري استئناف الجلسة...'));

    final result = await resumeSessionUseCase(event.sessionId);

    result.fold(
      (failure) {
        emit(
          PlannerError(
            message: 'فشل في استئناف الجلسة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) async {
        // Reload today's schedule to reflect changes
        add(const LoadTodaysScheduleEvent());
      },
    );
  }

  Future<void> _onCompleteSession(
    CompleteSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري إتمام الجلسة...'));

    // Convert completionRate (0.0-1.0) to percentage (0-100) if provided
    final completionPercentage = event.completionRate != null
        ? (event.completionRate! * 100).toInt()
        : 100;

    final params = CompleteSessionParams(
      sessionId: event.sessionId,
      completionPercentage: completionPercentage,
      userNotes: event.userNotes,
      mood: event.mood,
    );

    final result = await completeSessionUseCase(params);

    result.fold(
      (failure) {
        emit(
          PlannerError(
            message: 'فشل في إتمام الجلسة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) {
        // Reload today's schedule to reflect changes
        add(const LoadTodaysScheduleEvent());

        // Cancel notification for completed session (fire and forget)
        sessionNotificationService.cancelSessionNotification(event.sessionId).then((_) {
          if (kDebugMode) print('[PlannerBloc] Cancelled notification for completed session ${event.sessionId}');
        });
      },
    );
  }

  Future<void> _onSkipSession(
    SkipSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري تخطي الجلسة...'));

    final params = SkipSessionParams(
      sessionId: event.sessionId,
      reason: event.reason,
    );

    final result = await skipSessionUseCase(params);

    result.fold(
      (failure) {
        emit(
          PlannerError(
            message: 'فشل في تخطي الجلسة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (_) {
        // Reload today's schedule to reflect changes
        add(const LoadTodaysScheduleEvent());

        // Cancel notification for skipped session (fire and forget)
        sessionNotificationService.cancelSessionNotification(event.sessionId).then((_) {
          if (kDebugMode) print('[PlannerBloc] Cancelled notification for skipped session ${event.sessionId}');
        });
      },
    );
  }

  Future<void> _onRescheduleSession(
    RescheduleSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري إعادة جدولة الجلسة...'));

    final result = await rescheduleSessionUseCase(
      RescheduleSessionParams(
        sessionId: event.sessionId,
        newDate: event.newDate,
      ),
    );

    result.fold(
      (failure) => emit(
        PlannerError(
          message: failure.message,
          canRetry: true,
        ),
      ),
      (_) async {
        // Fetch updated session
        final updatedSession = await localDataSource.getSession(event.sessionId);
        if (updatedSession != null) {
          emit(SessionRescheduled(
            session: updatedSession,
            newDate: event.newDate,
            message: 'تم إعادة جدولة الجلسة بنجاح',
          ));

          // Refresh current view to show updated session
          add(const RefreshScheduleEvent());

          // Reschedule notification for the updated session (fire and forget)
          getSettingsUseCase(NoParams()).then((settingsResult) {
            settingsResult.fold(
              (_) {},
              (settings) {
                if (settings.sessionReminders) {
                  sessionNotificationService.rescheduleSessionNotification(
                    updatedSession,
                    settings.reminderMinutesBefore,
                  ).then((_) {
                    if (kDebugMode) print('[PlannerBloc] Rescheduled notification for session ${event.sessionId}');
                  });
                }
              },
            );
          });
        } else {
          // Refresh current view anyway
          add(const RefreshScheduleEvent());
        }
      },
    );
  }

  Future<void> _onPinSession(
    PinSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final message = event.isPinned ? 'جاري تثبيت الجلسة...' : 'جاري إلغاء تثبيت الجلسة...';
    emit(PlannerLoading(message: message));

    final result = await pinSessionUseCase(
      PinSessionParams(
        sessionId: event.sessionId,
        isPinned: event.isPinned,
      ),
    );

    result.fold(
      (failure) => emit(
        PlannerError(
          message: failure.message,
          canRetry: true,
        ),
      ),
      (_) async {
        // Fetch updated session
        final updatedSession = await localDataSource.getSession(event.sessionId);
        if (updatedSession != null) {
          final successMessage = event.isPinned
              ? 'تم تثبيت الجلسة بنجاح'
              : 'تم إلغاء تثبيت الجلسة';
          emit(SessionPinned(
            session: updatedSession,
            isPinned: event.isPinned,
            message: successMessage,
          ));
        }
        // Refresh current view to show updated session
        add(const RefreshScheduleEvent());
      },
    );
  }

  // ==========================================================================
  // Sync & Cache Handlers
  // ==========================================================================

  Future<void> _onSyncOfflineChanges(
    SyncOfflineChangesEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري مزامنة التغييرات...'));

    final result = await triggerSyncUseCase(NoParams());

    result.fold(
      (failure) => emit(PlannerError(
        message: 'فشلت المزامنة: ${failure.message}',
        canRetry: true,
      )),
      (syncResult) {
        final totalSynced = syncResult.success;
        final failedCount = syncResult.failed;

        if (failedCount > 0) {
          emit(OfflineChangesSynced(
            syncedCount: totalSynced,
            message: 'تمت مزامنة $totalSynced عملية، فشل $failedCount',
          ));
        } else if (totalSynced > 0) {
          emit(OfflineChangesSynced(
            syncedCount: totalSynced,
            message: 'تم مزامنة $totalSynced عملية بنجاح',
          ));
        } else {
          emit(const OfflineChangesSynced(
            syncedCount: 0,
            message: 'لا توجد تغييرات للمزامنة',
          ));
        }
      },
    );
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري تنظيف ذاكرة التخزين المؤقت...'));

    try {
      await localDataSource.clearAllCache();
      if (kDebugMode) {
        print('[PlannerBloc] Cache cleared successfully');
      }
      emit(const CacheCleared(message: 'تم تنظيف ذاكرة التخزين المؤقت بنجاح'));

      // Emit NoScheduleAvailable since we cleared all sessions
      emit(const NoScheduleAvailable(
        message: 'تم مسح الكاش. قم بإنشاء جدول جديد.',
      ));
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerBloc] Failed to clear cache: $e');
      }
      emit(PlannerError(
        message: 'فشل في تنظيف ذاكرة التخزين المؤقت: ${e.toString()}',
        canRetry: true,
      ));
    }
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) {
      print('[PlannerBloc] Delete schedule requested');
    }
    emit(const PlannerLoading(message: 'جاري حذف الجدول...'));

    final result = await deleteAllSessionsUseCase(NoParams());

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] ✗ Delete schedule failed: ${failure.message}');
        }
        emit(
          PlannerError(
            message: 'فشل في حذف الجدول: ${failure.message}',
            failure: failure,
            canRetry: true,
          ),
        );
      },
      (_) async {
        if (kDebugMode) {
          print('[PlannerBloc] ✓ Schedule deleted successfully (local + API)');
        }
        // First emit ScheduleDeleted for the snackbar notification
        emit(const ScheduleDeleted(message: 'تم حذف الجدول بنجاح'));

        // Then immediately emit NoScheduleAvailable to update the UI
        // This ensures the UI shows empty state without relying on async chain
        emit(const NoScheduleAvailable(
          message: 'لا يوجد جدول دراسي. قم بإنشاء جدول جديد.',
        ));
      },
    );
  }

  Future<void> _onSaveSettings(
    SaveSettingsEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري حفظ الإعدادات...'));

    try {
      // Get current settings first to preserve other fields
      final currentSettingsResult = await getSettingsUseCase(NoParams());

      await currentSettingsResult.fold(
        (failure) async {
          emit(
            PlannerError(
              message: 'فشل في تحميل الإعدادات الحالية: ${failure.message}',
              failure: failure,
            ),
          );
        },
        (currentSettings) async {
          // Parse energy levels (convert from string to int)
          final morningEnergy = _parseEnergyLevel(event.morningEnergy);
          final afternoonEnergy = _parseEnergyLevel(event.afternoonEnergy);
          final eveningEnergy = _parseEnergyLevel(event.eveningEnergy);

          // Parse time strings to TimeOfDay
          final studyStartTime = _parseTimeString(event.studyStartTime);
          final studyEndTime = _parseTimeString(event.studyEndTime);

          // Calculate max study hours from daily goal
          final maxStudyHours = event.dailyGoalHours.ceil();

          // Create updated settings with new values
          final updatedSettings = currentSettings.copyWith(
            studyStartTime: studyStartTime,
            studyEndTime: studyEndTime,
            morningEnergyLevel: morningEnergy,
            afternoonEnergyLevel: afternoonEnergy,
            eveningEnergyLevel: eveningEnergy,
            usePomodoroTechnique: event.usePomodoro,
            pomodoroDurationMinutes:
                event.pomodoroWorkMinutes ??
                currentSettings.pomodoroDurationMinutes,
            shortBreakMinutes:
                event.pomodoroBreakMinutes ?? currentSettings.shortBreakMinutes,
            autoRescheduleEnabled: event.autoRescheduleMissed,
            maxStudyHoursPerDay: maxStudyHours,
          );

          // Update settings via use case
          final result = await updateSettingsUseCase(updatedSettings);

          result.fold(
            (failure) {
              emit(
                PlannerError(
                  message: 'فشل في حفظ الإعدادات: ${failure.message}',
                  failure: failure,
                ),
              );
            },
            (_) {
              emit(const SettingsSaved(message: 'تم حفظ الإعدادات بنجاح'));
            },
          );
        },
      );
    } catch (e) {
      emit(PlannerError(message: 'خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Parse energy level string to integer value
  int _parseEnergyLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
      case 'منخفض':
        return 3;
      case 'medium':
      case 'متوسط':
        return 6;
      case 'high':
      case 'عالي':
        return 9;
      default:
        return 6; // Default to medium
    }
  }

  /// Parse time string (HH:mm) to TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      // Default to 8:00 AM if parsing fails
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  // ==========================================================================
  // Session Lifecycle Handlers
  // ==========================================================================

  /// Check and mark past sessions as missed
  /// This should be called at app launch, when returning to foreground, and at midnight
  Future<void> _onCheckSessionLifecycle(
    CheckSessionLifecycleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Checking session lifecycle...');

    final result = await markPastSessionsMissedUseCase(
      const MarkPastSessionsMissedParams(),
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Failed to check session lifecycle: ${failure.message}');
        }
        // Silent failure - don't show error to user for background operation
      },
      (missedSessions) async {
        if (kDebugMode) {
          print('[PlannerBloc] Marked ${missedSessions.length} sessions as missed');
        }

        if (missedSessions.isNotEmpty) {
          // Emit state to notify UI about missed sessions
          emit(
            SessionsMarkedMissed(
              missedSessions: missedSessions,
              count: missedSessions.length,
              message: 'تم تحديث ${missedSessions.length} جلسة كـ"فائتة"',
            ),
          );

          // Reload today's schedule to reflect changes
          add(const LoadTodaysScheduleEvent());
        }
      },
    );
  }

  /// Reschedule a missed session to the next available slot
  Future<void> _onRescheduleMissedSession(
    RescheduleMissedSessionEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading(message: 'جاري إعادة جدولة الجلسة...'));

    // Get the session first
    final session = await localDataSource.getSession(event.sessionId);
    if (session == null) {
      emit(const PlannerError(
        message: 'لم يتم العثور على الجلسة',
        canRetry: false,
      ));
      return;
    }

    if (session.status != SessionStatus.missed) {
      emit(const PlannerError(
        message: 'يمكن إعادة جدولة الجلسات الفائتة فقط',
        canRetry: false,
      ));
      return;
    }

    final result = await rescheduleMissedSessionUseCase(
      RescheduleMissedSessionParams(missedSession: session),
    );

    await result.fold(
      (failure) async {
        emit(
          PlannerError(
            message: 'فشل في إعادة جدولة الجلسة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (newSession) async {
        if (newSession != null) {
          // Sync reschedule to API using the repository's rescheduleSession method
          // This will update the session on the server with the new date and times
          if (plannerRepository != null) {
            final syncResult = await plannerRepository!.rescheduleSession(
              event.sessionId,
              newSession.scheduledDate,
            );
            syncResult.fold(
              (failure) {
                if (kDebugMode) {
                  print('[PlannerBloc] Failed to sync reschedule to API: ${failure.message}');
                }
                // Continue anyway - local changes are saved
              },
              (_) {
                if (kDebugMode) {
                  print('[PlannerBloc] Reschedule synced to API successfully');
                }
              },
            );
          }

          emit(
            MissedSessionRescheduled(
              originalSession: session,
              newSession: newSession,
              message: 'تم إعادة جدولة الجلسة بنجاح',
            ),
          );

          // Reload today's schedule to reflect changes
          add(const LoadTodaysScheduleEvent());
        } else {
          emit(
            MissedSessionRescheduleFailed(
              session: session,
              message: 'لا توجد فترة متاحة لإعادة جدولة هذه الجلسة',
            ),
          );
        }
      },
    );
  }

  /// Load all missed sessions
  Future<void> _onLoadMissedSessions(
    LoadMissedSessionsEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Loading missed sessions...');

    final result = await getMissedSessionsUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(
          PlannerError(
            message: 'فشل في تحميل الجلسات الفائتة: ${failure.message}',
            failure: failure,
          ),
        );
      },
      (missedSessions) {
        if (kDebugMode) {
          print('[PlannerBloc] Loaded ${missedSessions.length} missed sessions');
        }
        emit(MissedSessionsLoaded(missedSessions: missedSessions));
      },
    );
  }

  /// Load overdue sessions (past start time but not yet missed)
  Future<void> _onLoadOverdueSessions(
    LoadOverdueSessionsEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Loading overdue sessions...');

    final result = await getOverdueSessionsUseCase(const NoParams());

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Failed to load overdue sessions: ${failure.message}');
        }
        // Silent failure for background operation
      },
      (overdueSessions) {
        if (kDebugMode) {
          print('[PlannerBloc] Loaded ${overdueSessions.length} overdue sessions');
        }
        emit(OverdueSessionsLoaded(overdueSessions: overdueSessions));
      },
    );
  }

  // ==========================================================================
  // Full Schedule Handlers
  // ==========================================================================

  /// Load all sessions for full schedule view
  Future<void> _onLoadFullSchedule(
    LoadFullScheduleEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Loading full schedule...');
    emit(const PlannerLoading(message: 'جاري تحميل الجدول الكامل...'));

    try {
      final allSessions = await localDataSource.getCachedSessions();

      if (kDebugMode) {
        print('[PlannerBloc] Loaded ${allSessions.length} total sessions');
      }

      if (allSessions.isEmpty) {
        emit(const NoScheduleAvailable(
          message: 'لا توجد جلسات مجدولة. قم بإنشاء جدول جديد.',
        ));
        return;
      }

      // Sort sessions by scheduled date
      allSessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      final startDate = allSessions.first.scheduledDate;
      final endDate = allSessions.last.scheduledDate;

      emit(FullScheduleLoaded(
        sessions: allSessions,
        startDate: startDate,
        endDate: endDate,
        message: 'تم تحميل ${allSessions.length} جلسة',
      ));
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerBloc] Error loading full schedule: $e');
      }
      emit(PlannerError(
        message: 'فشل في تحميل الجدول الكامل: ${e.toString()}',
      ));
    }
  }

  /// Load sessions for a specific date
  Future<void> _onLoadSessionsForDate(
    LoadSessionsForDateEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Loading sessions for date: ${event.date}');
    emit(const PlannerLoading(message: 'جاري تحميل الجلسات...'));

    try {
      final allSessions = await localDataSource.getCachedSessions();

      final dateSessions = allSessions.where((session) {
        final sessionDate = session.scheduledDate;
        return sessionDate.year == event.date.year &&
            sessionDate.month == event.date.month &&
            sessionDate.day == event.date.day;
      }).toList();

      // Sort by scheduled start time
      dateSessions.sort((a, b) =>
        (a.scheduledStartTime.hour * 60 + a.scheduledStartTime.minute)
            .compareTo(b.scheduledStartTime.hour * 60 + b.scheduledStartTime.minute));

      if (kDebugMode) {
        print('[PlannerBloc] Found ${dateSessions.length} sessions for ${event.date}');
      }

      emit(ScheduleLoaded(
        sessions: dateSessions,
        date: event.date,
        message: 'تم تحميل ${dateSessions.length} جلسة',
      ));
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerBloc] Error loading sessions for date: $e');
      }
      emit(PlannerError(
        message: 'فشل في تحميل الجلسات: ${e.toString()}',
      ));
    }
  }

  // ==========================================================================
  // Adaptation Handlers
  // ==========================================================================

  /// Trigger schedule adaptation based on performance
  Future<void> _onTriggerAdaptation(
    TriggerAdaptationEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (kDebugMode) print('[PlannerBloc] Triggering schedule adaptation...');
    emit(const AdaptationInProgress());

    final result = await triggerAdaptationUseCase(NoParams());

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Adaptation failed: ${failure.message}');
        }
        emit(PlannerError(
          message: 'فشل في تكييف الجدول: ${failure.message}',
          failure: failure,
          canRetry: true,
        ));
      },
      (adaptationResult) async {
        if (kDebugMode) {
          print('[PlannerBloc] Adaptation completed: ${adaptationResult.sessionsAffected} sessions affected');
        }
        emit(AdaptationCompleted(
          result: adaptationResult,
          message: adaptationResult.message,
        ));

        // Reload today's schedule to reflect any changes
        if (adaptationResult.sessionsAffected > 0) {
          add(const LoadTodaysScheduleEvent());
        }
      },
    );
  }

  // ==========================================================================
  // Session Content Handlers (Curriculum Integration)
  // ==========================================================================

  /// Load content items for a study session
  Future<void> _onLoadSessionContent(
    LoadSessionContentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (plannerRepository == null) {
      emit(const SessionContentError(message: 'خدمة المحتوى غير متوفرة'));
      return;
    }

    if (kDebugMode) {
      print('[PlannerBloc] Loading session content for subject: ${event.subjectId}, type: ${event.sessionType}, contentId: ${event.contentId}');
    }

    // If contentId is null, don't load content from API
    // This prevents loading all content for a subject when we don't have a specific unit
    // The session should show "سيتم اضافة المحتوى قريبا" instead
    if (event.contentId == null) {
      if (kDebugMode) {
        print('[PlannerBloc] No contentId provided - session has no specific content assigned');
        print('[PlannerBloc] User should use "Force Refresh from Server" to get updated sessions with content IDs');
      }
      // Return empty content with placeholder message
      emit(SessionContentLoaded(
        contents: const [],
        meta: SessionContentMeta(
          sessionType: event.sessionType,
          phaseToComplete: _getPhaseFromSessionType(event.sessionType),
          totalAvailable: 0,
          hasContent: false,
          placeholderMessage: 'سيتم اضافة المحتوى قريبا',
        ),
      ));
      return;
    }

    emit(const SessionContentLoading());

    final result = await plannerRepository!.getNextSessionContent(
      subjectId: event.subjectId,
      sessionType: event.sessionType,
      durationMinutes: event.durationMinutes,
      limit: event.limit,
      contentId: event.contentId, // Pass specific content ID to filter
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Failed to load session content: ${failure.message}');
        }
        emit(SessionContentError(message: failure.message));
      },
      (data) {
        final (contents, meta) = data;
        if (kDebugMode) {
          print('[PlannerBloc] Loaded ${contents.length} content items for session');
        }
        emit(SessionContentLoaded(contents: contents, meta: meta));
      },
    );
  }

  /// Helper to convert session type to phase
  String _getPhaseFromSessionType(String sessionType) {
    return switch (sessionType) {
      'study' => 'understanding',
      'revision' => 'review',
      'practice' => 'theory_practice',
      'exam' => 'exercise_practice',
      _ => 'understanding',
    };
  }

  /// Mark a single content phase as complete
  Future<void> _onMarkContentPhaseComplete(
    MarkContentPhaseCompleteEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (plannerRepository == null) {
      emit(const SessionContentError(message: 'خدمة المحتوى غير متوفرة'));
      return;
    }

    if (kDebugMode) {
      print('[PlannerBloc] Marking content ${event.contentId} phase ${event.phase} as complete');
    }

    final result = await plannerRepository!.markContentPhaseComplete(
      contentId: event.contentId,
      phase: event.phase,
      durationMinutes: event.durationMinutes,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Failed to mark content phase: ${failure.message}');
        }
        emit(SessionContentError(message: failure.message));
      },
      (_) {
        if (kDebugMode) {
          print('[PlannerBloc] Content phase marked successfully');
        }
        emit(ContentPhaseMarked(
          contentId: event.contentId,
          phase: event.phase,
        ));
      },
    );
  }

  /// Mark multiple content items' phases as complete (used when completing a session)
  Future<void> _onMarkSessionContentComplete(
    MarkSessionContentCompleteEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (plannerRepository == null) {
      if (kDebugMode) {
        print('[PlannerBloc] Repository not available for marking content complete');
      }
      return; // Silently fail - content marking is optional
    }

    if (event.contentIds.isEmpty) {
      if (kDebugMode) {
        print('[PlannerBloc] No content IDs to mark as complete');
      }
      return;
    }

    if (kDebugMode) {
      print('[PlannerBloc] Marking ${event.contentIds.length} content items phase ${event.phaseToMark} as complete');
    }

    final result = await plannerRepository!.markMultipleContentPhasesComplete(
      contentIds: event.contentIds,
      phase: event.phaseToMark,
      durationMinutes: event.totalDurationMinutes,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[PlannerBloc] Failed to mark session content: ${failure.message}');
        }
        // Don't emit error - this is a background operation
      },
      (_) {
        if (kDebugMode) {
          print('[PlannerBloc] Session content marked complete successfully');
        }
        emit(SessionContentMarkedComplete(
          contentCount: event.contentIds.length,
          phase: event.phaseToMark,
        ));
      },
    );
  }
}
