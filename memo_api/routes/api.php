<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AcademicController;
use App\Http\Controllers\ContentController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\UserSubjectController;
use App\Http\Controllers\UserStatsController;
use App\Http\Controllers\Api\V1\Auth\AuthController as V1AuthController;
use App\Http\Controllers\Api\V1\AcademicController as V1AcademicController;
use App\Http\Controllers\Api\V1\SubjectController as V1SubjectController;
use App\Http\Controllers\Api\V1\ContentController as V1ContentController;
use App\Http\Controllers\Api\V1\ProgressController as V1ProgressController;
use App\Http\Controllers\Api\V1\BookmarkController as V1BookmarkController;
use App\Http\Controllers\Api\V1\BacBookmarkController as V1BacBookmarkController;
use App\Http\Controllers\Api\PlannerController as ApiPlannerController;
use App\Http\Controllers\PlannerController;
use App\Http\Controllers\Api\StudySessionController;
use App\Http\Controllers\Api\PriorityController;
use App\Http\Controllers\Api\QuizController;
use App\Http\Controllers\Api\QuizAttemptController;
use App\Http\Controllers\Api\BacArchiveController;
use App\Http\Controllers\Api\CourseApiController;
use App\Http\Controllers\Api\SubscriptionApiController;
use App\Http\Controllers\Api\ProgressApiController;
use App\Http\Controllers\Api\ReviewApiController;
use App\Http\Controllers\Api\NotificationApiController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\PlannerSubjectController;
use App\Http\Controllers\Api\V1\PlannerSubjectsController;
use App\Http\Controllers\Api\ExamController;
use App\Http\Controllers\Api\PrayerTimesController;
use App\Http\Controllers\Api\CouponController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\CertificateController;
use App\Http\Controllers\StatisticsController;
use App\Http\Controllers\SettingsController;
use App\Http\Controllers\DeviceSessionController;
use App\Http\Controllers\Api\SponsorController;
use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\LeaderboardController;
use App\Http\Controllers\Api\BacStudyScheduleController;
use App\Http\Controllers\Api\AppVersionController;
use App\Http\Controllers\SubjectPlannerContentController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PdfController;

// App version check (public - no auth required)
Route::get('/app/version-check', [AppVersionController::class, 'check']);

// Public authentication routes (no auth required) - with strict rate limiting
Route::middleware('throttle:10,1')->prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/device-transfer/request', [AuthController::class, 'requestDeviceTransfer']);
});

// Protected authentication routes (auth required)
Route::middleware('auth:sanctum')->prefix('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/logout-all', [AuthController::class, 'logoutAll']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/refresh', [AuthController::class, 'refresh']);

    // Device transfer management
    Route::get('/device-transfer/my-requests', [AuthController::class, 'myDeviceTransferRequests']);

    // Admin only device transfer routes
    Route::middleware('admin')->group(function () {
        Route::get('/device-transfer/pending', [AuthController::class, 'pendingDeviceTransferRequests']);
        Route::post('/device-transfer/approve/{id}', [AuthController::class, 'approveDeviceTransfer']);
        Route::post('/device-transfer/reject/{id}', [AuthController::class, 'rejectDeviceTransfer']);
    });
});

// ===== PUBLIC ROUTES =====

// Academic structure (public access)
Route::prefix('academic')->group(function () {
    Route::get('/phases', [AcademicController::class, 'getPhases']);
    Route::get('/years', [AcademicController::class, 'getYears']);
    Route::get('/streams', [AcademicController::class, 'getStreams']);
    Route::get('/subjects', [AcademicController::class, 'getSubjects']);
    Route::get('/subjects/{id}', [AcademicController::class, 'getSubject']);
    Route::get('/bac-streams', [AcademicController::class, 'getBacStreams']);
});

// Content (auth required for user progress tracking)
Route::prefix('contents')->middleware('auth:sanctum')->group(function () {
    Route::get('/', [ContentController::class, 'index']);
    Route::get('/{id}', [ContentController::class, 'show']);
});

// Sponsors (public - "هاد التطبيق برعاية" section)
Route::prefix('v1/sponsors')->group(function () {
    Route::get('/', [SponsorController::class, 'index']);
    Route::get('/{sponsor}', [SponsorController::class, 'show']);
    Route::post('/{sponsor}/click', [SponsorController::class, 'recordClick']);
});

// Promos (public - Promotional slider on home page)
Route::prefix('v1/promos')->group(function () {
    Route::get('/', [PromoController::class, 'index']);
    Route::get('/settings', [PromoController::class, 'settings']);
    Route::get('/{promo}', [PromoController::class, 'show']);
    Route::post('/{promo}/click', [PromoController::class, 'recordClick']);
});

// ===== BAC STUDY SCHEDULE ROUTES (ManuellePlanner Feature 2) =====
// Public routes - View study schedule (no auth needed)
Route::prefix('bac-study')->group(function () {
    Route::get('/schedule/{stream_id}', [BacStudyScheduleController::class, 'index']);
    Route::get('/day/{stream_id}/{day_number}', [BacStudyScheduleController::class, 'getByDay']);
});

// Protected BAC Study routes (require auth) - User progress tracking
Route::middleware('auth:sanctum')->prefix('bac-study')->group(function () {
    Route::get('/week/{stream_id}/{week_number}', [BacStudyScheduleController::class, 'getByWeek']);
    Route::get('/rewards/{stream_id}', [BacStudyScheduleController::class, 'getRewards']);
    Route::post('/progress/complete', [BacStudyScheduleController::class, 'markTopicComplete']);
    Route::get('/progress/user', [BacStudyScheduleController::class, 'getUserProgress']);
    Route::get('/progress/stats', [BacStudyScheduleController::class, 'getStats']);
    Route::get('/day-with-progress/{stream_id}/{day_number}', [BacStudyScheduleController::class, 'getDayWithProgress']);
});

// ===== PROTECTED ROUTES (Auth Required) =====
// Rate limit: 60 requests per minute for authenticated users

Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    // Profile routes
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'getProfile']);
        Route::put('/', [ProfileController::class, 'updateProfile']);
        Route::post('/academic', [ProfileController::class, 'updateAcademicProfile']);
        Route::get('/subjects', [ProfileController::class, 'getSubjects']);
        Route::post('/subjects', [ProfileController::class, 'updateSubjects']);
        Route::post('/photo', [ProfileController::class, 'uploadPhoto']);
        Route::post('/change-password', [ProfileController::class, 'changePassword']);
        Route::get('/stats', [ProfileController::class, 'getStats']);
        Route::post('/delete-account', [ProfileController::class, 'deleteAccount']);
        Route::post('/export', [ProfileController::class, 'exportData']);
    });

    // Statistics routes
    Route::prefix('statistics')->group(function () {
        Route::get('/', [StatisticsController::class, 'getStatistics']);
        Route::get('/weekly', [StatisticsController::class, 'getWeeklyChart']);
        Route::get('/subjects', [StatisticsController::class, 'getSubjectBreakdown']);
        Route::get('/achievements', [StatisticsController::class, 'getAchievements']);
        Route::get('/streak-calendar', [StatisticsController::class, 'getStreakCalendar']);
    });

    // Settings routes
    Route::prefix('settings')->group(function () {
        Route::get('/', [SettingsController::class, 'getSettings']);
        Route::put('/', [SettingsController::class, 'updateSettings']);
        Route::put('/notifications', [SettingsController::class, 'updateNotificationSettings']);
        Route::put('/prayer-times', [SettingsController::class, 'updatePrayerTimesSettings']);
        Route::put('/language', [SettingsController::class, 'updateLanguage']);
        Route::put('/theme', [SettingsController::class, 'updateTheme']);
        Route::put('/study', [SettingsController::class, 'updateStudySettings']);
        Route::put('/privacy', [SettingsController::class, 'updatePrivacySettings']);
    });

    // Device Sessions routes
    Route::prefix('sessions')->group(function () {
        Route::get('/devices', [DeviceSessionController::class, 'index']);
        Route::put('/device', [DeviceSessionController::class, 'update']);
        Route::delete('/devices/{sessionId}', [DeviceSessionController::class, 'logout']);
        Route::delete('/devices', [DeviceSessionController::class, 'logoutAllOthers']);
        Route::get('/statistics', [DeviceSessionController::class, 'statistics']);
    });

    // Content interaction routes
    Route::prefix('contents')->group(function () {
        Route::post('/{id}/view', [ContentController::class, 'recordView']);
        Route::post('/{id}/download', [ContentController::class, 'recordDownload']);
        Route::post('/{id}/rate', [ContentController::class, 'rate']);
        Route::get('/{id}/progress', [ContentController::class, 'getProgress']);
        Route::post('/{id}/progress', [ContentController::class, 'updateProgress']);
    });

    // ===== USER MANAGEMENT ROUTES (v1) =====

    Route::prefix('v1/user')->group(function () {
        // Profile management
        Route::get('/profile', [UserController::class, 'getProfile']);
        Route::put('/profile', [UserController::class, 'updateProfile'])->middleware('throttle:10,1'); // 10 requests per minute
        Route::post('/avatar', [UserController::class, 'uploadAvatar'])->middleware('throttle:3,60'); // 3 requests per hour
        Route::delete('/avatar', [UserController::class, 'deleteAvatar']);

        // Preferences
        Route::get('/preferences', [UserController::class, 'getPreferences']);
        Route::put('/preferences', [UserController::class, 'updatePreferences']);

        // Activity log
        Route::get('/activity', [UserController::class, 'getActivity']);

        // Data export & sync
        Route::get('/export', [UserController::class, 'exportData']);
        Route::get('/sync', [UserController::class, 'getSyncData']);
        Route::post('/sync', [UserController::class, 'postSyncData']);

        // Subject management
        Route::prefix('subjects')->group(function () {
            Route::get('/', [UserSubjectController::class, 'index']);
            Route::get('/{subject_id}', [UserSubjectController::class, 'show']);
            Route::put('/{subject_id}', [UserSubjectController::class, 'update']);
            Route::post('/recalculate-priorities', [UserSubjectController::class, 'recalculatePriorities']);
            Route::post('/{subject_id}/toggle-favorite', [UserSubjectController::class, 'toggleFavorite']);
        });

        // Statistics & Analytics (rate limited to prevent abuse)
        Route::prefix('stats')->middleware('throttle:30,1')->group(function () { // 30 requests per minute
            Route::get('/', [UserStatsController::class, 'index']);
            Route::get('/heatmap', [UserStatsController::class, 'heatmap']);
            Route::get('/performance', [UserStatsController::class, 'performance']);
            Route::get('/subjects-breakdown', [UserStatsController::class, 'subjectsBreakdown']);
            Route::get('/weekly-summary', [UserStatsController::class, 'weeklySummary']);
            Route::get('/streak', [UserStatsController::class, 'streak']);
            Route::get('/summary', [UserStatsController::class, 'summary']);
        });
    });
});

// Legacy user route (for backward compatibility)
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// ===== LEGACY PLANNER ROUTES (for backward compatibility without /v1 prefix) =====
// Standard rate limit: 60 requests per minute for most endpoints
Route::middleware(['auth:sanctum', 'throttle:60,1'])->prefix('planner')->group(function () {
    Route::get('/dashboard', [PlannerController::class, 'getDashboard']);

    // Settings - stricter limit (10/min) as it involves database writes
    Route::get('/settings', [PlannerController::class, 'getSettings']);
    Route::post('/settings', [PlannerController::class, 'updateSettings'])->middleware('throttle:10,1');

    // Gamification & Points - cache-friendly, higher limit
    Route::get('/points/history', [PlannerController::class, 'getPointsHistory']);
    Route::get('/achievements', [PlannerController::class, 'getAchievements']);

    // Schedule management - generation is expensive, limit to 5/min
    Route::get('/schedules', [PlannerController::class, 'getSchedules']);
    Route::post('/schedules/generate', [PlannerController::class, 'generateSchedule'])->middleware('throttle:30,1');
    Route::get('/schedules/active', [PlannerController::class, 'getActiveSchedule']);
    Route::get('/schedules/{id}', [PlannerController::class, 'getSchedule']);
    Route::post('/schedules/{id}/activate', [PlannerController::class, 'activateSchedule'])->middleware('throttle:10,1');
    Route::delete('/schedules/{id}', [PlannerController::class, 'deleteSchedule'])->middleware('throttle:10,1');

    // Study Sessions
    Route::prefix('sessions')->group(function () {
        Route::get('/today', [PlannerController::class, 'getTodaySessions']);
        Route::get('/range', [StudySessionController::class, 'getSessionsInRange']);
        Route::get('/{id}', [StudySessionController::class, 'getSession']);

        // CRUD operations - moderate limit (20/min)
        Route::post('/', [StudySessionController::class, 'createSession'])->middleware('throttle:20,1');
        Route::put('/{id}', [StudySessionController::class, 'updateSession'])->middleware('throttle:20,1');
        Route::delete('/{id}', [StudySessionController::class, 'deleteSession'])->middleware('throttle:20,1');
        Route::delete('/', [StudySessionController::class, 'deleteAll'])->middleware('throttle:3,1'); // Dangerous, very strict

        // Session actions - moderate limit (30/min) for normal usage
        Route::post('/{id}/start', [PlannerController::class, 'startSession'])->middleware('throttle:30,1');
        Route::post('/{id}/pause', [PlannerController::class, 'pauseSession'])->middleware('throttle:30,1');
        Route::post('/{id}/resume', [PlannerController::class, 'resumeSession'])->middleware('throttle:30,1');
        Route::post('/{id}/complete', [PlannerController::class, 'completeSession'])->middleware('throttle:30,1');
        Route::post('/{id}/skip', [PlannerController::class, 'skipSession'])->middleware('throttle:30,1');
    });

    // Subjects
    Route::get('/subjects', [PlannerController::class, 'getSubjects']);
    Route::post('/subjects/batch', [PlannerController::class, 'batchCreateSubjects'])->middleware('throttle:5,1'); // Heavy operation

    // Adaptation - expensive AI operation, very strict limit (3/min)
    Route::post('/adapt', [PlannerController::class, 'triggerAdaptation'])->middleware('throttle:3,1');
});

// ===== CURRICULUM CONTENT ROUTES (Subject Planner Content) =====
Route::middleware(['auth:sanctum', 'throttle:60,1'])->prefix('curriculum')->group(function () {
    // Get full curriculum tree for user's stream
    Route::get('/', [SubjectPlannerContentController::class, 'index']);

    // Get curriculum for specific subject
    Route::get('/subject/{subjectId}', [SubjectPlannerContentController::class, 'getBySubject']);

    // Get next content items to study for a session (for planner integration)
    Route::get('/subject/{subjectId}/next-session-content', [SubjectPlannerContentController::class, 'getNextSessionContent']);

    // Get specific curriculum content item with details
    Route::get('/content/{id}', [SubjectPlannerContentController::class, 'show']);

    // Get content for specific unit/topic (for session detail screen)
    Route::get('/content/{id}/session-content', [SubjectPlannerContentController::class, 'getContentSessionContent']);

    // Progress management
    Route::get('/content/{id}/progress', [SubjectPlannerContentController::class, 'getProgress']);
    Route::post('/content/{id}/progress', [SubjectPlannerContentController::class, 'updateProgress'])->middleware('throttle:30,1');

    // BAC priority content
    Route::get('/bac-priority', [SubjectPlannerContentController::class, 'getBacPriority']);

    // Spaced repetition - items due for review
    Route::get('/due-for-review', [SubjectPlannerContentController::class, 'getDueForReview']);

    // User statistics
    Route::get('/statistics', [SubjectPlannerContentController::class, 'getStatistics']);

    // Search curriculum
    Route::get('/search', [SubjectPlannerContentController::class, 'search']);
});

// ===== PAYMENT RECEIPTS ROUTES (without v1 prefix for Flutter app compatibility) =====
Route::middleware('auth:sanctum')->prefix('payment-receipts')->group(function () {
    Route::get('/my-receipts', [SubscriptionApiController::class, 'myPaymentReceipts']);
    Route::get('/{id}', [SubscriptionApiController::class, 'receiptDetails']);
});

// ===== API V1 ROUTES (New Content Management System) =====

Route::prefix('v1')->group(function () {

    // ===== V1 AUTHENTICATION ROUTES =====

    // Public authentication routes (no auth required) - with strict rate limiting
    Route::middleware('throttle:10,1')->prefix('auth')->group(function () {
        Route::post('/register', [V1AuthController::class, 'register']);
        Route::post('/login', [V1AuthController::class, 'login']);
        Route::post('/google', [V1AuthController::class, 'loginWithGoogle']);
        Route::post('/device-transfer/request', [V1AuthController::class, 'requestDeviceTransfer']);
        Route::post('/forgot-password', [V1AuthController::class, 'forgotPassword']);
        Route::post('/verify-reset-code', [V1AuthController::class, 'verifyResetCode']);
        Route::post('/reset-password', [V1AuthController::class, 'resetPassword']);
    });

    // Protected authentication routes (auth required)
    Route::middleware('auth:sanctum')->prefix('auth')->group(function () {
        Route::post('/logout', [V1AuthController::class, 'logout']);
        Route::post('/logout-all', [V1AuthController::class, 'logoutAll']);
        Route::get('/validate-token', [V1AuthController::class, 'validateToken']);
        Route::get('/me', [V1AuthController::class, 'me']);
        Route::post('/refresh-token', [V1AuthController::class, 'refresh']);

        // Device transfer management
        Route::get('/device-transfer/my-requests', [V1AuthController::class, 'myDeviceTransferRequests']);

        // Admin only device transfer routes
        Route::middleware('admin')->group(function () {
            Route::get('/device-transfer/pending', [V1AuthController::class, 'pendingDeviceTransferRequests']);
            Route::post('/device-transfer/approve/{id}', [V1AuthController::class, 'approveDeviceTransfer']);
            Route::post('/device-transfer/reject/{id}', [V1AuthController::class, 'rejectDeviceTransfer']);
        });
    });

    // Public routes - Academic Structure
    Route::prefix('academic')->group(function () {
        Route::get('/structure', [V1AcademicController::class, 'structure']);
        Route::get('/phases', [V1AcademicController::class, 'phases']);
        Route::get('/phases/{phaseId}/years', [V1AcademicController::class, 'years']);
        Route::get('/years/{yearId}/streams', [V1AcademicController::class, 'streams']);

        // Subjects under academic prefix (for compatibility with Flutter app)
        Route::get('/subjects', [V1SubjectController::class, 'index']);
        Route::get('/subjects/{id}', [V1SubjectController::class, 'show']);
    });

    // Public routes - Subjects
    Route::prefix('subjects')->group(function () {
        Route::get('/', [V1SubjectController::class, 'index']);
        Route::get('/by-academic', [V1SubjectController::class, 'byAcademic']);
        Route::get('/{id}', [V1SubjectController::class, 'show']);
    });

    // Public routes - Contents (listing and viewing)
    // Note: These routes use optional auth middleware to include user progress when authenticated
    Route::prefix('contents')->middleware('auth:sanctum')->group(function () {
        Route::get('/', [V1ContentController::class, 'index']);
        Route::get('/search', [V1ContentController::class, 'search']);
        Route::get('/types', [V1ContentController::class, 'types']);
        Route::get('/chapters', [V1ContentController::class, 'chapters']);
        Route::get('/chapter/{chapterId}', [V1ContentController::class, 'byChapter']);
        Route::get('/{id}', [V1ContentController::class, 'show']);
    });

    // Protected routes - Progress & Interactions (require authentication)
    Route::middleware('auth:sanctum')->group(function () {

        // Profile routes
        Route::prefix('profile')->group(function () {
            Route::get('/', [ProfileController::class, 'getProfile']);
            Route::put('/', [ProfileController::class, 'updateProfile']);
            Route::post('/update', [ProfileController::class, 'updateAcademicProfile']);
            Route::post('/academic', [ProfileController::class, 'updateAcademicProfile']);
            Route::post('/photo', [ProfileController::class, 'uploadPhoto']);
            Route::post('/change-password', [ProfileController::class, 'changePassword']);
            Route::get('/stats', [ProfileController::class, 'getStats']);
            Route::post('/export', [ProfileController::class, 'exportData']);
            Route::post('/delete-account', [ProfileController::class, 'deleteAccount']);
        });

        // V1 Statistics Routes (alias to main statistics routes)
        Route::prefix('statistics')->group(function () {
            Route::get('/', [StatisticsController::class, 'getStatistics']);
            Route::get('/weekly', [StatisticsController::class, 'getWeeklyChart']);
            Route::get('/subjects', [StatisticsController::class, 'getSubjectBreakdown']);
            Route::get('/achievements', [StatisticsController::class, 'getAchievements']);
            Route::get('/streak-calendar', [StatisticsController::class, 'getStreakCalendar']);
        });

        // V1 Sessions/Devices Routes (alias for Flutter compatibility)
        Route::prefix('sessions')->group(function () {
            Route::get('/devices', [DeviceSessionController::class, 'index']);
            Route::put('/device', [DeviceSessionController::class, 'update']);
            Route::delete('/devices/{sessionId}', [DeviceSessionController::class, 'logout']);
            Route::delete('/devices', [DeviceSessionController::class, 'logoutAllOthers']);
            Route::get('/statistics', [DeviceSessionController::class, 'statistics']);
        });

        // Content Download
        Route::get('/contents/{id}/download', [V1ContentController::class, 'download']);

        // Content File Stream (for files not in public storage)
        Route::get('/contents/{id}/file', [V1ContentController::class, 'streamFile']);

        // Content View/Download Tracking
        Route::post('/contents/{id}/view', [ContentController::class, 'recordView']);
        Route::post('/contents/{id}/record-download', [ContentController::class, 'recordDownload']);

        // Progress tracking
        Route::prefix('progress')->group(function () {
            Route::get('/all', [V1ProgressController::class, 'allProgress']);
            Route::get('/subject/{subjectId}', [V1ProgressController::class, 'subjectProgress']);
            Route::get('/content/{contentId}', [V1ProgressController::class, 'getProgress']);
            Route::post('/content/{contentId}', [V1ProgressController::class, 'updateProgress']);
            Route::post('/content/{contentId}/complete', [V1ProgressController::class, 'markCompleted']);
        });

        // Content rating
        Route::prefix('ratings')->group(function () {
            Route::get('/content/{contentId}', [V1ProgressController::class, 'getRating']);
            Route::post('/content/{contentId}', [V1ProgressController::class, 'rateContent']);
        });

        // Content bookmarks
        Route::prefix('bookmarks')->group(function () {
            Route::get('/', [V1BookmarkController::class, 'index']);
            Route::get('/count', [V1BookmarkController::class, 'count']);
            Route::post('/content/{contentId}', [V1BookmarkController::class, 'store']);
            Route::get('/content/{contentId}/check', [V1BookmarkController::class, 'check']);
            Route::delete('/content/{contentId}', [V1BookmarkController::class, 'destroy']);
        });

        // BAC subject bookmarks
        Route::prefix('bac-bookmarks')->group(function () {
            Route::get('/', [V1BacBookmarkController::class, 'index']);
            Route::get('/count', [V1BacBookmarkController::class, 'count']);
            Route::post('/bac-subject/{bacSubjectId}', [V1BacBookmarkController::class, 'toggle']);
            Route::get('/bac-subject/{bacSubjectId}/check', [V1BacBookmarkController::class, 'check']);
            Route::delete('/bac-subject/{bacSubjectId}', [V1BacBookmarkController::class, 'destroy']);
        });

        // ===== INTELLIGENT PLANNER ROUTES =====
        // Rate limiting applied per endpoint based on resource intensity

        // Planner settings and schedule management
        Route::prefix('planner')->group(function () {
            Route::get('/dashboard', [PlannerController::class, 'getDashboard']);

            // Settings - stricter limit for writes (10/min)
            Route::get('/settings', [PlannerController::class, 'getSettings']);
            Route::post('/settings', [PlannerController::class, 'updateSettings'])->middleware('throttle:10,1');
            Route::put('/settings/{userId}', [PlannerController::class, 'updateSettings'])->middleware('throttle:10,1');

            // Gamification & Points - standard limit
            Route::get('/points/history', [PlannerController::class, 'getPointsHistory']);
            Route::get('/achievements', [PlannerController::class, 'getAchievements']);

            // Schedule management - generation is expensive (5/min)
            Route::get('/schedules', [PlannerController::class, 'getSchedules']);
            Route::post('/schedules/generate', [PlannerController::class, 'generateSchedule'])->middleware('throttle:30,1');
            Route::get('/schedules/{id}', [PlannerController::class, 'getSchedule']);
            Route::post('/schedules/{id}/activate', [PlannerController::class, 'activateSchedule'])->middleware('throttle:10,1');
            Route::delete('/schedules/{id}', [PlannerController::class, 'deleteSchedule'])->middleware('throttle:10,1');

            // Study Sessions
            Route::prefix('sessions')->group(function () {
                // Session queries - standard limit
                Route::get('/today', [PlannerController::class, 'getTodaySessions']);
                Route::get('/range', [ApiPlannerController::class, 'getSessionsInRange']);
                Route::get('/spaced-reviews', [PlannerController::class, 'getSpacedReviewsDue']);
                Route::get('/{id}', [PlannerController::class, 'getSessionWithContent']);

                // Session CRUD - moderate limit (20/min)
                Route::post('/', [StudySessionController::class, 'createSession'])->middleware('throttle:20,1');
                Route::put('/{id}', [StudySessionController::class, 'updateSession'])->middleware('throttle:20,1');
                Route::delete('/{id}', [StudySessionController::class, 'deleteSession'])->middleware('throttle:20,1');
                Route::delete('/', [StudySessionController::class, 'deleteAll'])->middleware('throttle:3,1'); // Very strict - dangerous operation

                // Session actions - moderate limit (30/min)
                Route::post('/{id}/start', [PlannerController::class, 'startSession'])->middleware('throttle:30,1');
                Route::post('/{id}/pause', [PlannerController::class, 'pauseSession'])->middleware('throttle:30,1');
                Route::post('/{id}/resume', [PlannerController::class, 'resumeSession'])->middleware('throttle:30,1');
                Route::post('/{id}/complete', [PlannerController::class, 'completeSessionWithProgress'])->middleware('throttle:30,1');
                Route::post('/{id}/skip', [PlannerController::class, 'skipSession'])->middleware('throttle:30,1');
            });

            // Adaptation - expensive AI operation (3/min)
            Route::post('/adapt', [PlannerController::class, 'triggerAdaptation'])->middleware('throttle:3,1');
        });

        // Study sessions - Additional statistics endpoints (use /planner/sessions for main CRUD)
        Route::prefix('sessions')->group(function () {
            Route::get('/upcoming', [StudySessionController::class, 'getUpcomingSessions']);
            Route::get('/current', [StudySessionController::class, 'getCurrentSession']);
            Route::get('/statistics', [StudySessionController::class, 'getStatistics']);
            Route::get('/history', [StudySessionController::class, 'getSessionHistory']);

            // Additional session actions not in /planner/sessions
            Route::post('/{id}/missed', [StudySessionController::class, 'markAsMissed']);
            Route::post('/{id}/reschedule', [StudySessionController::class, 'rescheduleSession']);
            Route::post('/{id}/pin', [StudySessionController::class, 'togglePin']);
        });

        // Subject priorities
        Route::prefix('priorities')->group(function () {
            Route::get('/', [PriorityController::class, 'getPriorities']);
            Route::get('/top', [PriorityController::class, 'getTopPriorities']);
            Route::get('/subject/{subjectId}', [PriorityController::class, 'getSubjectPriority']);
            Route::post('/recalculate', [PriorityController::class, 'recalculateAll']);
            Route::post('/subject/{subjectId}/recalculate', [PriorityController::class, 'recalculateSubject']);
        });

        // Planner-specific Subject CRUD (only for scheduling)
        Route::prefix('planner/subjects')->group(function () {
            // Batch create subjects (atomic transaction)
            Route::post('/batch', [PlannerSubjectsController::class, 'batchCreate']);

            Route::get('/', [PlannerSubjectController::class, 'index']);
            Route::post('/', [PlannerSubjectController::class, 'store']);
            Route::get('/{id}', [PlannerSubjectController::class, 'show']);
            Route::put('/{id}', [PlannerSubjectController::class, 'update']);
            Route::delete('/{id}', [PlannerSubjectController::class, 'destroy']);
        });

        // ===== V1 PLANNER API (NEW - Complete Implementation) =====
        // NOTE: Already inside 'v1' prefix from line 191, so just use 'planner' here
        // Rate limiting applied based on operation cost
        Route::prefix('planner')->group(function () {
            // 1. Batch create subjects - heavy operation (5/min)
            Route::post('/subjects/batch', [PlannerController::class, 'batchCreateSubjects'])->middleware('throttle:5,1');

            // 2. Get subjects - using V1 PlannerSubjectsController which auto-initializes from academic profile
            Route::get('/subjects', [\App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'index']);
            Route::put('/subjects/{id}', [\App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'update']);

            // 3. Generate schedule - expensive (5/min)
            Route::post('/schedules/generate', [PlannerController::class, 'generateSchedule'])->middleware('throttle:30,1');

            // 4. Get active schedule - standard limit
            Route::get('/schedules/active', [PlannerController::class, 'getDashboard']);

            // 5-6. Session management - moderate limit (30/min)
            Route::post('/sessions/{id}/start', [StudySessionController::class, 'startSession'])->middleware('throttle:30,1');
            Route::post('/sessions/{id}/complete', [StudySessionController::class, 'completeSession'])->middleware('throttle:30,1');

            // 7-8. Settings - stricter limit for writes (10/min)
            Route::get('/settings', [PlannerController::class, 'getSettings']);
            Route::put('/settings', [PlannerController::class, 'updateSettings'])->middleware('throttle:10,1');

            // 9-10. Gamification - standard limit
            Route::get('/points/history', [PlannerController::class, 'getPointsHistory']);
            Route::get('/achievements', [PlannerController::class, 'getAchievements']);

            // 11-15. Exam management - moderate limit (20/min for writes)
            Route::post('/exams', [ExamController::class, 'store'])->middleware('throttle:20,1');
            Route::get('/exams', [ExamController::class, 'index']);
            Route::put('/exams/{id}', [ExamController::class, 'update'])->middleware('throttle:20,1');
            Route::delete('/exams/{id}', [ExamController::class, 'destroy'])->middleware('throttle:20,1');
            Route::post('/exams/{id}/result', [ExamController::class, 'recordResult'])->middleware('throttle:20,1');

            // 16-17. Schedule adaptation - expensive AI operation (3/min)
            Route::post('/schedules/{id}/adapt', [PlannerController::class, 'triggerAdaptation'])->middleware('throttle:3,1');
            Route::put('/sessions/{id}/reschedule', [StudySessionController::class, 'rescheduleSession'])->middleware('throttle:20,1');
        });

        // Exam CRUD (for planner feature)
        Route::prefix('exams')->group(function () {
            Route::get('/', [ExamController::class, 'index']);
            Route::post('/', [ExamController::class, 'store']);
            Route::get('/{id}', [ExamController::class, 'show']);
            Route::put('/{id}', [ExamController::class, 'update']);
            Route::delete('/{id}', [ExamController::class, 'destroy']);
            // CRITICAL: Record exam result and trigger adaptation
            Route::post('/{id}/result', [ExamController::class, 'recordResult']);
        });

        // Prayer Times (for planner feature)
        Route::prefix('prayer-times')->group(function () {
            Route::get('/', [PrayerTimesController::class, 'getPrayerTimes']);
            Route::post('/sync', [PrayerTimesController::class, 'syncPrayerTimes']);
        });

        // Quizzes
        Route::prefix('quizzes')->group(function () {
            // List and details
            Route::get('/', [QuizController::class, 'index']);
            Route::get('/recommended', [QuizController::class, 'recommended']);
            Route::get('/my-attempts', [QuizController::class, 'myAttempts']);
            Route::get('/performance', [QuizController::class, 'performance']);
            Route::get('/{id}', [QuizController::class, 'show']);

            // Start quiz
            Route::post('/{id}/start', [QuizController::class, 'start']);
        });

        // Quiz attempts
        Route::prefix('quiz-attempts')->group(function () {
            Route::get('/current', [QuizAttemptController::class, 'current']);
            Route::post('/{id}/answer', [QuizAttemptController::class, 'answer']);

            // Strict rate limiting on quiz submission (10 per minute)
            Route::middleware('throttle:10,1')->group(function () {
                Route::post('/{id}/submit', [QuizAttemptController::class, 'submit']);
            });

            Route::get('/{id}/results', [QuizAttemptController::class, 'results']);
            Route::get('/{id}/review', [QuizAttemptController::class, 'review']);
            Route::delete('/{id}/abandon', [QuizAttemptController::class, 'abandon']);
        });

        // ===== LEADERBOARD ROUTES =====
        Route::prefix('leaderboard')->group(function () {
            Route::get('/stream', [LeaderboardController::class, 'byStream']);
            Route::get('/subject/{subjectId}', [LeaderboardController::class, 'bySubject']);
        });

        // ===== BAC ARCHIVES ROUTES =====

        Route::prefix('bac')->group(function () {
            // Public browsing endpoints
            Route::get('/years', [BacArchiveController::class, 'getBacYears'])->withoutMiddleware('auth:sanctum');
            Route::get('/years/{yearSlug}/subjects', [BacArchiveController::class, 'getSubjectsByYear'])->withoutMiddleware('auth:sanctum');
            Route::get('/years/{yearSlug}/sessions', [BacArchiveController::class, 'getBacSessions'])->withoutMiddleware('auth:sanctum');
            Route::get('/sessions/{sessionSlug}/subjects', [BacArchiveController::class, 'getBacSubjects'])->withoutMiddleware('auth:sanctum');
            Route::get('/subjects/{subjectSlug}/chapters', [BacArchiveController::class, 'getBacChapters'])->withoutMiddleware('auth:sanctum');
            Route::get('/exams-by-subject', [BacArchiveController::class, 'getExamsBySubject'])->withoutMiddleware('auth:sanctum');

            // Legacy public browsing (with filters)
            Route::get('/filters', [BacArchiveController::class, 'filters'])->withoutMiddleware('auth:sanctum');
            Route::get('/browse', [BacArchiveController::class, 'browse'])->withoutMiddleware('auth:sanctum');
            Route::get('/{id}', [BacArchiveController::class, 'show'])->withoutMiddleware('auth:sanctum');

            // Download (requires signed URL)
            Route::get('/{id}/download', [BacArchiveController::class, 'download'])->name('api.bac.download');

            // Stream file directly (public, no signature required)
            Route::get('/{id}/stream', [BacArchiveController::class, 'streamFile'])->withoutMiddleware('auth:sanctum');

            // Simulation management (requires authentication)
            Route::post('/{id}/simulation/start', [BacArchiveController::class, 'startSimulation']);
            Route::get('/simulation/active', [BacArchiveController::class, 'getActiveSimulation']);
            Route::post('/simulation/{id}/submit', [BacArchiveController::class, 'submitSimulation']);
            Route::post('/simulation/{id}/abandon', [BacArchiveController::class, 'abandonSimulation']);
            Route::get('/simulations/history', [BacArchiveController::class, 'simulationHistory']);

            // Performance tracking (requires authentication)
            Route::get('/performance', [BacArchiveController::class, 'getAllPerformances']);
            Route::get('/performance/{subjectId}', [BacArchiveController::class, 'getPerformance']);

            // Recommendations (requires authentication)
            Route::get('/recommendations', [BacArchiveController::class, 'getRecommendations']);
        });

        // ===== PAID COURSES ROUTES =====

        // Courses (Public browsing)
        Route::prefix('courses')->withoutMiddleware('auth:sanctum')->group(function () {
            Route::get('/', [CourseApiController::class, 'index']);
            Route::get('/featured', [CourseApiController::class, 'featured']);
            Route::get('/complete', [CourseApiController::class, 'complete']); // OPTIMIZED: Single call for courses page
            Route::get('/search', [CourseApiController::class, 'search']);
            Route::get('/{id}', [CourseApiController::class, 'show']);
            Route::get('/{id}/modules', [CourseApiController::class, 'modules']);
            Route::get('/{id}/stats', [CourseApiController::class, 'stats']);
        });

        // Lessons (Requires authentication)
        Route::get('/lessons/{id}', [CourseApiController::class, 'lesson']);

        // Subscriptions (Requires authentication)
        Route::prefix('subscriptions')->group(function () {
            Route::get('/my-subscriptions', [SubscriptionApiController::class, 'mySubscriptions']);
            Route::post('/redeem-code', [SubscriptionApiController::class, 'redeemCode']);
            Route::post('/validate-code', [SubscriptionApiController::class, 'validateCode']);
            Route::post('/submit-receipt', [SubscriptionApiController::class, 'submitReceipt']);
            Route::get('/my-payment-receipts', [SubscriptionApiController::class, 'myPaymentReceipts']);
            Route::get('/payment-receipts/{id}', [SubscriptionApiController::class, 'receiptDetails']);
            Route::get('/my-stats', [SubscriptionApiController::class, 'myStats']);
        });

        // Subscription Packages (Public)
        Route::get('/subscription-packages', [SubscriptionApiController::class, 'packages'])->withoutMiddleware('auth:sanctum');

        // Payment Receipts (alternative route for Flutter app)
        Route::prefix('payment-receipts')->group(function () {
            Route::get('/my-receipts', [SubscriptionApiController::class, 'myPaymentReceipts']);
            Route::get('/{id}', [SubscriptionApiController::class, 'receiptDetails']);
        });

        // Course Access Check (Requires authentication)
        Route::get('/courses/{id}/check-access', [SubscriptionApiController::class, 'checkCourseAccess']);

        // ===== COUPONS ROUTES =====
        Route::post('/coupons/validate', [CouponController::class, 'validate']);

        // ===== ORDERS ROUTES =====
        Route::prefix('orders')->group(function () {
            Route::post('/create', [OrderController::class, 'create']);
            Route::post('/{orderNumber}/verify', [OrderController::class, 'verify']);
            Route::get('/my-orders', [OrderController::class, 'myOrders']);
            Route::get('/{orderNumber}', [OrderController::class, 'show']);
        });

        // ===== CERTIFICATES ROUTES =====
        // Generate certificate for completed course
        Route::post('/courses/{id}/certificate', [CertificateController::class, 'generate']);

        Route::prefix('certificates')->group(function () {
            Route::get('/my-certificates', [CertificateController::class, 'myCertificates']);
            Route::get('/{certificateNumber}/download', [CertificateController::class, 'download']);
        });

        // Public certificate verification (no auth required)
        Route::get('/certificates/{certificateNumber}/verify', [CertificateController::class, 'verify'])
            ->withoutMiddleware('auth:sanctum');

        // Progress Tracking (Requires authentication)
        Route::prefix('progress')->group(function () {
            Route::post('/lessons/{id}/progress', [ProgressApiController::class, 'updateLessonProgress']);
            Route::post('/lessons/{id}/complete', [ProgressApiController::class, 'completeLesson']);
            Route::get('/lessons/{id}/my-progress', [ProgressApiController::class, 'lessonProgress']);
            Route::get('/courses/{id}/my-progress', [ProgressApiController::class, 'courseProgress']);
            Route::get('/courses/{id}/next-lesson', [ProgressApiController::class, 'nextLesson']);
            Route::get('/courses/{id}/certificate', [ProgressApiController::class, 'certificate']);
            Route::get('/my-stats', [ProgressApiController::class, 'myStatistics']);
            Route::get('/my-recent-activity', [ProgressApiController::class, 'recentActivity']);
            Route::get('/my-courses', [ProgressApiController::class, 'myCourses']);
        });

        // Reviews (Mixed authentication)
        Route::prefix('reviews')->group(function () {
            // Public
            Route::get('/', [ReviewApiController::class, 'index'])->withoutMiddleware('auth:sanctum');
            Route::get('/courses/{id}/reviews', [ReviewApiController::class, 'courseReviews'])->withoutMiddleware('auth:sanctum');

            // Requires authentication
            Route::post('/courses/{id}/review', [ReviewApiController::class, 'store']);
            Route::put('/{id}', [ReviewApiController::class, 'update']);
            Route::delete('/{id}', [ReviewApiController::class, 'destroy']);
            Route::get('/my-reviews', [ReviewApiController::class, 'myReviews']);
            Route::get('/courses/{id}/can-review', [ReviewApiController::class, 'canReview']);
        });

        // Admin Routes (Requires admin middleware)
        Route::middleware('admin')->prefix('admin')->group(function () {
            // Payment Receipts Management
            Route::prefix('payment-receipts')->group(function () {
                Route::get('/', [SubscriptionApiController::class, 'adminListReceipts']);
                Route::post('/{id}/approve', [SubscriptionApiController::class, 'adminApproveReceipt']);
                Route::post('/{id}/reject', [SubscriptionApiController::class, 'adminRejectReceipt']);
            });
        });

        // Notifications
        Route::prefix('notifications')->name('notifications.')->group(function () {
            Route::get('/', [NotificationController::class, 'index'])->name('index');
            Route::get('/unread-count', [NotificationController::class, 'unreadCount'])->name('unreadCount');
            Route::post('/{id}/read', [NotificationController::class, 'markAsRead'])->name('markAsRead');
            Route::post('/read-all', [NotificationController::class, 'markAllAsRead'])->name('markAllAsRead');
            Route::delete('/{id}', [NotificationController::class, 'destroy'])->name('destroy');

            // Notification settings
            Route::get('/settings', [NotificationController::class, 'getSettings'])->name('settings');
            Route::put('/settings', [NotificationController::class, 'updateSettings'])->name('updateSettings');

            // FCM Device token management
            Route::post('/register-device', [NotificationController::class, 'registerDevice'])->name('registerDevice');
            Route::delete('/unregister-device', [NotificationController::class, 'unregisterDevice'])->name('unregisterDevice');
            Route::post('/refresh-token', [NotificationController::class, 'refreshToken'])->name('refreshToken');
            Route::get('/devices', [NotificationController::class, 'getDevices'])->name('devices');
        });

        // Analytics
        Route::prefix('analytics')->name('analytics.')->group(function () {
            Route::get('/dashboard', [AnalyticsController::class, 'dashboard'])->name('dashboard');
            Route::get('/overview', [AnalyticsController::class, 'overview'])->name('overview');
            Route::get('/trends', [AnalyticsController::class, 'trends'])->name('trends');
            Route::get('/heatmap', [AnalyticsController::class, 'heatmap'])->name('heatmap');
            Route::get('/report', [AnalyticsController::class, 'report'])->name('report');
            Route::get('/compare', [AnalyticsController::class, 'compare'])->name('compare');
            Route::get('/patterns', [AnalyticsController::class, 'patterns'])->name('patterns');
            Route::get('/recommendations', [AnalyticsController::class, 'recommendations'])->name('recommendations');
            Route::get('/planner', [AnalyticsController::class, 'plannerAnalytics'])->name('planner');

            // Subject-specific analytics (must be before {subject_id} to avoid route conflicts)
            Route::get('/subjects/compare', [AnalyticsController::class, 'compareSubjects'])->name('subjects.compare');
            Route::get('/subjects/{subject_id}', [AnalyticsController::class, 'subjectAnalytics'])->name('subjects.show');

            // Weak areas endpoints
            Route::get('/weak-areas', [AnalyticsController::class, 'weakAreas'])->name('weakAreas.index');
            Route::get('/weak-areas/{topic_id}', [AnalyticsController::class, 'weakAreaDetail'])->name('weakAreas.show');
            Route::post('/weak-areas/{topic_id}/create-plan', [AnalyticsController::class, 'createImprovementPlan'])->name('weakAreas.createPlan');

            // Progress tracking
            Route::get('/progress', [AnalyticsController::class, 'progress'])->name('progress');

            // Export (POST for enhanced options)
            Route::post('/export', [AnalyticsController::class, 'exportReport'])->name('export');
        });

        // Sync endpoints for offline support
        Route::prefix('sync')->name('sync.')->group(function () {
            Route::get('/', [\App\Http\Controllers\Api\SyncController::class, 'sync'])->name('index');
            Route::post('/upload', [\App\Http\Controllers\Api\SyncController::class, 'upload'])->name('upload');
        });

        // Dashboard / Home Screen
        Route::prefix('dashboard')->name('dashboard.')->group(function () {
            Route::get('/', [DashboardController::class, 'getDashboard'])->name('index');

            // OPTIMIZED: Unified endpoint combines 6 API calls into 1
            // Returns: stats, today_sessions, subjects_progress, featured_courses, sponsors, promos
            Route::get('/complete', [DashboardController::class, 'getComplete'])->name('complete');

            // Flutter-compatible endpoints (kept for backward compatibility)
            Route::get('/stats', [DashboardController::class, 'getStats'])->name('stats');
            Route::get('/today-sessions', [DashboardController::class, 'getTodaySessions'])->name('todaySessions');
        });

        // ===== PDF MANAGEMENT =====
        Route::prefix('pdfs')->name('pdfs.')->group(function () {
            // Upload PDF to public/planner folder
            Route::post('/upload', [PdfController::class, 'uploadPlannerPdf'])->name('upload');

            // List PDFs in planner folder
            Route::get('/list', [PdfController::class, 'listPlannerPdfs'])->name('list');

            // Delete PDF
            Route::delete('/delete', [PdfController::class, 'deletePlannerPdf'])->name('delete');

            // Clean old PDFs (admin only - add middleware if needed)
            Route::post('/clean', [PdfController::class, 'cleanOldPdfs'])->name('clean');
        });

        // ===== FLASHCARDS ROUTES =====
        // Spaced Repetition Flashcards Feature

        // Flashcard Decks (browsing)
        Route::prefix('flashcard-decks')->group(function () {
            // Public - deck listing and preview
            Route::get('/', [\App\Http\Controllers\Api\FlashcardDeckController::class, 'index'])->withoutMiddleware('auth:sanctum');
            Route::get('/due', [\App\Http\Controllers\Api\FlashcardDeckController::class, 'withDueCards']);
            Route::get('/{id}', [\App\Http\Controllers\Api\FlashcardDeckController::class, 'show'])->withoutMiddleware('auth:sanctum');
            Route::get('/{id}/cards', [\App\Http\Controllers\Api\FlashcardDeckController::class, 'cards']);
        });

        // Flashcards (due for review)
        Route::prefix('flashcards')->group(function () {
            Route::get('/due', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'getDueCards']);
            Route::get('/new', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'getNewCards']);
        });

        // Flashcard Review Sessions
        Route::prefix('flashcard-reviews')->group(function () {
            Route::post('/start', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'start'])->middleware('throttle:30,1');
            Route::get('/current', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'getCurrentSession']);
            Route::post('/{sessionId}/answer', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'submitAnswer'])->middleware('throttle:60,1');
            Route::post('/{sessionId}/complete', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'complete']);
            Route::post('/{sessionId}/abandon', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'abandon']);
            Route::get('/history', [\App\Http\Controllers\Api\FlashcardReviewController::class, 'history']);
        });

        // Flashcard Statistics
        Route::prefix('flashcard-stats')->group(function () {
            Route::get('/', [\App\Http\Controllers\Api\FlashcardStatsController::class, 'index']);
            Route::get('/forecast', [\App\Http\Controllers\Api\FlashcardStatsController::class, 'forecast']);
            Route::get('/heatmap', [\App\Http\Controllers\Api\FlashcardStatsController::class, 'heatmap']);
            Route::get('/today', [\App\Http\Controllers\Api\FlashcardStatsController::class, 'todaySummary']);
            Route::get('/deck/{deckId}', [\App\Http\Controllers\Api\FlashcardStatsController::class, 'deckStats']);
        });
    });
});

// Public PDF download route (no auth required)
Route::get('/planner/{fileName}', [PdfController::class, 'downloadPlannerPdf'])->name('pdf.download');
