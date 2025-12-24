import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/planner_settings.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/prioritized_subject.dart';
import '../../domain/entities/centralized_subject.dart';
import '../../domain/entities/planner_analytics.dart';
import '../../domain/entities/session_history.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/points_history.dart';
import '../../domain/entities/session_content.dart';
import '../../domain/usecases/trigger_adaptation.dart';
import '../../domain/usecases/record_exam_result.dart';
import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_local_datasource.dart';
import '../datasources/planner_remote_datasource.dart';
import '../datasources/planner_sync_queue.dart';
import '../models/planner_analytics_model.dart';
import '../models/session_history_model.dart';
import '../models/sync_queue_item.dart';
import '../services/priority_calculator.dart';
import '../services/prayer_times_service.dart';

/// Implementation of PlannerRepository
///
/// Implements offline-first strategy:
/// 1. Read from local cache first
/// 2. If online, fetch from remote and update cache
/// 3. Write to local immediately, sync to remote in background
class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerLocalDataSource localDataSource;
  final PlannerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final PriorityCalculator priorityCalculator;
  final PrayerTimesService prayerTimesService;
  final AuthLocalDataSource authLocalDataSource;
  final PlannerSyncQueue syncQueue;

  PlannerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.priorityCalculator,
    required this.prayerTimesService,
    required this.authLocalDataSource,
    required this.syncQueue,
  });

  /// Get current authenticated user ID, returns null if not authenticated
  Future<String?> _getCurrentUserId() async {
    try {
      final user = await authLocalDataSource.getCachedUser();
      return user.id.toString();
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerRepository] Failed to get current user ID: $e');
      }
      return null;
    }
  }

  /// Helper method to queue session actions for sync
  Future<void> _queueSessionAction({
    required String sessionId,
    required String actionType,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{'sessionId': sessionId};
    if (additionalData != null) {
      data.addAll(<String, dynamic>{...additionalData});
    }

    await syncQueue.addToQueue(SyncQueueItem.create(
      operation: SyncOperation.action,
      entityType: SyncEntityType.session,
      data: data,
      actionType: actionType,
    ));
  }

  @override
  Future<Either<Failure, Schedule>> generateSchedule({
    required PlannerSettings settings,
    required List<Subject> subjects,
    required List<Exam> exams,
    required DateTime startDate,
    required DateTime endDate,
    bool startFromNow = true,
    ScheduleType scheduleType = ScheduleType.weekly,
    List<String>? selectedSubjectIds,
  }) async {
    try {
      // Clear ALL sessions before generating new schedule to prevent old data showing in UI
      await localDataSource.clearAllSessions();

      if (kDebugMode) {
        print('[Repository] Generating schedule from $startDate to $endDate');
        print('[Repository] scheduleType: ${scheduleType.name}');
        print('[Repository] selectedSubjectIds: $selectedSubjectIds');
      }

      Schedule schedule;

      // Always use API for schedule generation (has real subject_planner_content)
      // No local fallback - API is required for proper content linking
      if (!await networkInfo.isConnected) {
        if (kDebugMode) {
          print('[Repository] Offline - cannot generate schedule without API');
        }
        throw ServerException(message: 'يجب الاتصال بالإنترنت لإنشاء الجدول الدراسي');
      }

      if (kDebugMode) {
        print('[Repository] Online - generating schedule from API with real content...');
      }
      final subjectIds = subjects.map((s) => s.id).toList();
      schedule = await remoteDataSource.generateSchedule(
        userId: settings.userId,
        subjectIds: subjectIds,
        startDate: startDate,
        endDate: endDate,
      );
      if (kDebugMode) {
        print('[Repository] API schedule generated with ${schedule.sessions.length} sessions (with content)');
      }

      if (kDebugMode) {
        print('[Repository] Schedule generated with ${schedule.sessions.length} sessions');
      }

      // Cache schedule locally
      await localDataSource.cacheSchedule(schedule);

      // Cache all sessions with timestamp metadata
      final now = DateTime.now();
      for (final session in schedule.sessions) {
        final cachedSession = session.copyWith(
          cachedAt: now,
          lastSyncedAt: now,
          isDirty: false,
        );
        await localDataSource.cacheSession(cachedSession);
      }

      if (kDebugMode) {
        print('[Repository] All ${schedule.sessions.length} sessions cached with timestamp');
      }

      // Force flush all cached data to disk to ensure it's immediately available
      await localDataSource.flushSessions();
      if (kDebugMode) {
        print('[Repository] All sessions flushed to disk');
      }

      return Right(schedule);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getTodaysSessions() async {
    try {
      // PRIORITY: Always use locally generated schedule if it exists
      // The local schedule respects user's selectedSubjectIds filter
      // API sessions may contain ALL subjects, not just selected ones
      final localSessions = await localDataSource.getTodaysSessions();

      if (kDebugMode) {
        print('[Repository] getTodaysSessions - Found ${localSessions.length} sessions in local cache');
        for (final s in localSessions) {
          print('[Repository]   - ${s.subjectName} (isBreak: ${s.isBreak})');
        }
      }

      // If we have local sessions, ALWAYS return them (they are the source of truth)
      if (localSessions.isNotEmpty) {
        if (kDebugMode) {
          print('[Repository] ✓ Returning ${localSessions.length} sessions from local schedule');
        }
        return Right(localSessions);
      }

      // ONLY fetch from API if there are NO local sessions at all
      if (await networkInfo.isConnected) {
        try {
          if (kDebugMode) {
            print('[Repository] No local schedule found, fetching from API...');
          }

          final userId = await _getCurrentUserId();
          if (userId != null) {
            final remoteSessions = await remoteDataSource.fetchTodaysSessions(userId);

            // Step 4: Mark as cached with timestamp and store in Hive
            final now = DateTime.now();
            final cachedSessions = <StudySession>[];

            for (final session in remoteSessions) {
              final cachedSession = session.copyWith(
                cachedAt: now,
                lastSyncedAt: now,
                isDirty: false,
              );
              await localDataSource.cacheSession(cachedSession);
              cachedSessions.add(cachedSession);
            }

            if (kDebugMode) {
              print('[Repository] ✓ Cached ${cachedSessions.length} fresh sessions from API');
            }

            return Right(cachedSessions);
          }
        } catch (e) {
          if (kDebugMode) {
            print('[Repository] ✗ API fetch failed: $e');
          }
          // API failed - fall through to return stale cache if available
        }
      }

      // Step 5: Offline or API failed - return stale cache if available
      if (localSessions.isNotEmpty) {
        if (kDebugMode) {
          print('[Repository] ⚠ Returning ${localSessions.length} sessions from stale cache (offline)');
        }
        return Right(localSessions);
      }

      // No cache and offline - return empty list
      if (kDebugMode) {
        print('[Repository] ✗ No cache available and offline - returning empty list');
      }
      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getWeekSessions(
    DateTime startDate,
  ) async {
    try {
      // Calculate end date (7 days from start)
      final endDate = startDate.add(const Duration(days: 7));

      // PRIORITY: Always use locally generated schedule if it exists
      // The local schedule respects user's selectedSubjectIds filter
      final localSessions = await localDataSource.getSessionsInRange(
        startDate,
        endDate,
      );

      if (kDebugMode) {
        print('[Repository] getWeekSessions - Found ${localSessions.length} sessions in local cache');
      }

      // If we have local sessions, ALWAYS return them (they are the source of truth)
      if (localSessions.isNotEmpty) {
        if (kDebugMode) {
          print('[Repository] ✓ Returning ${localSessions.length} week sessions from local schedule');
        }
        return Right(localSessions);
      }

      // ONLY fetch from API if there are NO local sessions at all
      if (await networkInfo.isConnected) {
        try {
          if (kDebugMode) {
            print('[Repository] No local schedule found, fetching week data from API...');
          }

          final userId = await _getCurrentUserId();
          if (userId != null) {
            final remoteSessions = await remoteDataSource.fetchSessionsInRange(
              userId,
              startDate,
              endDate,
            );

            // Step 4: Mark as cached with timestamp and store in Hive
            final now = DateTime.now();
            final cachedSessions = <StudySession>[];

            for (final session in remoteSessions) {
              final cachedSession = session.copyWith(
                cachedAt: now,
                lastSyncedAt: now,
                isDirty: false,
              );
              await localDataSource.cacheSession(cachedSession);
              cachedSessions.add(cachedSession);
            }

            if (kDebugMode) {
              print('[Repository] ✓ Cached ${cachedSessions.length} fresh week sessions from API');
            }

            return Right(cachedSessions);
          }
        } catch (e) {
          if (kDebugMode) {
            print('[Repository] ✗ API fetch failed: $e');
          }
          // API failed - fall through to return stale cache if available
        }
      }

      // Step 5: Offline or API failed - return stale cache if available
      if (localSessions.isNotEmpty) {
        if (kDebugMode) {
          print('[Repository] ⚠ Returning ${localSessions.length} week sessions from stale cache (offline)');
        }
        return Right(localSessions);
      }

      // No cache and offline - return empty list
      if (kDebugMode) {
        print('[Repository] ✗ No cache available and offline - returning empty list');
      }
      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getAllUpcomingSessions() async {
    try {
      // Get next 30 days of sessions
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 30));

      // PRIORITY: Always use locally generated schedule if it exists
      // The local schedule respects user's selectedSubjectIds filter
      final localSessions = await localDataSource.getSessionsInRange(
        startDate,
        endDate,
      );

      if (kDebugMode) {
        print('[Repository] getAllUpcomingSessions - Found ${localSessions.length} sessions in local cache');
      }

      // If we have local sessions, ALWAYS return them (they are the source of truth)
      if (localSessions.isNotEmpty) {
        if (kDebugMode) {
          print('[Repository] ✓ Returning ${localSessions.length} upcoming sessions from local schedule');
        }
        return Right(localSessions);
      }

      // ONLY fetch from API if there are NO local sessions at all
      if (await networkInfo.isConnected) {
        try {
          if (kDebugMode) {
            print('[Repository] No local schedule found, fetching upcoming data from API...');
          }

          final userId = await _getCurrentUserId();
          if (userId != null) {
            final remoteSessions = await remoteDataSource.fetchSessionsInRange(
              userId,
              startDate,
              endDate,
            );

            // Step 4: Mark as cached with timestamp and store in Hive
            final now = DateTime.now();
            final cachedSessions = <StudySession>[];

            for (final session in remoteSessions) {
              final cachedSession = session.copyWith(
                cachedAt: now,
                lastSyncedAt: now,
                isDirty: false,
              );
              await localDataSource.cacheSession(cachedSession);
              cachedSessions.add(cachedSession);
            }

            if (kDebugMode) {
              print('[Repository] ✓ Cached ${cachedSessions.length} fresh upcoming sessions from API');
            }

            return Right(cachedSessions);
          }
        } catch (e) {
          if (kDebugMode) {
            print('[Repository] ✗ API fetch failed: $e');
          }
          // API failed - fall through to return stale cache if available
        }
      }

      // Step 5: Offline or API failed - return stale cache if available
      if (localSessions.isNotEmpty) {
        if (kDebugMode) {
          print('[Repository] ⚠ Returning ${localSessions.length} upcoming sessions from stale cache (offline)');
        }
        return Right(localSessions);
      }

      // No cache and offline - return empty list
      if (kDebugMode) {
        print('[Repository] ✗ No cache available and offline - returning empty list');
      }
      return const Right([]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> startSession(String sessionId) async {
    try {
      // Get session from local
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Update session status locally and mark as dirty
      final updatedSession = session.copyWith(
        status: SessionStatus.inProgress,
        actualStartTime: DateTime.now(),
        isDirty: true, // Mark as having unsaved changes
      );
      await localDataSource.updateSession(updatedSession);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.startSession(sessionId);

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = updatedSession.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);
        } on ServerException catch (e) {
          // If session doesn't exist on server (404), that's okay for local-only sessions
          if (!e.message.contains('not found')) {
            // For other errors, queue for later sync
            await _queueSessionAction(sessionId: sessionId, actionType: 'start');
          }
        } catch (e) {
          // Queue for later sync
          await _queueSessionAction(sessionId: sessionId, actionType: 'start');
        }
      } else {
        // Offline: queue for later sync
        await _queueSessionAction(sessionId: sessionId, actionType: 'start');
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> pauseSession(String sessionId) async {
    try {
      // Get session from local
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Update session status to paused and mark as dirty
      final updatedSession = session.copyWith(
        status: SessionStatus.paused,
        isDirty: true, // Mark as having unsaved changes
      );
      await localDataSource.updateSession(updatedSession);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.pauseSession(sessionId);

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = updatedSession.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);
        } on ServerException catch (e) {
          // If session doesn't exist on server (404), that's okay for local-only sessions
          if (!e.message.contains('not found')) {
            await _queueSessionAction(sessionId: sessionId, actionType: 'pause');
          }
        } catch (e) {
          await _queueSessionAction(sessionId: sessionId, actionType: 'pause');
        }
      } else {
        await _queueSessionAction(sessionId: sessionId, actionType: 'pause');
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resumeSession(String sessionId) async {
    try {
      // Get session from local
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Update session status to in progress and mark as dirty
      final updatedSession = session.copyWith(
        status: SessionStatus.inProgress,
        isDirty: true, // Mark as having unsaved changes
      );
      await localDataSource.updateSession(updatedSession);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.resumeSession(sessionId);

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = updatedSession.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);
        } on ServerException catch (e) {
          // If session doesn't exist on server (404), that's okay for local-only sessions
          if (!e.message.contains('not found')) {
            await _queueSessionAction(sessionId: sessionId, actionType: 'resume');
          }
        } catch (e) {
          await _queueSessionAction(sessionId: sessionId, actionType: 'resume');
        }
      } else {
        await _queueSessionAction(sessionId: sessionId, actionType: 'resume');
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeSession(
    String sessionId, {
    required int completionPercentage,
    String? userNotes,
    String? mood,
  }) async {
    try {
      // Get session from local
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Update session status locally and mark as dirty
      final updatedSession = session.copyWith(
        status: SessionStatus.completed,
        actualEndTime: DateTime.now(),
        completionPercentage: completionPercentage,
        userNotes: userNotes,
        isDirty: true, // Mark as having unsaved changes
      );
      await localDataSource.updateSession(updatedSession);

      // Update subject progress
      final subject = await localDataSource.getSubject(session.subjectId);
      if (subject != null) {
        final sessionDuration = updatedSession.duration.inMinutes;
        final updatedSubject = subject.copyWith(
          totalStudyMinutes: subject.totalStudyMinutes + sessionDuration,
          lastStudiedDate: DateTime.now(),
        );
        await localDataSource.updateSubject(updatedSubject);
      }

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.completeSession(
            sessionId,
            completionPercentage,
            userNotes,
            mood,
          );

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = updatedSession.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);
        } on ServerException catch (e) {
          // If session doesn't exist on server (404), that's okay for local-only sessions
          if (!e.message.contains('not found')) {
            await _queueSessionAction(
              sessionId: sessionId,
              actionType: 'complete',
              additionalData: {
                'completionPercentage': completionPercentage,
                if (userNotes != null) 'userNotes': userNotes,
                if (mood != null) 'mood': mood,
              },
            );
          }
        } catch (e) {
          await _queueSessionAction(
            sessionId: sessionId,
            actionType: 'complete',
            additionalData: {
              'completionPercentage': completionPercentage,
              if (userNotes != null) 'userNotes': userNotes,
              if (mood != null) 'mood': mood,
            },
          );
        }
      } else {
        await _queueSessionAction(
          sessionId: sessionId,
          actionType: 'complete',
          additionalData: {
            'completionPercentage': completionPercentage,
            if (userNotes != null) 'userNotes': userNotes,
            if (mood != null) 'mood': mood,
          },
        );
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> skipSession(
    String sessionId,
    String reason,
  ) async {
    try {
      // Get session from local
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Update session status locally and mark as dirty
      final updatedSession = session.copyWith(
        status: SessionStatus.skipped,
        userNotes: reason,
        isDirty: true, // Mark as having unsaved changes
      );
      await localDataSource.updateSession(updatedSession);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.skipSession(sessionId, reason);

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = updatedSession.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);
        } on ServerException catch (e) {
          // If session doesn't exist on server (404), that's okay for local-only sessions
          // like breaks that are generated locally
          if (!e.message.contains('not found')) {
            await _queueSessionAction(
              sessionId: sessionId,
              actionType: 'skip',
              additionalData: {'reason': reason},
            );
          }
        } catch (e) {
          await _queueSessionAction(
            sessionId: sessionId,
            actionType: 'skip',
            additionalData: {'reason': reason},
          );
        }
      } else {
        await _queueSessionAction(
          sessionId: sessionId,
          actionType: 'skip',
          additionalData: {'reason': reason},
        );
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> rescheduleSession(
    String sessionId,
    DateTime newDate,
  ) async {
    try {
      // Get session from local - it should already be updated by the use case
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Use the session's already updated times (set by SessionLifecycleService)
      final startTime = session.scheduledStartTime;
      final endTime = session.scheduledEndTime;

      // Sync to remote if online using the dedicated reschedule endpoint
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.rescheduleSession(
            sessionId,
            session.scheduledDate,
            startTime,
            endTime,
          );

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = session.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);

          if (kDebugMode) {
            print('[PlannerRepository] Session $sessionId rescheduled successfully via API');
          }
        } on ServerException catch (e) {
          if (kDebugMode) {
            print('[PlannerRepository] Failed to reschedule via API: ${e.message}');
          }
          // Queue for later sync
          await _queueSessionAction(
            sessionId: sessionId,
            actionType: 'reschedule',
            additionalData: {
              'newDate': session.scheduledDate.toIso8601String(),
              'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
            },
          );
        } catch (e) {
          if (kDebugMode) {
            print('[PlannerRepository] Error rescheduling via API: $e');
          }
          await _queueSessionAction(
            sessionId: sessionId,
            actionType: 'reschedule',
            additionalData: {
              'newDate': session.scheduledDate.toIso8601String(),
              'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
            },
          );
        }
      } else {
        // Offline - queue for later sync
        await _queueSessionAction(
          sessionId: sessionId,
          actionType: 'reschedule',
          additionalData: {
            'newDate': session.scheduledDate.toIso8601String(),
            'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
            'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          },
        );
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> pinSession(
    String sessionId,
    bool isPinned,
  ) async {
    try {
      // Get session from local
      final session = await localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(CacheFailure('Session not found'));
      }

      // Update pin status locally and mark as dirty
      final updatedSession = session.copyWith(
        isPinned: isPinned,
        isDirty: true, // Mark as having unsaved changes
      );
      await localDataSource.updateSession(updatedSession);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateSession(updatedSession);

          // Successfully synced - mark as clean and update sync timestamp
          final syncedSession = updatedSession.copyWith(
            isDirty: false,
            lastSyncedAt: DateTime.now(),
          );
          await localDataSource.updateSession(syncedSession);
        } on ServerException catch (e) {
          // If session doesn't exist on server (404), that's okay for local-only sessions
          if (!e.message.contains('not found')) {
            await _queueSessionAction(
              sessionId: sessionId,
              actionType: 'pin',
              additionalData: {'isPinned': isPinned},
            );
          }
        } catch (e) {
          await _queueSessionAction(
            sessionId: sessionId,
            actionType: 'pin',
            additionalData: {'isPinned': isPinned},
          );
        }
      } else {
        await _queueSessionAction(
          sessionId: sessionId,
          actionType: 'pin',
          additionalData: {'isPinned': isPinned},
        );
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> forceRefreshFromServer() async {
    debugPrint('[Repository] ========== FORCE REFRESH FROM SERVER START ==========');
    try {
      // Step 1: Check network connectivity
      if (!await networkInfo.isConnected) {
        debugPrint('[Repository] ✗ No network connection');
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت. يرجى الاتصال بالإنترنت والمحاولة مرة أخرى.'));
      }

      // Step 2: Get user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        debugPrint('[Repository] ✗ No user ID found');
        return Left(ServerFailure('فشل في تحديد هوية المستخدم'));
      }

      debugPrint('[Repository] User ID: $userId');

      // Step 3: Clear all local sessions cache
      debugPrint('[Repository] Clearing local cache...');
      await localDataSource.clearAllSessions();
      debugPrint('[Repository] ✓ Local cache cleared');

      // Step 4: Fetch fresh sessions from API for next 30 days
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(const Duration(days: 30));

      debugPrint('[Repository] Fetching sessions from API: $startDate to $endDate');
      final remoteSessions = await remoteDataSource.fetchSessionsInRange(
        userId,
        startDate,
        endDate,
      );
      debugPrint('[Repository] ✓ Fetched ${remoteSessions.length} sessions from API');

      // Step 5: Cache all fetched sessions locally
      final cachedSessions = <StudySession>[];
      for (final session in remoteSessions) {
        final cachedSession = session.copyWith(
          cachedAt: now,
          lastSyncedAt: now,
          isDirty: false,
        );
        await localDataSource.cacheSession(cachedSession);
        cachedSessions.add(cachedSession);
      }

      // Step 6: Flush to disk
      await localDataSource.flushSessions();
      debugPrint('[Repository] ✓ Cached and flushed ${cachedSessions.length} sessions');

      // Step 7: Return today's sessions
      final todaySessions = cachedSessions.where((session) {
        final sessionDate = session.scheduledDate;
        return sessionDate.year == now.year &&
            sessionDate.month == now.month &&
            sessionDate.day == now.day;
      }).toList();

      debugPrint('[Repository] ✓ Returning ${todaySessions.length} sessions for today');
      debugPrint('[Repository] ========== FORCE REFRESH FROM SERVER COMPLETE ==========');
      return Right(todaySessions);
    } on ServerException catch (e) {
      debugPrint('[Repository] ✗ ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[Repository] ✗ Unexpected error: $e');
      debugPrint('[Repository] Stack trace: $stackTrace');
      return Left(ServerFailure('فشل في تحديث الجدول من الخادم: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllSessions() async {
    debugPrint('[Repository] ========== DELETE ALL SESSIONS START ==========');
    try {
      // Check network status
      final isOnline = await networkInfo.isConnected;
      debugPrint('[Repository] Network status: ${isOnline ? "ONLINE ✓" : "OFFLINE ✗"}');

      // FIRST: Delete from remote API if online
      if (isOnline) {
        try {
          debugPrint('[Repository] 🌐 Calling API: remoteDataSource.deleteAllSessions()...');
          await remoteDataSource.deleteAllSessions();
          debugPrint('[Repository] ✓ API DELETE SUCCESS - Sessions removed from database tables:');
          debugPrint('[Repository]   - planner_study_sessions');
          debugPrint('[Repository]   - planner_schedules');
        } catch (e, stackTrace) {
          debugPrint('[Repository] ✗ API DELETE FAILED: $e');
          debugPrint('[Repository] Stack trace: $stackTrace');
          debugPrint('[Repository] ⚠ Continuing to clear local cache despite API error...');
          // Continue to clear local even if remote fails
        }
      } else {
        debugPrint('[Repository] ⚠ OFFLINE - Skipping API delete (will only clear local cache)');
      }

      // SECOND: Clear all sessions from local storage
      debugPrint('[Repository] 💾 Calling localDataSource.clearAllSessions()...');
      await localDataSource.clearAllSessions();
      debugPrint('[Repository] ✓ LOCAL CACHE CLEARED - All Hive boxes emptied');

      debugPrint('[Repository] ========== DELETE ALL SESSIONS COMPLETE ==========');
      return const Right(unit);
    } on CacheException catch (e) {
      debugPrint('[Repository] ✗ CacheException: ${e.message}');
      debugPrint('[Repository] ========== DELETE ALL SESSIONS FAILED ==========');
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[Repository] ✗ Unexpected error: $e');
      debugPrint('[Repository] Stack trace: $stackTrace');
      debugPrint('[Repository] ========== DELETE ALL SESSIONS FAILED ==========');
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlannerSettings>> getSettings() async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();
      final userIdKey = userId ?? 'default_user';

      // Try local first
      final settings = await localDataSource.getCachedSettings(userIdKey);

      if (settings != null) {
        // If online, sync with remote in background
        if (await networkInfo.isConnected && userId != null) {
          _syncSettingsInBackground(userId);
        }
        return Right(settings);
      }

      // If no local cache, try fetch from remote
      if (await networkInfo.isConnected && userId != null) {
        try {
          final remoteSettings = await remoteDataSource.fetchSettings(
            userId,
          );
          await localDataSource.cacheSettings(remoteSettings);
          return Right(remoteSettings);
        } catch (e) {
          // Remote fetch failed, create default settings
          final defaultSettings = await _createDefaultSettings();
          await localDataSource.cacheSettings(defaultSettings);
          return Right(defaultSettings);
        }
      }

      // Offline and no cache - create default settings
      final defaultSettings = await _createDefaultSettings();
      await localDataSource.cacheSettings(defaultSettings);
      return Right(defaultSettings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSettings(PlannerSettings settings) async {
    try {
      // Update local first
      await localDataSource.updateSettings(settings);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateSettings(settings);
        } catch (e) {
          // Queue for later sync
        }
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getPrayerTimes(
    DateTime date,
    String city,
  ) async {
    try {
      // Check local cache first
      final cachedTimes = await localDataSource.getCachedPrayerTimes(date);

      if (cachedTimes != null &&
          !prayerTimesService.needsRefresh(cachedTimes)) {
        return Right(cachedTimes);
      }

      // Fetch from API if online
      if (await networkInfo.isConnected) {
        final prayerTimes = await prayerTimesService.getPrayerTimes(
          city: city,
          country: 'Algeria',
          date: date,
        );

        // Cache locally
        await localDataSource.cachePrayerTimes(prayerTimes);

        return Right(prayerTimes);
      }

      // Return cached even if stale (offline)
      if (cachedTimes != null) {
        return Right(cachedTimes);
      }

      return Left(ServerFailure('No internet connection'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch prayer times'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async {
    try {
      if (kDebugMode) print('[PlannerRepository] getSubjects called');
      // Try local first
      final localSubjects = await localDataSource.getCachedSubjects();
      if (kDebugMode)
        print(
          '[PlannerRepository] Local subjects count: ${localSubjects.length}',
        );

      // If online, sync with remote (authentication handled by Bearer token)
      if (await networkInfo.isConnected) {
        if (kDebugMode)
          print('[PlannerRepository] Network connected, fetching from remote');
        try {
          // Note: userId is not actually used by the API - auth is via Bearer token
          // We pass it for compatibility but the API uses $request->user()
          final userId = await _getCurrentUserId() ?? 'token_auth';

          final remoteSubjects = await remoteDataSource.fetchSubjects(
            userId,
          );
          if (kDebugMode)
            print(
              '[PlannerRepository] Remote subjects fetched: ${remoteSubjects.length}',
            );

          // Update local cache
          for (final subject in remoteSubjects) {
            await localDataSource.cacheSubject(subject);
          }

          if (kDebugMode)
            print(
              '[PlannerRepository] Returning ${remoteSubjects.length} subjects',
            );
          return Right(remoteSubjects);
        } catch (e) {
          if (kDebugMode)
            print('[PlannerRepository] Error fetching remote: $e');
          // Return local cache on error
          if (localSubjects.isNotEmpty) {
            return Right(localSubjects);
          }
          rethrow;
        }
      }

      if (kDebugMode)
        print(
          '[PlannerRepository] Returning ${localSubjects.length} local subjects',
        );
      return Right(localSubjects);
    } on CacheException catch (e) {
      if (kDebugMode) print('[PlannerRepository] CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      if (kDebugMode) print('[PlannerRepository] Exception: $e');
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Exam>>> getExams() async {
    try {
      // Try local first
      final localExams = await localDataSource.getCachedExams();

      // If online, sync with remote
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            final remoteExams = await remoteDataSource.fetchExams(
              userId,
            );

            // Update local cache
            for (final exam in remoteExams) {
              await localDataSource.cacheExam(exam);
            }

            return Right(remoteExams);
          }
        } catch (e) {
          // Return local cache on error
          return Right(localExams);
        }
      }

      return Right(localExams);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrioritizedSubject>>> calculatePriorities({
    required List<Subject> subjects,
    required List<Exam> exams,
    required PlannerSettings settings,
  }) async {
    try {
      final prioritizedSubjects = priorityCalculator.calculatePriorities(
        subjects: subjects,
        exams: exams,
        settings: settings,
      );

      return Right(prioritizedSubjects);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncOfflineChanges() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('No internet connection'));
      }

      // Get all queued items ready for retry
      final queuedItems = syncQueue.getItemsToRetry();

      if (queuedItems.isEmpty) {
        if (kDebugMode) {
          print('[PlannerRepository] No items to sync');
        }
        return const Right(unit);
      }

      if (kDebugMode) {
        print('[PlannerRepository] Syncing ${queuedItems.length} queued items...');
      }

      int successCount = 0;
      int failCount = 0;

      // Process each queued operation
      for (final item in queuedItems) {
        try {
          if (kDebugMode) {
            print('[PlannerRepository] Processing: ${item.description} (id: ${item.id})');
          }

          // Process based on entity type and operation
          final result = await _processSyncItem(item);

          if (result) {
            // Remove from queue on success
            await syncQueue.removeFromQueue(item.id);
            successCount++;
            if (kDebugMode) {
              print('[PlannerRepository] ✅ Success: ${item.description}');
            }
          } else {
            // Mark retry attempt
            await syncQueue.markRetry(
              item.id,
              errorMessage: 'Processing returned false',
            );
            failCount++;
            if (kDebugMode) {
              print('[PlannerRepository] ❌ Failed: ${item.description}');
            }
          }
        } catch (e, stackTrace) {
          // Mark retry attempt with error message
          await syncQueue.markRetry(
            item.id,
            errorMessage: e.toString(),
          );
          failCount++;
          if (kDebugMode) {
            print('[PlannerRepository] ❌ Error processing ${item.description}: $e');
            print(stackTrace);
          }
        }
      }

      // Update last sync timestamp if any items succeeded
      if (successCount > 0) {
        await syncQueue.updateLastSyncTimestamp();
      }

      if (kDebugMode) {
        print('[PlannerRepository] Sync complete: $successCount succeeded, $failCount failed');
      }

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Process individual sync queue item
  Future<bool> _processSyncItem(SyncQueueItem item) async {
    switch (item.entityType) {
      case SyncEntityType.session:
        return await _processSessionSync(item);
      case SyncEntityType.settings:
        return await _processSettingsSync(item);
      case SyncEntityType.subject:
        return await _processSubjectSync(item);
      case SyncEntityType.exam:
        return await _processExamSync(item);
      case SyncEntityType.schedule:
        return await _processScheduleSync(item);
      default:
        if (kDebugMode) {
          print('[PlannerRepository] Unknown entity type: ${item.entityType}');
        }
        return false;
    }
  }

  /// Process session sync operations
  Future<bool> _processSessionSync(SyncQueueItem item) async {
    try {
      final sessionId = item.data['sessionId'] as String?;
      if (sessionId == null) {
        if (kDebugMode) {
          print('[PlannerRepository] Missing sessionId in sync data');
        }
        return false;
      }

      switch (item.operation) {
        case SyncOperation.action:
          // Handle session actions (start, pause, resume, complete, skip)
          final actionType = item.actionType;
          switch (actionType) {
            case 'start':
              await remoteDataSource.startSession(sessionId);
              return true;
            case 'pause':
              await remoteDataSource.pauseSession(sessionId);
              return true;
            case 'resume':
              await remoteDataSource.resumeSession(sessionId);
              return true;
            case 'complete':
              final userNotes = item.data['userNotes'] as String?;
              final completionRate = (item.data['completionRate'] as double?)?.toInt() ?? 100;
              final mood = item.data['mood'] as String?;
              await remoteDataSource.completeSession(
                sessionId,
                completionRate,
                userNotes,
                mood,
              );
              return true;
            case 'skip':
              final reason = item.data['reason'] as String? ?? 'Skipped offline';
              await remoteDataSource.skipSession(sessionId, reason);
              return true;
            default:
              if (kDebugMode) {
                print('[PlannerRepository] Unknown session action: $actionType');
              }
              return false;
          }

        case SyncOperation.update:
          // Handle session reschedule
          final newDate = item.data['newDate'] != null
              ? DateTime.parse(item.data['newDate'] as String)
              : null;
          if (newDate != null) {
            // Parse start/end times from data if available, otherwise use defaults
            final startTimeStr = item.data['startTime'] as String?;
            final endTimeStr = item.data['endTime'] as String?;
            final startTime = startTimeStr != null
                ? TimeOfDay(
                    hour: int.parse(startTimeStr.split(':')[0]),
                    minute: int.parse(startTimeStr.split(':')[1]),
                  )
                : const TimeOfDay(hour: 8, minute: 0);
            final endTime = endTimeStr != null
                ? TimeOfDay(
                    hour: int.parse(endTimeStr.split(':')[0]),
                    minute: int.parse(endTimeStr.split(':')[1]),
                  )
                : const TimeOfDay(hour: 9, minute: 0);
            await remoteDataSource.rescheduleSession(sessionId, newDate, startTime, endTime);
            return true;
          }
          return false;

        case SyncOperation.delete:
          await remoteDataSource.deleteSession(sessionId);
          return true;

        default:
          if (kDebugMode) {
            print('[PlannerRepository] Unsupported session operation: ${item.operation}');
          }
          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerRepository] Error processing session sync: $e');
      }
      rethrow;
    }
  }

  /// Process settings sync operations
  Future<bool> _processSettingsSync(SyncQueueItem item) async {
    try {
      // Settings sync would need the settings model
      // For now, skip until we have proper settings model mapping
      if (kDebugMode) {
        print('[PlannerRepository] Settings sync needs settings model - skipping for now');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerRepository] Error processing settings sync: $e');
      }
      rethrow;
    }
  }

  /// Process subject sync operations
  Future<bool> _processSubjectSync(SyncQueueItem item) async {
    try {
      final subjectId = item.data['subjectId'] as String?;
      final userId = item.data['userId'] as String?;

      if (userId == null) {
        if (kDebugMode) {
          print('[PlannerRepository] Missing userId for subject sync');
        }
        return false;
      }

      switch (item.operation) {
        case SyncOperation.create:
        case SyncOperation.update:
          // Subject create/update would need Subject model
          // For now, skip until we have proper model mapping
          if (kDebugMode) {
            print('[PlannerRepository] Subject sync needs Subject model - skipping for now');
          }
          return false;

        case SyncOperation.delete:
          if (subjectId != null) {
            await remoteDataSource.deleteSubject(userId, subjectId);
            return true;
          }
          return false;

        default:
          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerRepository] Error processing subject sync: $e');
      }
      rethrow;
    }
  }

  /// Process exam sync operations
  Future<bool> _processExamSync(SyncQueueItem item) async {
    try {
      // Exam sync would go here if the remote datasource has exam methods
      // For now, return false as exam sync is not yet implemented in remote datasource
      if (kDebugMode) {
        print('[PlannerRepository] Exam sync not yet implemented');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerRepository] Error processing exam sync: $e');
      }
      rethrow;
    }
  }

  /// Process schedule sync operations
  Future<bool> _processScheduleSync(SyncQueueItem item) async {
    try {
      if (item.operation == SyncOperation.create) {
        final userId = item.data['userId'] as String?;
        final startDate = item.data['startDate'] != null
            ? DateTime.parse(item.data['startDate'] as String)
            : null;
        final endDate = item.data['endDate'] != null
            ? DateTime.parse(item.data['endDate'] as String)
            : null;
        final subjectIds = item.data['selectedSubjectIds'] as List?;

        if (userId != null && startDate != null && endDate != null && subjectIds != null) {
          await remoteDataSource.generateSchedule(
            userId: userId,
            startDate: startDate,
            endDate: endDate,
            subjectIds: List<String>.from(subjectIds),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[PlannerRepository] Error processing schedule sync: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await localDataSource.clearAllSessions();
      await localDataSource.clearOldPrayerTimes();
      await localDataSource.clearOldSchedules();

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Create default settings for new users
  Future<PlannerSettings> _createDefaultSettings() async {
    final userId = await _getCurrentUserId() ?? 'default_user';
    return PlannerSettings(
      userId: userId,
      studyStartTime: const TimeOfDay(hour: 8, minute: 0), // 8:00 AM
      studyEndTime: const TimeOfDay(hour: 22, minute: 0), // 10:00 PM
      sleepStartTime: const TimeOfDay(hour: 23, minute: 0), // 11:00 PM
      sleepEndTime: const TimeOfDay(hour: 7, minute: 0), // 7:00 AM
      exerciseEnabled: false,
      morningEnergyLevel: 7,
      afternoonEnergyLevel: 6,
      eveningEnergyLevel: 8,
      nightEnergyLevel: 4,
      usePomodoroTechnique: true,
      pomodoroDurationMinutes: 25,
      enablePrayerTimes: false,
      cityForPrayer: 'Algiers',
      // Other properties will use their default values from the entity
    );
  }

  // Background sync helper
  Future<void> _syncSettingsInBackground(String userId) async {
    try {
      final remoteSettings = await remoteDataSource.fetchSettings(userId);
      await localDataSource.cacheSettings(remoteSettings);
    } catch (e) {
      // Silently fail background sync
    }
  }

  // Subject Management Methods
  @override
  Future<Either<Failure, List<Subject>>> getAllSubjects() async {
    return getSubjects(); // Delegate to existing method
  }

  @override
  Future<Either<Failure, Subject>> getSubject(String id) async {
    try {
      final subject = await localDataSource.getSubject(id);
      if (subject == null) {
        return Left(CacheFailure('Subject not found'));
      }
      return Right(subject);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subject>> addSubject(Subject subject) async {
    try {
      // Cache locally first
      await localDataSource.cacheSubject(subject);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await remoteDataSource.addSubject(userId, subject);
          }
        } catch (e) {
          // Queue for later sync
        }
      }

      return Right(subject);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subject>> updateSubject(Subject subject) async {
    try {
      // Update locally first
      await localDataSource.updateSubject(subject);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await remoteDataSource.updateSubject(userId, subject);
          }
        } catch (e) {
          // Queue for later sync
        }
      }

      return Right(subject);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubject(String id) async {
    try {
      // Delete locally first
      await localDataSource.deleteSubject(id);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await remoteDataSource.deleteSubject(userId, id);
          }
        } catch (e) {
          // Queue for later sync
        }
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Exam Management Methods
  @override
  Future<Either<Failure, List<Exam>>> getAllExams() async {
    return getExams(); // Delegate to existing method
  }

  @override
  Future<Either<Failure, List<Exam>>> getExamsBySubject(
    String subjectId,
  ) async {
    try {
      final allExams = await localDataSource.getCachedExams();
      final subjectExams = allExams
          .where((exam) => exam.subjectId == subjectId)
          .toList();
      return Right(subjectExams);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Exam>>> getUpcomingExams() async {
    try {
      final allExams = await localDataSource.getCachedExams();
      final now = DateTime.now();
      final upcomingExams = allExams
          .where((exam) => exam.examDate.isAfter(now))
          .toList();

      // Sort by date (nearest first)
      upcomingExams.sort((a, b) => a.examDate.compareTo(b.examDate));

      return Right(upcomingExams);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Exam>> addExam(Exam exam) async {
    try {
      // Cache locally first
      await localDataSource.cacheExam(exam);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await remoteDataSource.addExam(userId, exam);
          }
        } catch (e) {
          // Queue for later sync
        }
      }

      return Right(exam);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Exam>> updateExam(Exam exam) async {
    try {
      // Update locally first
      await localDataSource.updateExam(exam);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await remoteDataSource.updateExam(userId, exam);
          }
        } catch (e) {
          // Queue for later sync
        }
      }

      return Right(exam);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExam(String id) async {
    try {
      // Delete locally first
      await localDataSource.deleteExam(id);

      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await remoteDataSource.deleteExam(userId, id);
          }
        } catch (e) {
          // Queue for later sync
        }
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Centralized Subjects Management
  @override
  Future<Either<Failure, List<CentralizedSubject>>> getCentralizedSubjects({
    int? streamId,
    int? yearId,
    bool activeOnly = true,
  }) async {
    try {
      // Check if cache is valid (24 hours TTL)
      final isCacheValid = await localDataSource
          .isCentralizedSubjectsCacheValid();

      if (isCacheValid) {
        // Return cached subjects
        final cachedSubjects = await localDataSource
            .getCachedCentralizedSubjects();
        if (cachedSubjects != null && cachedSubjects.isNotEmpty) {
          return Right(cachedSubjects);
        }
      }

      // Cache expired or empty, fetch from API if online
      if (await networkInfo.isConnected) {
        try {
          final subjects = await remoteDataSource.fetchCentralizedSubjects(
            streamId: streamId,
            yearId: yearId,
            activeOnly: activeOnly,
          );

          // Update cache
          await localDataSource.cacheCentralizedSubjects(subjects);

          return Right(subjects);
        } on ServerException catch (e) {
          // API failed, try to return stale cache
          final cachedSubjects = await localDataSource
              .getCachedCentralizedSubjects();
          if (cachedSubjects != null && cachedSubjects.isNotEmpty) {
            return Right(cachedSubjects);
          }
          return Left(ServerFailure(e.message));
        }
      } else {
        // No network, return cached subjects even if stale
        final cachedSubjects = await localDataSource
            .getCachedCentralizedSubjects();
        if (cachedSubjects != null && cachedSubjects.isNotEmpty) {
          return Right(cachedSubjects);
        }
        return Left(
          ServerFailure(
            'No internet connection and no cached subjects available',
          ),
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlannerAnalytics>> getPlannerAnalytics(
    String period,
  ) async {
    try {
      // Calculate date range based on period
      final now = DateTime.now();
      late DateTime startDate;

      switch (period) {
        case 'last_7_days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last_30_days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'last_3_months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'all_time':
          startDate = DateTime(2020, 1, 1); // Arbitrary start date
          break;
        default:
          startDate = now.subtract(const Duration(days: 30));
      }

      // Fetch all sessions from local storage using date range
      final endDate = now.add(const Duration(days: 1));
      final sessionsInPeriod = await localDataSource.getSessionsInRange(
        startDate,
        endDate,
      );

      // Calculate metrics
      final completedSessions = sessionsInPeriod
          .where((s) => s.status == SessionStatus.completed)
          .toList();
      final missedSessions = sessionsInPeriod
          .where((s) => s.status == SessionStatus.missed)
          .toList();
      final skippedSessions = sessionsInPeriod
          .where((s) => s.status == SessionStatus.skipped)
          .toList();

      final totalMinutes = completedSessions.fold<int>(
        0,
        (sum, session) =>
            sum + ((session.actualDuration ?? session.duration).inMinutes),
      );
      final totalHours = totalMinutes / 60.0;

      final completionRate = sessionsInPeriod.isNotEmpty
          ? (completedSessions.length / sessionsInPeriod.length) * 100
          : 0.0;

      final avgDuration = completedSessions.isNotEmpty
          ? (totalMinutes / completedSessions.length).round()
          : 0;

      // Calculate streak
      final streak = _calculateCurrentStreak(sessionsInPeriod);
      final longestStreak = _calculateLongestStreak(sessionsInPeriod);

      // Get user points from cached user data
      int totalPoints = 0;
      int currentLevel = 1;
      try {
        final userModel = await authLocalDataSource.getCachedUser();
        final user = userModel.toEntity();
        if (user.profile != null) {
          totalPoints = user.profile!.points;
          currentLevel = user.profile!.level;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[PlannerRepository] Failed to get user profile data: $e');
        }
        // Use defaults if user data unavailable
      }

      // Subject breakdown
      final subjectTimeMap = <String, double>{};
      final subjectSessionMap = <String, int>{};

      for (final session in completedSessions) {
        final subjectName = session.subjectName;
        final duration =
            (session.actualDuration ?? session.duration).inMinutes / 60.0;

        subjectTimeMap[subjectName] =
            (subjectTimeMap[subjectName] ?? 0.0) + duration;
        subjectSessionMap[subjectName] =
            (subjectSessionMap[subjectName] ?? 0) + 1;
      }

      // Weekly productivity (day of week -> hours)
      final weeklyHours = <int, double>{};
      for (final session in completedSessions) {
        final dayOfWeek =
            (session.scheduledDate.weekday + 1) % 7; // Convert to 0=Saturday
        final duration =
            (session.actualDuration ?? session.duration).inMinutes / 60.0;
        weeklyHours[dayOfWeek] = (weeklyHours[dayOfWeek] ?? 0.0) + duration;
      }

      // Daily study trend
      final dailyData = <DateTime, DailyStudyDataModel>{};
      for (final session in completedSessions) {
        final date = DateTime(
          session.scheduledDate.year,
          session.scheduledDate.month,
          session.scheduledDate.day,
        );
        final duration =
            (session.actualDuration ?? session.duration).inMinutes / 60.0;

        final existing = dailyData[date];
        if (existing != null) {
          dailyData[date] = DailyStudyDataModel(
            date: date,
            hours: existing.hours + duration,
            sessionCount: existing.sessionCount + 1,
          );
        } else {
          dailyData[date] = DailyStudyDataModel(
            date: date,
            hours: duration,
            sessionCount: 1,
          );
        }
      }

      final dailyTrend = dailyData.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // Productivity patterns
      final patterns = _calculateProductivityPatterns(completedSessions);

      // Generate recommendations
      final recommendations = _generateRecommendations(
        completedSessions,
        missedSessions,
        subjectTimeMap,
        patterns,
      );

      final analytics = PlannerAnalyticsModel(
        period: period,
        startDate: startDate,
        endDate: now,
        totalHours: totalHours,
        sessionsCompleted: completedSessions.length,
        sessionsMissed: missedSessions.length,
        sessionsSkipped: skippedSessions.length,
        completionRate: completionRate,
        averageSessionDuration: avgDuration,
        currentStreak: streak,
        longestStreak: longestStreak,
        totalPoints: totalPoints,
        currentLevel: currentLevel,
        subjectTimeBreakdown: subjectTimeMap,
        subjectSessionCount: subjectSessionMap,
        weeklyProductivityHours: weeklyHours,
        dailyStudyTrend: dailyTrend,
        patterns: patterns,
        recommendations: recommendations,
      );

      return Right(analytics);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to calculate analytics: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SessionHistory>> getSessionHistory({
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Fetch sessions from local storage using date range
      var filteredSessions = await localDataSource.getSessionsInRange(
        startDate.subtract(const Duration(days: 1)),
        endDate.add(const Duration(days: 1)),
      );

      // Apply additional filters if provided
      if (filters != null) {
        if (filters['status'] != null) {
          final statusFilter = filters['status'] as String;
          filteredSessions = filteredSessions.where((s) {
            return s.status.toString().split('.').last == statusFilter;
          }).toList();
        }
        if (filters['subject_id'] != null) {
          final subjectId = filters['subject_id'] as String;
          filteredSessions = filteredSessions.where((s) {
            return s.subjectId == subjectId;
          }).toList();
        }
      }

      // Convert to historical sessions
      final historicalSessions = filteredSessions.map((session) {
        return HistoricalSessionModel(
          id: session.id,
          subjectId: session.subjectId,
          subjectName: session.subjectName,
          subjectColor:
              session.subjectColor?.value
                  .toRadixString(16)
                  .padLeft(8, '0')
                  .substring(2) ??
              '6366F1',
          scheduledDate: session.scheduledDate,
          scheduledStartTime:
              '${session.scheduledStartTime.hour.toString().padLeft(2, '0')}:${session.scheduledStartTime.minute.toString().padLeft(2, '0')}',
          scheduledEndTime:
              '${session.scheduledEndTime.hour.toString().padLeft(2, '0')}:${session.scheduledEndTime.minute.toString().padLeft(2, '0')}',
          actualStartTime: session.actualStartTime,
          actualEndTime: session.actualEndTime,
          durationMinutes:
              (session.actualDuration ?? session.duration).inMinutes,
          pointsEarned: 0, // TODO: Get from session if available
          mood: null, // TODO: Get from session if available
          completionPercentage: session.completionPercentage ?? 100,
          userNotes: session.userNotes,
          sessionType: session.sessionType.toString().split('.').last,
          contentTitle: session.contentTitle,
          status: session.status.toString().split('.').last,
        );
      }).toList();

      // Calculate intensity map for heatmap
      final intensityMap = <String, int>{};
      final dailySessionCount = <String, int>{};

      for (final session in filteredSessions) {
        if (session.status == SessionStatus.completed) {
          final dateKey =
              '${session.scheduledDate.year}-${session.scheduledDate.month.toString().padLeft(2, '0')}-${session.scheduledDate.day.toString().padLeft(2, '0')}';
          dailySessionCount[dateKey] = (dailySessionCount[dateKey] ?? 0) + 1;
        }
      }

      // Convert session count to intensity (0-4 scale)
      for (final entry in dailySessionCount.entries) {
        final count = entry.value;
        int intensity;
        if (count == 0)
          intensity = 0;
        else if (count <= 2)
          intensity = 1;
        else if (count <= 4)
          intensity = 2;
        else if (count <= 6)
          intensity = 3;
        else
          intensity = 4;

        intensityMap[entry.key] = intensity;
      }

      // Calculate statistics
      final completedSessions = filteredSessions
          .where((s) => s.status == SessionStatus.completed)
          .toList();
      final totalMinutes = completedSessions.fold<int>(
        0,
        (sum, s) => sum + (s.actualDuration ?? s.duration).inMinutes,
      );

      final moodDist = <String, int>{'happy': 0, 'neutral': 0, 'sad': 0};

      final subjectStats = <String, SubjectStatsModel>{};
      for (final session in completedSessions) {
        final subjectName = session.subjectName;
        final subjectId = session.subjectId;
        final duration = (session.actualDuration ?? session.duration).inMinutes;
        final colorHex =
            session.subjectColor?.value
                .toRadixString(16)
                .padLeft(8, '0')
                .substring(2) ??
            '6366F1';

        if (subjectStats.containsKey(subjectId)) {
          final existing = subjectStats[subjectId]!;
          subjectStats[subjectId] = SubjectStatsModel(
            subjectId: subjectId,
            subjectName: subjectName,
            subjectColor: colorHex,
            sessionCount: existing.sessionCount + 1,
            totalMinutes: existing.totalMinutes + duration,
            totalPoints: existing.totalPoints,
          );
        } else {
          subjectStats[subjectId] = SubjectStatsModel(
            subjectId: subjectId,
            subjectName: subjectName,
            subjectColor: colorHex,
            sessionCount: 1,
            totalMinutes: duration,
            totalPoints: 0,
          );
        }
      }

      final statistics = HistoryStatisticsModel(
        totalSessions: filteredSessions.length,
        totalMinutes: totalMinutes,
        totalHours: totalMinutes / 60.0,
        totalPoints: 0,
        averageSessionDuration: completedSessions.isNotEmpty
            ? (totalMinutes / completedSessions.length).round()
            : 0,
        moodDistribution: moodDist,
        subjectBreakdown: subjectStats,
      );

      final history = SessionHistoryModel(
        startDate: startDate,
        endDate: endDate,
        sessions: historicalSessions,
        intensityMap: intensityMap,
        statistics: statistics,
        filters: filters ?? {},
      );

      return Right(history);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to get session history: ${e.toString()}'),
      );
    }
  }

  int _calculateCurrentStreak(List<StudySession> allSessions) {
    final completedByDate = <DateTime, bool>{};
    for (final session in allSessions.where(
      (s) => s.status == SessionStatus.completed,
    )) {
      final date = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
      );
      completedByDate[date] = true;
    }

    int streak = 0;
    var checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    while (completedByDate[checkDate] == true) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateLongestStreak(List<StudySession> allSessions) {
    final completedByDate = <DateTime, bool>{};
    for (final session in allSessions.where(
      (s) => s.status == SessionStatus.completed,
    )) {
      final date = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
      );
      completedByDate[date] = true;
    }

    final sortedDates = completedByDate.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].difference(sortedDates[i - 1]).inDays == 1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  ProductivityPatternsModel? _calculateProductivityPatterns(
    List<StudySession> sessions,
  ) {
    if (sessions.isEmpty) return null;

    // Find best time of day
    final timeBlocks = <String, int>{
      'morning': 0,
      'afternoon': 0,
      'evening': 0,
      'night': 0,
    };

    final dayOfWeekCount = <int, int>{};
    int totalDuration = 0;

    for (final session in sessions) {
      final hour = session.scheduledStartTime.hour;
      if (hour >= 6 && hour < 12)
        timeBlocks['morning'] = timeBlocks['morning']! + 1;
      else if (hour >= 12 && hour < 17)
        timeBlocks['afternoon'] = timeBlocks['afternoon']! + 1;
      else if (hour >= 17 && hour < 21)
        timeBlocks['evening'] = timeBlocks['evening']! + 1;
      else
        timeBlocks['night'] = timeBlocks['night']! + 1;

      final dayOfWeek = session.scheduledDate.weekday;
      dayOfWeekCount[dayOfWeek] = (dayOfWeekCount[dayOfWeek] ?? 0) + 1;

      totalDuration += (session.actualDuration ?? session.duration).inMinutes;
    }

    final bestTime = timeBlocks.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final bestDay = dayOfWeekCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final daysArabic = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final bestDayName = daysArabic[(bestDay + 5) % 7];

    return ProductivityPatternsModel(
      bestTimeOfDay: bestTime == 'morning'
          ? 'الصباح'
          : bestTime == 'afternoon'
          ? 'بعد الظهر'
          : bestTime == 'evening'
          ? 'المساء'
          : 'الليل',
      bestDayOfWeek: bestDayName,
      optimalSessionDuration: sessions.isNotEmpty
          ? (totalDuration / sessions.length).round()
          : 45,
      productivityScore: sessions.length > 0
          ? (sessions.length / 10.0 * 100).clamp(0, 100)
          : 0,
      peakStudyHour: 9, // Simplified
    );
  }

  List<String> _generateRecommendations(
    List<StudySession> completed,
    List<StudySession> missed,
    Map<String, double> subjectTime,
    ProductivityPatternsModel? patterns,
  ) {
    final recommendations = <String>[];

    // 1. Analyze missed sessions ratio
    final totalSessions = completed.length + missed.length;
    if (totalSessions > 0) {
      final missedRatio = missed.length / totalSessions;
      if (missedRatio > 0.5) {
        recommendations.add('معدل الجلسات الفائتة مرتفع جداً (${(missedRatio * 100).round()}%). راجع جدولك وحدد أوقات واقعية.');
      } else if (missedRatio > 0.3) {
        recommendations.add('لديك ${missed.length} جلسة فائتة. حاول تحسين الالتزام بالجدول.');
      } else if (missedRatio < 0.1 && completed.length > 10) {
        recommendations.add('التزامك بالجدول ممتاز! معدل الإنجاز ${((1 - missedRatio) * 100).round()}%');
      }
    }

    // 2. Analyze subject time balance
    if (subjectTime.isNotEmpty && subjectTime.length > 1) {
      final values = subjectTime.values.toList();
      final avg = values.reduce((a, b) => a + b) / values.length;

      // Find subjects significantly below average
      final lowSubjects = subjectTime.entries
          .where((e) => e.value < avg * 0.5)
          .toList();

      if (lowSubjects.isNotEmpty) {
        final subject = lowSubjects.first;
        final percentage = ((avg - subject.value) / avg * 100).round();
        recommendations.add('زد وقت دراسة ${subject.key} بنسبة $percentage% لتحقيق توازن أفضل.');
      }

      // Find dominant subject (over 40% of total time)
      final total = values.reduce((a, b) => a + b);
      final dominant = subjectTime.entries
          .where((e) => e.value > total * 0.4)
          .toList();

      if (dominant.isNotEmpty) {
        recommendations.add('تركيزك على ${dominant.first.key} عالٍ. تأكد من عدم إهمال المواد الأخرى.');
      }
    }

    // 3. Productivity patterns insights
    if (patterns != null) {
      // Best time of day
      if (patterns.bestTimeOfDay.isNotEmpty) {
        final timeArabic = _translateTimeOfDay(patterns.bestTimeOfDay);
        recommendations.add('أنت أكثر إنتاجية في $timeArabic. خطط للمواد الصعبة في هذا الوقت.');
      }

      // Optimal session duration
      if (patterns.optimalSessionDuration > 0) {
        if (patterns.optimalSessionDuration < 30) {
          recommendations.add('جلساتك قصيرة (${patterns.optimalSessionDuration} دقيقة). حاول زيادتها تدريجياً إلى 45 دقيقة.');
        } else if (patterns.optimalSessionDuration > 90) {
          recommendations.add('جلساتك طويلة (${patterns.optimalSessionDuration} دقيقة). خذ استراحات منتظمة كل 45-60 دقيقة.');
        }
      }

      // Best day of week
      if (patterns.bestDayOfWeek.isNotEmpty) {
        recommendations.add('أفضل أيامك للدراسة: ${patterns.bestDayOfWeek}. استغله للمواد الصعبة.');
      }
    }

    // 4. Study streak motivation
    if (completed.isNotEmpty) {
      // Filter sessions with valid actualStartTime
      final validSessions = completed
          .where((s) => s.actualStartTime != null)
          .toList();

      if (validSessions.isNotEmpty) {
        // Calculate current streak
        final sortedSessions = validSessions
          ..sort((a, b) => b.actualStartTime!.compareTo(a.actualStartTime!));

        int streak = 0;
        DateTime? lastDate;

        for (final session in sortedSessions) {
          final sessionDate = DateTime(
            session.actualStartTime!.year,
            session.actualStartTime!.month,
            session.actualStartTime!.day,
          );

          if (lastDate == null) {
            streak = 1;
            lastDate = sessionDate;
          } else {
            final diff = lastDate.difference(sessionDate).inDays;
            if (diff == 1) {
              streak++;
              lastDate = sessionDate;
            } else {
              break;
            }
          }
        }

        if (streak >= 7) {
          recommendations.add('رائع! لديك سلسلة $streak يوم متتالي. حافظ عليها!');
        } else if (streak >= 3) {
          recommendations.add('سلسلتك $streak أيام. استمر لتصل إلى أسبوع كامل!');
        }
      }
    }

    // 5. Completion rate excellence
    if (completed.length > 20) {
      final completionRate = totalSessions > 0
          ? (completed.length / totalSessions * 100).round()
          : 0;

      if (completionRate >= 90) {
        recommendations.add('معدل إنجازك استثنائي ($completionRate%)! أنت قدوة للآخرين.');
      } else if (completionRate >= 75) {
        recommendations.add('معدل إنجازك ممتاز ($completionRate%)! استمر على هذا المنوال.');
      }
    }

    // 6. Weekly consistency check
    if (completed.length >= 7) {
      final last7Days = completed.where((s) {
        if (s.actualStartTime == null) return false;
        final diff = DateTime.now().difference(s.actualStartTime!).inDays;
        return diff <= 7;
      }).toList();

      if (last7Days.isEmpty) {
        recommendations.add('لم تدرس هذا الأسبوع. ابدأ بجلسة قصيرة اليوم!');
      } else if (last7Days.length < 3) {
        recommendations.add('نشاطك الأسبوعي منخفض (${last7Days.length} جلسات). حاول الدراسة يومياً.');
      }
    }

    // 7. Default encouragement
    if (recommendations.isEmpty) {
      if (completed.isEmpty && missed.isEmpty) {
        recommendations.add('ابدأ رحلتك التعليمية اليوم! أضف جلسة دراسية إلى جدولك.');
      } else {
        recommendations.add('واصل العمل الجيد! كل جلسة دراسية تقربك من أهدافك.');
      }
    }

    // Limit to top 4 most relevant recommendations
    return recommendations.take(4).toList();
  }

  String _translateTimeOfDay(String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        return 'الصباح';
      case 'afternoon':
        return 'بعد الظهر';
      case 'evening':
        return 'المساء';
      case 'night':
        return 'الليل';
      default:
        return timeOfDay;
    }
  }

  // ==================== NEW GAMIFICATION METHODS ====================

  @override
  Future<Either<Failure, AchievementsResponse>> getAchievements() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      final achievements = await remoteDataSource.fetchAchievements();
      return Right(achievements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل الإنجازات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PointsHistory>> getPointsHistory(int periodDays) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      final history = await remoteDataSource.fetchPointsHistory(periodDays);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل سجل النقاط: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExamResultResponse>> recordExamResult({
    required String examId,
    required double score,
    required double maxScore,
    String? notes,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      final response = await remoteDataSource.recordExamResult(
        examId: examId,
        score: score,
        maxScore: maxScore,
        notes: notes,
      );

      // Update local cache with the updated exam
      await localDataSource.updateExam(response.exam);

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تسجيل نتيجة الامتحان: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AdaptationResult>> triggerAdaptation() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      final result = await remoteDataSource.triggerAdaptation();

      // After successful adaptation, refresh the sessions from server
      final userId = await _getCurrentUserId();
      if (userId != null) {
        try {
          // Refresh today's sessions
          final remoteSessions = await remoteDataSource.fetchTodaysSessions(userId);
          final now = DateTime.now();
          for (final session in remoteSessions) {
            final cachedSession = session.copyWith(
              cachedAt: now,
              lastSyncedAt: now,
              isDirty: false,
            );
            await localDataSource.cacheSession(cachedSession);
          }
        } catch (e) {
          // Ignore refresh errors
          if (kDebugMode) {
            print('[Repository] Failed to refresh sessions after adaptation: $e');
          }
        }
      }

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تكييف الجدول: ${e.toString()}'));
    }
  }

  // ==================== SESSION CONTENT (CURRICULUM INTEGRATION) ====================

  @override
  Future<Either<Failure, (List<SessionContent>, SessionContentMeta)>> getNextSessionContent({
    required String subjectId,
    required String sessionType,
    int durationMinutes = 30,
    int limit = 5,
    String? contentId,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      final response = await remoteDataSource.fetchNextSessionContent(
        subjectId: subjectId,
        sessionType: sessionType,
        durationMinutes: durationMinutes,
        limit: limit,
        contentId: contentId, // Pass specific content ID to API
      );

      return Right((response.contents, response.meta));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل محتوى الجلسة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markContentPhaseComplete({
    required String contentId,
    required String phase,
    int durationMinutes = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      await remoteDataSource.markContentPhaseComplete(
        contentId: contentId,
        phase: phase,
        durationMinutes: durationMinutes,
      );

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث تقدم المحتوى: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markMultipleContentPhasesComplete({
    required List<String> contentIds,
    required String phase,
    int durationMinutes = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }

      // Calculate duration per content item
      final durationPerItem = contentIds.isNotEmpty
          ? (durationMinutes / contentIds.length).round()
          : 0;

      // Mark each content item's phase as complete
      for (final contentId in contentIds) {
        await remoteDataSource.markContentPhaseComplete(
          contentId: contentId,
          phase: phase,
          durationMinutes: durationPerItem,
        );
      }

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تحديث تقدم المحتوى: ${e.toString()}'));
    }
  }
}
