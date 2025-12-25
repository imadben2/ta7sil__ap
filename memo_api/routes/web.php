<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\UserController as AdminUserController;
use App\Http\Controllers\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Admin\AcademicPhaseController;
use App\Http\Controllers\Admin\AcademicYearController;
use App\Http\Controllers\Admin\AcademicStreamController;
use App\Http\Controllers\Admin\SubjectController as AdminSubjectController;
use App\Http\Controllers\Admin\ContentController as AdminContentController;
use App\Http\Controllers\Admin\ChapterController as AdminChapterController;
use App\Http\Controllers\Admin\PlannerController as AdminPlannerController;
use App\Http\Controllers\Admin\QuizController as AdminQuizController;
use App\Http\Controllers\Admin\BacController as AdminBacController;
use App\Http\Controllers\Admin\CourseController as AdminCourseController;
use App\Http\Controllers\Admin\CourseModuleController as AdminCourseModuleController;
use App\Http\Controllers\Admin\CourseLessonController as AdminCourseLessonController;
use App\Http\Controllers\Admin\SubscriptionController as AdminSubscriptionController;
use App\Http\Controllers\Admin\SubscriptionCodeController as AdminSubscriptionCodeController;
use App\Http\Controllers\Admin\SubscriptionCodeListController as AdminSubscriptionCodeListController;
use App\Http\Controllers\Admin\PaymentReceiptController as AdminPaymentReceiptController;
use App\Http\Controllers\Admin\CourseReviewController as AdminCourseReviewController;
use App\Http\Controllers\Admin\ExportController as AdminExportController;
use App\Http\Controllers\Admin\ProfileController as AdminProfileController;
use App\Http\Controllers\Admin\AdminBacStudyScheduleController;
use App\Http\Controllers\Admin\SubjectPlannerContentController as AdminSubjectPlannerContentController;
use App\Http\Controllers\Admin\FlashcardDeckController as AdminFlashcardDeckController;
use App\Http\Controllers\Admin\FlashcardController as AdminFlashcardController;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

// Admin Authentication Routes (public - no auth required)
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');

    // Password Reset Routes
    Route::get('/password/reset', [AdminAuthController::class, 'showForgotPasswordForm'])->name('password.request');
    Route::post('/password/email', [AdminAuthController::class, 'sendResetLinkEmail'])->name('password.email');
    Route::get('/password/reset/{token}', [AdminAuthController::class, 'showResetPasswordForm'])->name('password.reset');
    Route::post('/password/reset', [AdminAuthController::class, 'resetPassword'])->name('password.update');
});

// Admin routes (protected by auth and admin middleware)
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {

    // Dashboard
    Route::prefix('dashboard')->name('dashboard.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\DashboardController::class, 'index'])->name('index');
        Route::get('/user-growth', [\App\Http\Controllers\Admin\DashboardController::class, 'userGrowthChart'])->name('user-growth');
        Route::get('/study-sessions', [\App\Http\Controllers\Admin\DashboardController::class, 'studySessionsChart'])->name('study-sessions');
        Route::get('/content-distribution', [\App\Http\Controllers\Admin\DashboardController::class, 'contentDistributionChart'])->name('content-distribution');
        Route::get('/top-subjects', [\App\Http\Controllers\Admin\DashboardController::class, 'topSubjectsChart'])->name('top-subjects');
    });

    // Dashboard shortcut (main route)
    Route::get('/dashboard', [\App\Http\Controllers\Admin\DashboardController::class, 'index'])->name('dashboard');

    // User Management
    Route::prefix('users')->name('users.')->group(function () {
        Route::get('/', [AdminUserController::class, 'index'])->name('index');
        Route::get('/create', [AdminUserController::class, 'create'])->name('create');
        Route::post('/', [AdminUserController::class, 'store'])->name('store');

        // AJAX endpoints (must be before wildcard {id} routes)
        Route::get('/ajax/years-by-phase/{phaseId}', [AdminUserController::class, 'getYearsByPhase'])->name('ajax.years-by-phase');
        Route::get('/ajax/streams-by-year/{yearId}', [AdminUserController::class, 'getStreamsByYear'])->name('ajax.streams-by-year');

        // Analytics
        Route::get('/analytics/dashboard', [AdminUserController::class, 'analytics'])->name('analytics');

        // Bulk actions
        Route::post('/bulk-action', [AdminUserController::class, 'bulkAction'])->name('bulk-action');
        Route::get('/export', [AdminUserController::class, 'export'])->name('export');

        // CRUD with {id} parameter (MUST be last)
        Route::get('/{id}', [AdminUserController::class, 'show'])->name('show');
        Route::put('/{id}', [AdminUserController::class, 'update'])->name('update');
        Route::delete('/{id}', [AdminUserController::class, 'destroy'])->name('destroy');

        // Individual user actions
        Route::post('/{id}/reset-password', [AdminUserController::class, 'resetPassword'])->name('reset-password');
        Route::post('/{id}/revoke-device', [AdminUserController::class, 'revokeDevice'])->name('revoke-device');
        Route::post('/{id}/toggle-status', [AdminUserController::class, 'toggleStatus'])->name('toggle-status');
    });

    // Academic Structure Management
    Route::resource('academic-phases', AcademicPhaseController::class);
    Route::post('academic-phases/{academicPhase}/toggle-status', [AcademicPhaseController::class, 'toggleStatus'])->name('academic-phases.toggle-status');
    Route::resource('academic-years', AcademicYearController::class);
    Route::resource('academic-streams', AcademicStreamController::class);

    // Subject Management
    Route::prefix('subjects')->name('subjects.')->group(function () {
        // Main CRUD (no parameters)
        Route::get('/', [AdminSubjectController::class, 'index'])->name('index');
        Route::get('/create', [AdminSubjectController::class, 'create'])->name('create');
        Route::post('/', [AdminSubjectController::class, 'store'])->name('store');

        // AJAX endpoints (must be before wildcard {subject} routes)
        Route::get('/ajax/years/{phaseId}', [AdminSubjectController::class, 'getYearsByPhase'])->name('ajax.years');
        Route::get('/ajax/streams/{yearId}', [AdminSubjectController::class, 'getStreamsByYear'])->name('ajax.streams');
        Route::get('/ajax/subjects/{streamId}', [AdminSubjectController::class, 'getSubjectsByStream'])->name('ajax.subjectsByStream');

        // CRUD with {subject} parameter (MUST be last)
        Route::get('/{subject}', [AdminSubjectController::class, 'show'])->name('show');
        Route::get('/{subject}/edit', [AdminSubjectController::class, 'edit'])->name('edit');
        Route::put('/{subject}', [AdminSubjectController::class, 'update'])->name('update');
        Route::delete('/{subject}', [AdminSubjectController::class, 'destroy'])->name('destroy');
        Route::post('/{subject}/toggle-status', [AdminSubjectController::class, 'toggleStatus'])->name('toggle-status');
    });

    // Content Management
    Route::prefix('contents')->name('contents.')->group(function () {
        Route::get('/', [AdminContentController::class, 'index'])->name('index');
        Route::get('/create', [AdminContentController::class, 'create'])->name('create');
        Route::post('/', [AdminContentController::class, 'store'])->name('store');
        Route::get('/{content}', [AdminContentController::class, 'show'])->name('show');
        Route::get('/{content}/edit', [AdminContentController::class, 'edit'])->name('edit');
        Route::put('/{content}', [AdminContentController::class, 'update'])->name('update');
        Route::delete('/{content}', [AdminContentController::class, 'destroy'])->name('destroy');
        Route::post('/{content}/publish', [AdminContentController::class, 'publish'])->name('publish');
        Route::post('/{content}/unpublish', [AdminContentController::class, 'unpublish'])->name('unpublish');

        // Analytics
        Route::get('/analytics/dashboard', [AdminContentController::class, 'analytics'])->name('analytics');
    });

    // Chapter Management
    Route::prefix('subjects/{subject}/chapters')->name('chapters.')->group(function () {
        Route::get('/', [AdminChapterController::class, 'index'])->name('index');
        Route::post('/', [AdminChapterController::class, 'store'])->name('store');
        Route::put('/{chapter}', [AdminChapterController::class, 'update'])->name('update');
        Route::delete('/{chapter}', [AdminChapterController::class, 'destroy'])->name('destroy');
        Route::post('/reorder', [AdminChapterController::class, 'reorder'])->name('reorder');
    });

    // Intelligent Planner Management
    Route::prefix('planner')->name('planner.')->group(function () {
        Route::get('/', [AdminPlannerController::class, 'index'])->name('index');
        Route::get('/schedules', [AdminPlannerController::class, 'schedules'])->name('schedules');
        Route::get('/schedules/{id}', [AdminPlannerController::class, 'showSchedule'])->name('schedules.show');
        Route::get('/sessions', [AdminPlannerController::class, 'sessions'])->name('sessions');
        Route::get('/sessions/{id}', [AdminPlannerController::class, 'showSession'])->name('sessions.show');
        Route::get('/priorities', [AdminPlannerController::class, 'priorities'])->name('priorities');
        Route::get('/analytics', [AdminPlannerController::class, 'analytics'])->name('analytics');
    });

    // Profile Management
    Route::prefix('profile')->name('profile.')->group(function () {
        Route::get('/', [AdminProfileController::class, 'index'])->name('index');
        Route::get('/edit', [AdminProfileController::class, 'edit'])->name('edit');
        Route::put('/update', [AdminProfileController::class, 'update'])->name('update');
        Route::post('/update-picture', [AdminProfileController::class, 'updatePicture'])->name('update-picture');
        Route::delete('/delete-picture', [AdminProfileController::class, 'deletePicture'])->name('delete-picture');
        Route::get('/change-password', [AdminProfileController::class, 'showChangePassword'])->name('change-password');
        Route::put('/update-password', [AdminProfileController::class, 'updatePassword'])->name('update-password');
        Route::get('/devices', [AdminProfileController::class, 'devices'])->name('devices');
        Route::get('/activity', [AdminProfileController::class, 'activity'])->name('activity');
    });

    // Settings Management
    Route::prefix('settings')->name('settings.')->group(function () {
        Route::get('/', [AdminProfileController::class, 'settings'])->name('index');
        Route::put('/update', [AdminProfileController::class, 'updateSettings'])->name('update');
    });

    // Storage Link Management
    Route::get('/storage/check', [AdminProfileController::class, 'checkStorageLink'])->name('storage.check');
    Route::post('/storage/link', [AdminProfileController::class, 'createStorageLink'])->name('storage.link');

    // Quiz Management
    Route::prefix('quizzes')->name('quizzes.')->group(function () {
        // Main CRUD (list and create first)
        Route::get('/', [AdminQuizController::class, 'index'])->name('index');
        Route::get('/create', [AdminQuizController::class, 'create'])->name('create');
        Route::post('/', [AdminQuizController::class, 'store'])->name('store');

        // Analytics (before wildcard routes)
        Route::get('/analytics/dashboard', [AdminQuizController::class, 'analytics'])->name('analytics');

        // Excel Import (before wildcard routes)
        Route::get('/import', [AdminQuizController::class, 'showImportForm'])->name('import');
        Route::post('/import', [AdminQuizController::class, 'importQuestions'])->name('importQuestions');
        Route::get('/import/template', [AdminQuizController::class, 'downloadTemplate'])->name('downloadTemplate');

        // AJAX endpoints for cascading dropdowns (before wildcard routes)
        Route::get('/ajax/years/{phaseId}', [AdminQuizController::class, 'getYearsByPhase'])->name('ajax.years');
        Route::get('/ajax/streams/{yearId}', [AdminQuizController::class, 'getStreamsByYear'])->name('ajax.streams');
        Route::get('/ajax/subjects', [AdminQuizController::class, 'getSubjects'])->name('ajax.subjects');
        Route::get('/ajax/chapters/{subjectId}', [AdminQuizController::class, 'getChapters'])->name('ajax.chapters');
        Route::get('/ajax/by-subject/{subjectId}', [AdminQuizController::class, 'getQuizzesBySubject'])->name('ajax.bySubject');

        // Question Management - specific routes BEFORE wildcard {id} routes
        Route::post('/{id}/questions/reorder', [AdminQuizController::class, 'reorderQuestions'])->name('reorderQuestions');
        Route::get('/{id}/questions/{questionId}/edit', [AdminQuizController::class, 'editQuestion'])->name('editQuestion');
        Route::put('/{id}/questions/{questionId}', [AdminQuizController::class, 'updateQuestion'])->name('updateQuestion');
        Route::delete('/{id}/questions/{questionId}', [AdminQuizController::class, 'deleteQuestion'])->name('deleteQuestion');
        Route::get('/{id}/questions', [AdminQuizController::class, 'questions'])->name('questions');
        Route::post('/{id}/questions', [AdminQuizController::class, 'storeQuestion'])->name('storeQuestion');

        // Publishing actions (with {id} parameter)
        Route::post('/{id}/publish', [AdminQuizController::class, 'publish'])->name('publish');
        Route::post('/{id}/unpublish', [AdminQuizController::class, 'unpublish'])->name('unpublish');
        Route::post('/{id}/duplicate', [AdminQuizController::class, 'duplicate'])->name('duplicate');

        // Main CRUD with {id} parameter (MUST be last to avoid conflicts)
        Route::get('/{id}', [AdminQuizController::class, 'show'])->name('show');
        Route::get('/{id}/edit', [AdminQuizController::class, 'edit'])->name('edit');
        Route::put('/{id}', [AdminQuizController::class, 'update'])->name('update');
        Route::delete('/{id}', [AdminQuizController::class, 'destroy'])->name('destroy');
    });

    // BAC Archives Management
    Route::prefix('bac')->name('bac.')->group(function () {
        // Main CRUD
        Route::get('/', [AdminBacController::class, 'index'])->name('index');
        Route::get('/create', [AdminBacController::class, 'create'])->name('create');
        Route::post('/', [AdminBacController::class, 'store'])->name('store');

        // Statistics (before wildcard routes)
        Route::get('/statistics', [AdminBacController::class, 'statistics'])->name('statistics');

        // Years management (before wildcard routes)
        Route::get('/years', [AdminBacController::class, 'years'])->name('years');
        Route::post('/years', [AdminBacController::class, 'storeYear'])->name('years.store');
        Route::post('/years/{id}/toggle-status', [AdminBacController::class, 'toggleYearStatus'])->name('years.toggle-status');
        Route::delete('/years/{id}', [AdminBacController::class, 'destroyYear'])->name('years.destroy');

        // AJAX endpoints (before wildcard routes)
        Route::get('/ajax/sessions/{yearId}', [AdminBacController::class, 'getSessionsByYear'])->name('ajax.sessions');
        Route::get('/ajax/streams', [AdminBacController::class, 'getStreams'])->name('ajax.streams');
        Route::get('/ajax/subjects/{streamId}', [AdminBacController::class, 'getSubjectsByStream'])->name('ajax.subjects');

        // Main CRUD with {id} parameter (MUST be last)
        Route::get('/{id}', [AdminBacController::class, 'show'])->name('show');
        Route::get('/{id}/edit', [AdminBacController::class, 'edit'])->name('edit');
        Route::put('/{id}', [AdminBacController::class, 'update'])->name('update');
        Route::delete('/{id}', [AdminBacController::class, 'destroy'])->name('destroy');
    });

    // Paid Courses Management
    Route::prefix('courses')->name('courses.')->group(function () {
        // Main CRUD
        Route::get('/', [AdminCourseController::class, 'index'])->name('index');
        Route::get('/create', [AdminCourseController::class, 'create'])->name('create');
        Route::post('/', [AdminCourseController::class, 'store'])->name('store');

        // Course actions (before wildcard routes)
        Route::post('/{course}/publish', [AdminCourseController::class, 'publish'])->name('publish');
        Route::post('/{course}/unpublish', [AdminCourseController::class, 'unpublish'])->name('unpublish');
        Route::post('/{course}/update-statistics', [AdminCourseController::class, 'updateStatistics'])->name('update-statistics');
        Route::post('/{course}/reorder-modules', [AdminCourseController::class, 'reorderModules'])->name('reorder-modules');
        Route::delete('/{course}/delete-enrollments', [AdminCourseController::class, 'deleteAllEnrollments'])->name('delete-enrollments');

        // Main CRUD with {course} parameter
        Route::get('/{course}', [AdminCourseController::class, 'show'])->name('show');
        Route::get('/{course}/edit', [AdminCourseController::class, 'edit'])->name('edit');
        Route::put('/{course}', [AdminCourseController::class, 'update'])->name('update');
        Route::delete('/{course}', [AdminCourseController::class, 'destroy'])->name('destroy');

        // Module Management
        Route::post('/{course}/modules', [AdminCourseModuleController::class, 'store'])->name('modules.store');
        Route::put('/modules/{module}', [AdminCourseModuleController::class, 'update'])->name('modules.update');
        Route::delete('/modules/{module}', [AdminCourseModuleController::class, 'destroy'])->name('modules.destroy');
        Route::post('/modules/{module}/reorder-lessons', [AdminCourseModuleController::class, 'reorderLessons'])->name('modules.reorder-lessons');

        // Lesson Management
        Route::post('/modules/{module}/lessons', [AdminCourseLessonController::class, 'store'])->name('lessons.store');
        Route::get('/lessons/{lesson}/view', [AdminCourseLessonController::class, 'view'])->name('lessons.view');
        Route::get('/lessons/{lesson}/edit', [AdminCourseLessonController::class, 'edit'])->name('lessons.edit');
        Route::put('/lessons/{lesson}', [AdminCourseLessonController::class, 'update'])->name('lessons.update');
        Route::delete('/lessons/{lesson}', [AdminCourseLessonController::class, 'destroy'])->name('lessons.destroy');

        // Lesson Attachments
        Route::post('/lessons/{lesson}/attachments', [AdminCourseLessonController::class, 'addAttachment'])->name('lessons.attachments.store');
        Route::delete('/lessons/attachments/{attachment}', [AdminCourseLessonController::class, 'deleteAttachment'])->name('lessons.attachments.destroy');
    });

    // Subscriptions Management
    Route::prefix('subscriptions')->name('subscriptions.')->group(function () {
        // Subscriptions list
        Route::get('/', [AdminSubscriptionController::class, 'index'])->name('index');
        Route::get('/{subscription}', [AdminSubscriptionController::class, 'show'])->name('show');
        Route::post('/{subscription}/suspend', [AdminSubscriptionController::class, 'suspend'])->name('suspend');
        Route::post('/{subscription}/reactivate', [AdminSubscriptionController::class, 'reactivate'])->name('reactivate');
        Route::post('/{subscription}/activate', [AdminSubscriptionController::class, 'reactivate'])->name('activate');
        Route::put('/{subscription}/extend', [AdminSubscriptionController::class, 'extend'])->name('extend');
        Route::post('/expire-subscriptions', [AdminSubscriptionController::class, 'expireSubscriptions'])->name('expire');

        // Packages Management
        Route::get('/packages/list', [AdminSubscriptionController::class, 'packages'])->name('packages');
        Route::get('/packages/create', [AdminSubscriptionController::class, 'createPackage'])->name('packages.create');
        Route::post('/packages', [AdminSubscriptionController::class, 'storePackage'])->name('packages.store');
        Route::get('/packages/{package}/edit', [AdminSubscriptionController::class, 'editPackage'])->name('packages.edit');
        Route::put('/packages/{package}', [AdminSubscriptionController::class, 'updatePackage'])->name('packages.update');
        Route::delete('/packages/{package}', [AdminSubscriptionController::class, 'destroyPackage'])->name('packages.destroy');
    });

    // Subscription Codes Management
    Route::prefix('subscription-codes')->name('subscription-codes.')->group(function () {
        Route::get('/', [AdminSubscriptionCodeController::class, 'index'])->name('index');
        Route::get('/by-list', [AdminSubscriptionCodeController::class, 'byList'])->name('by-list');
        Route::get('/by-list/export/summary', [AdminSubscriptionCodeController::class, 'exportByListSummary'])->name('by-list.export.summary');
        Route::get('/by-list/export/detailed', [AdminSubscriptionCodeController::class, 'exportByListDetailed'])->name('by-list.export.detailed');
        Route::get('/list/{list}/export', [AdminSubscriptionCodeController::class, 'exportList'])->name('export-list');
        Route::get('/create', [AdminSubscriptionCodeController::class, 'create'])->name('create');
        Route::post('/', [AdminSubscriptionCodeController::class, 'store'])->name('store');
        Route::get('/{code}', [AdminSubscriptionCodeController::class, 'show'])->name('show');
        Route::post('/{code}/deactivate', [AdminSubscriptionCodeController::class, 'deactivate'])->name('deactivate');
        Route::post('/{code}/activate', [AdminSubscriptionCodeController::class, 'activate'])->name('activate');
        Route::delete('/{code}', [AdminSubscriptionCodeController::class, 'destroy'])->name('destroy');
        Route::post('/{code}/extend-expiration', [AdminSubscriptionCodeController::class, 'extendExpiration'])->name('extend-expiration');
        Route::post('/{code}/increase-uses', [AdminSubscriptionCodeController::class, 'increaseMaxUses'])->name('increase-uses');
        Route::get('/export/csv', [AdminSubscriptionCodeController::class, 'export'])->name('export');
        Route::post('/deactivate-expired', [AdminSubscriptionCodeController::class, 'deactivateExpired'])->name('deactivate-expired');
        Route::post('/validate', [AdminSubscriptionCodeController::class, 'validate'])->name('validate');
    });

    // Subscription Code Lists Management
    Route::prefix('subscription-code-lists')->name('subscription-code-lists.')->group(function () {
        Route::get('/', [AdminSubscriptionCodeListController::class, 'index'])->name('index');
        Route::get('/{list}', [AdminSubscriptionCodeListController::class, 'show'])->name('show');
        Route::delete('/{list}', [AdminSubscriptionCodeListController::class, 'destroy'])->name('destroy');
    });

    // Payment Receipts Management
    Route::prefix('payment-receipts')->name('payment-receipts.')->group(function () {
        Route::get('/', [AdminPaymentReceiptController::class, 'index'])->name('index');
        Route::get('/{receipt}', [AdminPaymentReceiptController::class, 'show'])->name('show');
        Route::post('/{receipt}/approve', [AdminPaymentReceiptController::class, 'approve'])->name('approve');
        Route::post('/{receipt}/reject', [AdminPaymentReceiptController::class, 'reject'])->name('reject');
        Route::post('/bulk-approve', [AdminPaymentReceiptController::class, 'bulkApprove'])->name('bulk-approve');
        Route::get('/{receipt}/download', [AdminPaymentReceiptController::class, 'downloadReceipt'])->name('download');
    });

    // Course Reviews Management
    Route::prefix('course-reviews')->name('course-reviews.')->group(function () {
        Route::get('/', [AdminCourseReviewController::class, 'index'])->name('index');
        Route::get('/{review}', [AdminCourseReviewController::class, 'show'])->name('show');
        Route::post('/{review}/approve', [AdminCourseReviewController::class, 'approve'])->name('approve');
        Route::post('/{review}/reject', [AdminCourseReviewController::class, 'reject'])->name('reject');
        Route::delete('/{review}', [AdminCourseReviewController::class, 'destroy'])->name('destroy');
        Route::post('/bulk-approve', [AdminCourseReviewController::class, 'bulkApprove'])->name('bulk-approve');
        Route::post('/bulk-reject', [AdminCourseReviewController::class, 'bulkReject'])->name('bulk-reject');
    });

    // Promos Management (العروض الترويجية - Slider)
    Route::prefix('promos')->name('promos.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\PromoController::class, 'index'])->name('index');
        Route::get('/create', [\App\Http\Controllers\Admin\PromoController::class, 'create'])->name('create');
        Route::post('/', [\App\Http\Controllers\Admin\PromoController::class, 'store'])->name('store');
        Route::post('/toggle-section', [\App\Http\Controllers\Admin\PromoController::class, 'toggleSection'])->name('toggle-section');
        Route::post('/update-order', [\App\Http\Controllers\Admin\PromoController::class, 'updateOrder'])->name('update-order');
        Route::get('/{promo}', [\App\Http\Controllers\Admin\PromoController::class, 'show'])->name('show');
        Route::get('/{promo}/edit', [\App\Http\Controllers\Admin\PromoController::class, 'edit'])->name('edit');
        Route::put('/{promo}', [\App\Http\Controllers\Admin\PromoController::class, 'update'])->name('update');
        Route::delete('/{promo}', [\App\Http\Controllers\Admin\PromoController::class, 'destroy'])->name('destroy');
        Route::post('/{promo}/toggle-status', [\App\Http\Controllers\Admin\PromoController::class, 'toggleStatus'])->name('toggle-status');
        Route::post('/{promo}/reset-clicks', [\App\Http\Controllers\Admin\PromoController::class, 'resetClicks'])->name('reset-clicks');
    });

    // Sponsors Management (هاد التطبيق برعاية)
    Route::prefix('sponsors')->name('sponsors.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\SponsorController::class, 'index'])->name('index');
        Route::get('/create', [\App\Http\Controllers\Admin\SponsorController::class, 'create'])->name('create');
        Route::post('/', [\App\Http\Controllers\Admin\SponsorController::class, 'store'])->name('store');
        Route::post('/toggle-section', [\App\Http\Controllers\Admin\SponsorController::class, 'toggleSection'])->name('toggle-section');
        Route::post('/update-order', [\App\Http\Controllers\Admin\SponsorController::class, 'updateOrder'])->name('update-order');
        Route::get('/{sponsor}', [\App\Http\Controllers\Admin\SponsorController::class, 'show'])->name('show');
        Route::get('/{sponsor}/edit', [\App\Http\Controllers\Admin\SponsorController::class, 'edit'])->name('edit');
        Route::put('/{sponsor}', [\App\Http\Controllers\Admin\SponsorController::class, 'update'])->name('update');
        Route::delete('/{sponsor}', [\App\Http\Controllers\Admin\SponsorController::class, 'destroy'])->name('destroy');
        Route::post('/{sponsor}/toggle-status', [\App\Http\Controllers\Admin\SponsorController::class, 'toggleStatus'])->name('toggle-status');
        Route::post('/{sponsor}/reset-clicks', [\App\Http\Controllers\Admin\SponsorController::class, 'resetClicks'])->name('reset-clicks');
    });

    // Exports
    Route::prefix('exports')->name('exports.')->group(function () {
        // Reports Index Page
        Route::get('/', [AdminExportController::class, 'index'])->name('index');

        // Course Exports
        Route::get('/courses', [AdminExportController::class, 'exportCourses'])->name('courses');
        Route::get('/courses/{id}/enrollments', [AdminExportController::class, 'exportCourseEnrollments'])->name('courses.enrollments');
        Route::get('/courses/statistics', [AdminExportController::class, 'exportCourseStatistics'])->name('courses.statistics');

        // Subscription Exports
        Route::get('/subscriptions', [AdminExportController::class, 'exportSubscriptions'])->name('subscriptions');
        Route::get('/packages/statistics', [AdminExportController::class, 'exportPackageStatistics'])->name('packages.statistics');
        Route::get('/revenue', [AdminExportController::class, 'exportRevenue'])->name('revenue');

        // Code Exports
        Route::get('/codes', [AdminExportController::class, 'exportCodes'])->name('codes');
        Route::get('/codes/usage', [AdminExportController::class, 'exportCodeUsageStatistics'])->name('codes.usage');

        // Receipt Exports
        Route::get('/receipts', [AdminExportController::class, 'exportReceipts'])->name('receipts');
        Route::get('/receipts/statistics', [AdminExportController::class, 'exportReceiptStatistics'])->name('receipts.statistics');
    });

    // Subscription Assignment
    Route::prefix('subscriptions/assign')->name('subscriptions.assign.')->group(function () {
        // Assign Courses to Students
        Route::get('/courses', [\App\Http\Controllers\Admin\SubscriptionAssignmentController::class, 'assignCoursesIndex'])->name('courses.index');
        Route::post('/courses', [\App\Http\Controllers\Admin\SubscriptionAssignmentController::class, 'assignCourses'])->name('courses.store');

        // Assign Packages to Students
        Route::get('/packages', [\App\Http\Controllers\Admin\SubscriptionAssignmentController::class, 'assignPackagesIndex'])->name('packages.index');
        Route::post('/packages', [\App\Http\Controllers\Admin\SubscriptionAssignmentController::class, 'assignPackages'])->name('packages.store');
    });

    // Notification Management
    Route::prefix('notifications')->name('notifications.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\NotificationController::class, 'index'])->name('index');
        Route::get('/settings', [\App\Http\Controllers\Admin\NotificationController::class, 'settings'])->name('settings');
        Route::get('/statistics', [\App\Http\Controllers\Admin\NotificationController::class, 'statistics'])->name('statistics');
        Route::get('/users/{userId}/settings', [\App\Http\Controllers\Admin\NotificationController::class, 'getUserSettings'])->name('users.settings.get');
        Route::put('/users/{userId}/settings', [\App\Http\Controllers\Admin\NotificationController::class, 'updateUserSettings'])->name('users.settings.update');
        Route::post('/test', [\App\Http\Controllers\Admin\NotificationController::class, 'sendTest'])->name('test');

        // Broadcast Notifications (Send to multiple users)
        Route::get('/broadcast', [\App\Http\Controllers\Admin\NotificationController::class, 'broadcast'])->name('broadcast');
        Route::post('/broadcast/send', [\App\Http\Controllers\Admin\NotificationController::class, 'sendBroadcast'])->name('broadcast.send');
        Route::post('/broadcast/preview', [\App\Http\Controllers\Admin\NotificationController::class, 'previewBroadcast'])->name('broadcast.preview');
        Route::get('/broadcast/users', [\App\Http\Controllers\Admin\NotificationController::class, 'getBroadcastUsers'])->name('broadcast.users');

        // Configuration & Push Notification Settings
        Route::get('/configuration', [\App\Http\Controllers\Admin\NotificationController::class, 'configuration'])->name('configuration');
        Route::put('/configuration', [\App\Http\Controllers\Admin\NotificationController::class, 'updateConfiguration'])->name('configuration.update');
        Route::post('/configuration/test-fcm', [\App\Http\Controllers\Admin\NotificationController::class, 'testFcmConnection'])->name('configuration.test-fcm');
        Route::post('/configuration/clean-tokens', [\App\Http\Controllers\Admin\NotificationController::class, 'cleanInactiveTokens'])->name('configuration.clean-tokens');
    });

    // Analytics Dashboard
    Route::prefix('analytics')->name('analytics.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\AnalyticsController::class, 'index'])->name('index');
        Route::get('/engagement-trends', [\App\Http\Controllers\Admin\AnalyticsController::class, 'engagementTrends'])->name('engagement-trends');
        Route::get('/performance-trends', [\App\Http\Controllers\Admin\AnalyticsController::class, 'performanceTrends'])->name('performance-trends');
        Route::get('/leaderboard', [\App\Http\Controllers\Admin\AnalyticsController::class, 'leaderboard'])->name('leaderboard');
    });

    // BAC Study Schedule Management (98 Days Planner)
    Route::prefix('bac-study-schedule')->name('bac-study-schedule.')->group(function () {
        // Dashboard
        Route::get('/', [AdminBacStudyScheduleController::class, 'index'])->name('index');

        // Days Management
        Route::get('/days', [AdminBacStudyScheduleController::class, 'days'])->name('days');
        Route::get('/days/{id}', [AdminBacStudyScheduleController::class, 'showDay'])->name('days.show');
        Route::get('/days/{id}/edit', [AdminBacStudyScheduleController::class, 'editDay'])->name('days.edit');
        Route::put('/days/{id}', [AdminBacStudyScheduleController::class, 'updateDay'])->name('days.update');

        // Subject Management for Days
        Route::post('/days/{dayId}/subjects', [AdminBacStudyScheduleController::class, 'addSubjectToDay'])->name('days.subjects.store');
        Route::delete('/days/{dayId}/subjects/{subjectId}', [AdminBacStudyScheduleController::class, 'removeSubjectFromDay'])->name('days.subjects.destroy');

        // Topic Management
        Route::post('/day-subjects/{daySubjectId}/topics', [AdminBacStudyScheduleController::class, 'addTopic'])->name('topics.store');
        Route::put('/topics/{topicId}', [AdminBacStudyScheduleController::class, 'updateTopic'])->name('topics.update');
        Route::delete('/topics/{topicId}', [AdminBacStudyScheduleController::class, 'deleteTopic'])->name('topics.destroy');

        // Weekly Rewards Management
        Route::get('/rewards', [AdminBacStudyScheduleController::class, 'rewards'])->name('rewards');
        Route::get('/rewards/create', [AdminBacStudyScheduleController::class, 'createReward'])->name('rewards.create');
        Route::post('/rewards', [AdminBacStudyScheduleController::class, 'storeReward'])->name('rewards.store');
        Route::get('/rewards/{id}/edit', [AdminBacStudyScheduleController::class, 'editReward'])->name('rewards.edit');
        Route::put('/rewards/{id}', [AdminBacStudyScheduleController::class, 'updateReward'])->name('rewards.update');
        Route::delete('/rewards/{id}', [AdminBacStudyScheduleController::class, 'deleteReward'])->name('rewards.destroy');

        // User Progress
        Route::get('/progress', [AdminBacStudyScheduleController::class, 'progress'])->name('progress');
    });

    // Subject Planner Content Management (محتوى مخطط المادة)
    Route::prefix('subject-planner-content')->name('subject-planner-content.')->group(function () {
        // Main views
        Route::get('/', [AdminSubjectPlannerContentController::class, 'index'])->name('index');
        Route::get('/tree', [AdminSubjectPlannerContentController::class, 'tree'])->name('tree');
        Route::get('/create', [AdminSubjectPlannerContentController::class, 'create'])->name('create');
        Route::post('/', [AdminSubjectPlannerContentController::class, 'store'])->name('store');

        // AJAX endpoints (must be before wildcard routes)
        Route::get('/ajax/years/{phaseId}', [AdminSubjectPlannerContentController::class, 'getYearsByPhase'])->name('ajax.years');
        Route::get('/ajax/streams/{yearId}', [AdminSubjectPlannerContentController::class, 'getStreamsByYear'])->name('ajax.streams');
        Route::get('/ajax/subjects/{streamId}', [AdminSubjectPlannerContentController::class, 'getSubjectsByStream'])->name('ajax.subjects');
        Route::get('/ajax/subjects-by-year/{yearId}', [AdminSubjectPlannerContentController::class, 'getSubjectsByYear'])->name('ajax.subjects-by-year');
        Route::get('/ajax/parents/{subjectId}', [AdminSubjectPlannerContentController::class, 'getParentsBySubject'])->name('ajax.parents');
        Route::get('/ajax/children/{id}', [AdminSubjectPlannerContentController::class, 'getChildren'])->name('ajax.children');

        // Bulk, reorder and move actions
        Route::post('/ajax/reorder', [AdminSubjectPlannerContentController::class, 'reorder'])->name('ajax.reorder');
        Route::post('/ajax/move', [AdminSubjectPlannerContentController::class, 'move'])->name('ajax.move');
        Route::post('/bulk-action', [AdminSubjectPlannerContentController::class, 'bulkAction'])->name('bulk-action');

        // CRUD with {content} parameter (MUST be last)
        Route::get('/{content}', [AdminSubjectPlannerContentController::class, 'show'])->name('show');
        Route::get('/{content}/edit', [AdminSubjectPlannerContentController::class, 'edit'])->name('edit');
        Route::put('/{content}', [AdminSubjectPlannerContentController::class, 'update'])->name('update');
        Route::delete('/{content}', [AdminSubjectPlannerContentController::class, 'destroy'])->name('destroy');
        Route::post('/{content}/toggle-status', [AdminSubjectPlannerContentController::class, 'toggleStatus'])->name('toggle-status');
        Route::post('/{content}/toggle-publish', [AdminSubjectPlannerContentController::class, 'togglePublish'])->name('toggle-publish');
    });

    // Flashcard Decks Management (البطاقات التعليمية)
    Route::prefix('flashcard-decks')->name('flashcard-decks.')->group(function () {
        // Main CRUD
        Route::get('/', [AdminFlashcardDeckController::class, 'index'])->name('index');
        Route::get('/create', [AdminFlashcardDeckController::class, 'create'])->name('create');
        Route::post('/', [AdminFlashcardDeckController::class, 'store'])->name('store');

        // AJAX endpoints for cascading dropdowns (before wildcard routes)
        Route::get('/years-by-phase/{phaseId}', [AdminFlashcardDeckController::class, 'getYearsByPhase'])->name('years-by-phase');
        Route::get('/streams-by-year/{yearId}', [AdminFlashcardDeckController::class, 'getStreamsByYear'])->name('streams-by-year');
        Route::get('/subjects', [AdminFlashcardDeckController::class, 'getSubjects'])->name('subjects');
        Route::get('/chapters/{subjectId}', [AdminFlashcardDeckController::class, 'getChapters'])->name('chapters');

        // Publishing actions (with {id} parameter)
        Route::post('/{id}/publish', [AdminFlashcardDeckController::class, 'publish'])->name('publish');
        Route::post('/{id}/unpublish', [AdminFlashcardDeckController::class, 'unpublish'])->name('unpublish');
        Route::post('/{id}/duplicate', [AdminFlashcardDeckController::class, 'duplicate'])->name('duplicate');

        // Main CRUD with {id} parameter (MUST be last)
        Route::get('/{id}', [AdminFlashcardDeckController::class, 'show'])->name('show');
        Route::get('/{id}/edit', [AdminFlashcardDeckController::class, 'edit'])->name('edit');
        Route::put('/{id}', [AdminFlashcardDeckController::class, 'update'])->name('update');
        Route::delete('/{id}', [AdminFlashcardDeckController::class, 'destroy'])->name('destroy');
    });

    // Flashcard Cards Management (within deck context)
    Route::prefix('flashcard-decks/{deckId}/cards')->name('flashcards.')->group(function () {
        Route::get('/', [AdminFlashcardController::class, 'index'])->name('index');
        Route::post('/', [AdminFlashcardController::class, 'store'])->name('store');
        Route::post('/bulk-action', [AdminFlashcardController::class, 'bulkAction'])->name('bulk-action');
        Route::post('/reorder', [AdminFlashcardController::class, 'reorder'])->name('reorder');
        Route::get('/{id}', [AdminFlashcardController::class, 'show'])->name('show');
        Route::put('/{id}', [AdminFlashcardController::class, 'update'])->name('update');
        Route::delete('/{id}', [AdminFlashcardController::class, 'destroy'])->name('destroy');
    });

    // Flashcard File Uploads
    Route::post('/flashcards/upload-image', [AdminFlashcardController::class, 'uploadImage'])->name('flashcards.upload-image');
    Route::post('/flashcards/upload-audio', [AdminFlashcardController::class, 'uploadAudio'])->name('flashcards.upload-audio');
    Route::post('/flashcards/delete-file', [AdminFlashcardController::class, 'deleteFile'])->name('flashcards.delete-file');
});
