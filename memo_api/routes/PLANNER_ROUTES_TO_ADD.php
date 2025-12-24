<?php

/**
 * INTELLIGENT PLANNER ROUTES TO ADD
 *
 * Add these routes to memo_api/routes/api.php
 * Place them inside the protected routes section (after line 84)
 *
 * INSTRUCTIONS:
 * 1. Add the controller import at the top:
 *    use App\Http\Controllers\Api\V1\PlannerSubjectsController;
 *
 * 2. Add these routes inside the auth:sanctum middleware group
 */

// Intelligent Planner Routes
Route::prefix('v1/planner')->group(function () {
    // Batch create subjects (NEW - Intelligent Planner feature)
    Route::post('/subjects/batch', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'batchCreate']);

    // CRUD operations for planner subjects
    Route::get('/subjects', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'index']);
    Route::get('/subjects/{id}', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'show']);
    Route::put('/subjects/{id}', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'update']);
    Route::delete('/subjects/{id}', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'destroy']);
});

// Enhanced Subject Routes (with profile filtering)
Route::prefix('v1')->group(function () {
    // Get subjects filtered by user profile (NEW - Enhanced filtering)
    Route::get('/subjects', [App\Http\Controllers\Api\V1\SubjectController::class, 'index']);
    Route::get('/subjects/all', [App\Http\Controllers\Api\V1\SubjectController::class, 'all']); // Admin/dev use
    Route::get('/subjects/{id}', [App\Http\Controllers\Api\V1\SubjectController::class, 'show']);
});

/**
 * EXAMPLE OF FINAL ROUTE STRUCTURE:
 *
 * Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
 *
 *     // ... existing routes ...
 *
 *     // Intelligent Planner Routes
 *     Route::prefix('v1/planner')->group(function () {
 *         Route::post('/subjects/batch', [PlannerSubjectsController::class, 'batchCreate']);
 *         Route::get('/subjects', [PlannerSubjectsController::class, 'index']);
 *         Route::get('/subjects/{id}', [PlannerSubjectsController::class, 'show']);
 *         Route::put('/subjects/{id}', [PlannerSubjectsController::class, 'update']);
 *         Route::delete('/subjects/{id}', [PlannerSubjectsController::class, 'destroy']);
 *     });
 *
 *     // Enhanced Subject Routes
 *     Route::prefix('v1')->group(function () {
 *         Route::get('/subjects', [SubjectController::class, 'index']);
 *         Route::get('/subjects/all', [SubjectController::class, 'all']);
 *         Route::get('/subjects/{id}', [SubjectController::class, 'show']);
 *     });
 *
 *     // ... rest of routes ...
 * });
 */
