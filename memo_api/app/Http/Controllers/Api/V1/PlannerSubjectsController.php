<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\PlannerSubject;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class PlannerSubjectsController extends Controller
{
    /**
     * Batch create planner subjects
     *
     * POST /api/v1/planner/subjects/batch
     *
     * Creates multiple planner subjects in a single atomic transaction.
     * Core of the intelligent planner feature.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function batchCreate(Request $request)
    {
        // Validate request
        $validated = $request->validate([
            'subjects' => 'required|array|min:1|max:20',
            'subjects.*.subject_id' => [
                'required',
                'integer',
                Rule::exists('subjects', 'id')->where(function ($query) {
                    $query->where('is_active', true);
                }),
            ],
            'subjects.*.difficulty_level' => 'required|integer|min:1|max:5',
            'subjects.*.last_year_average' => 'nullable|numeric|min:0|max:20',
            'subjects.*.priority' => 'required|in:low,medium,high,critical',
            'subjects.*.progress_percentage' => 'nullable|integer|min:0|max:100',
        ]);

        $userId = auth()->id();
        $subjectIds = collect($validated['subjects'])->pluck('subject_id');

        // Check for duplicates in request
        if ($subjectIds->count() !== $subjectIds->unique()->count()) {
            return response()->json([
                'success' => false,
                'error' => 'DUPLICATE_IN_REQUEST',
                'message' => 'يوجد مواد مكررة في الطلب',
            ], 400);
        }

        // Check for existing subjects in user's planner
        $existingSubjects = PlannerSubject::where('user_id', $userId)
            ->whereIn('subject_id', $subjectIds)
            ->with('subject')
            ->get();

        if ($existingSubjects->isNotEmpty()) {
            $firstExisting = $existingSubjects->first();
            return response()->json([
                'success' => false,
                'error' => 'DUPLICATE_SUBJECT',
                'message' => "المادة '{$firstExisting->subject->name_ar}' موجودة مسبقاً",
                'data' => [
                    'subject_id' => $firstExisting->subject_id,
                    'existing_planner_subject_id' => $firstExisting->id,
                ],
            ], 400);
        }

        // Batch create in transaction (all-or-nothing)
        try {
            DB::beginTransaction();

            $createdSubjects = [];

            foreach ($validated['subjects'] as $subjectData) {
                $plannerSubject = PlannerSubject::create([
                    'user_id' => $userId,
                    'subject_id' => $subjectData['subject_id'],
                    'difficulty_level' => $subjectData['difficulty_level'],
                    'last_year_average' => $subjectData['last_year_average'] ?? null,
                    'priority' => $subjectData['priority'],
                    'progress_percentage' => $subjectData['progress_percentage'] ?? 0,
                ]);

                // Load relationship for response
                $plannerSubject->load('subject');
                $createdSubjects[] = $plannerSubject;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => count($createdSubjects) . ' مواد تم إضافتها بنجاح',
                'data' => [
                    'created_count' => count($createdSubjects),
                    'subjects' => $createdSubjects,
                ],
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            \Log::error('Batch create planner subjects failed', [
                'user_id' => $userId,
                'subject_ids' => $subjectIds->toArray(),
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'TRANSACTION_FAILED',
                'message' => 'فشل في إنشاء المواد. يرجى المحاولة مرة أخرى',
            ], 500);
        }
    }

    /**
     * Get user's planner subjects
     *
     * GET /api/v1/planner/subjects
     *
     * Auto-initializes subjects from user's academic profile if none exist
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $user = auth()->user();
        $userId = $user->id;

        // Get user's academic profile
        $academicProfile = $user->academicProfile;

        if (!$academicProfile || !$academicProfile->academic_year_id || !$academicProfile->academic_stream_id) {
            return response()->json([
                'success' => true,
                'data' => [],
                'message' => 'Academic profile not configured',
            ]);
        }

        $yearId = $academicProfile->academic_year_id;
        $streamId = $academicProfile->academic_stream_id;

        \Log::info("PlannerSubjectsController@index - User {$userId}, Year: {$yearId}, Stream: {$streamId}");

        // ALWAYS fetch subjects directly from subjects table filtered by year and stream
        // This ensures subjects are always dynamic based on user's current academic profile
        $subjects = Subject::where('is_active', true)
            ->where('academic_year_id', $yearId)
            ->where(function ($query) use ($streamId) {
                $query->whereJsonContains('academic_stream_ids', (int) $streamId)
                      ->orWhereJsonContains('academic_stream_ids', (string) $streamId);
            })
            ->get()
            ->map(function ($subject) use ($userId, $streamId) {
                // Get user's progress for this subject from planner_subjects (if exists)
                $plannerSubject = PlannerSubject::where('user_id', $userId)
                    ->where('subject_id', $subject->id)
                    ->first();

                // Get stream-specific coefficient from subject_stream table
                $streamCoef = \App\Models\SubjectStream::where('subject_id', $subject->id)
                    ->where('academic_stream_id', $streamId)
                    ->first();

                $coefficient = $streamCoef ? $streamCoef->coefficient : ($subject->coefficient ?? 1);

                return [
                    'id' => $plannerSubject ? $plannerSubject->subject_id : $subject->id,
                    'subject_id' => $subject->id,
                    'name' => $subject->name_ar ?? $subject->slug ?? '',
                    'name_ar' => $subject->name_ar ?? '',
                    'color_hex' => $subject->color ?? '#3B82F6',
                    'color' => $subject->color ?? '#3B82F6',
                    'icon_name' => $subject->icon ?? 'book',
                    'icon' => $subject->icon ?? 'book',
                    'coefficient' => $coefficient,
                    'difficulty_level' => $plannerSubject->difficulty_level ?? 5,
                    'progress_percentage' => $plannerSubject->progress_percentage ?? 0,
                    'last_studied_at' => $plannerSubject->last_studied_at ?? null,
                    'total_chapters' => 0,
                    'completed_chapters' => 0,
                    'average_score' => 0,
                    'last_year_average' => $plannerSubject->last_year_average ?? null,
                    'priority' => $plannerSubject->priority ?? 'medium',
                    'is_active' => $plannerSubject->is_active ?? true,
                ];
            });

        \Log::info("Returning {$subjects->count()} subjects for user {$userId} (year: {$yearId}, stream: {$streamId})");

        return response()->json([
            'success' => true,
            'data' => $subjects,
        ]);
    }

    /**
     * Initialize planner subjects from user's academic profile
     *
     * @param \App\Models\User $user
     * @return void
     */
    private function initializeSubjectsFromAcademicProfile($user)
    {
        // Get user's academic profile
        $academicProfile = $user->academicProfile;

        if (!$academicProfile) {
            \Log::warning("User {$user->id} has no academic profile, cannot initialize planner subjects");
            return;
        }

        $yearId = $academicProfile->academic_year_id;
        $streamId = $academicProfile->academic_stream_id;

        if (!$yearId || !$streamId) {
            \Log::warning("User {$user->id} has incomplete academic profile (year: {$yearId}, stream: {$streamId})");
            return;
        }

        // Get subjects for this year and stream
        $subjects = Subject::where('is_active', true)
            ->where('academic_year_id', $yearId)
            ->where(function ($query) use ($streamId) {
                $query->whereJsonContains('academic_stream_ids', (int) $streamId)
                      ->orWhereJsonContains('academic_stream_ids', (string) $streamId);
            })
            ->get();

        if ($subjects->isEmpty()) {
            \Log::warning("No subjects found for year {$yearId}, stream {$streamId}");
            return;
        }

        \Log::info("Initializing {$subjects->count()} planner subjects for user {$user->id} (year: {$yearId}, stream: {$streamId})");

        // Create planner subjects for each academic subject
        foreach ($subjects as $subject) {
            try {
                PlannerSubject::create([
                    'user_id' => $user->id,
                    'subject_id' => $subject->id,
                    'difficulty_level' => 5, // Default middle difficulty
                    'last_year_average' => null,
                    'priority' => 'medium',
                    'progress_percentage' => 0,
                    'is_active' => true,
                ]);
            } catch (\Exception $e) {
                \Log::error("Failed to create planner subject for user {$user->id}, subject {$subject->id}: {$e->getMessage()}");
            }
        }
    }

    /**
     * Get single planner subject
     *
     * GET /api/v1/planner/subjects/{id}
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $userId = auth()->id();

        $subject = PlannerSubject::where('user_id', $userId)
            ->where('id', $id)
            ->with('subject')
            ->first();

        if (!$subject) {
            return response()->json([
                'success' => false,
                'error' => 'NOT_FOUND',
                'message' => 'المادة غير موجودة',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'subject' => $subject,
        ]);
    }

    /**
     * Update planner subject
     *
     * PUT /api/v1/planner/subjects/{id}
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $userId = auth()->id();

        // Try to find by planner_subject.id first, then by subject_id
        $plannerSubject = PlannerSubject::where('user_id', $userId)
            ->where('id', $id)
            ->first();

        if (!$plannerSubject) {
            $plannerSubject = PlannerSubject::where('user_id', $userId)
                ->where('subject_id', $id)
                ->first();
        }

        $validated = $request->validate([
            'difficulty_level' => 'sometimes|integer|min:1|max:10',
            'last_year_average' => 'nullable|numeric|min:0|max:20',
            'priority' => 'sometimes|in:low,medium,high,critical',
            'progress_percentage' => 'sometimes|numeric|min:0|max:100',
        ]);

        if (isset($validated['difficulty_level'])) {
            $validated['difficulty_level'] = max(1, min(5, ceil($validated['difficulty_level'] / 2)));
        }

        if (!$plannerSubject) {
            $subject = Subject::find($id);
            if (!$subject) {
                return response()->json([
                    'success' => false,
                    'error' => 'NOT_FOUND',
                    'message' => 'المادة غير موجودة',
                ], 404);
            }

            $plannerSubject = PlannerSubject::create([
                'user_id' => $userId,
                'subject_id' => $id,
                'difficulty_level' => $validated['difficulty_level'] ?? 3,
                'last_year_average' => $validated['last_year_average'] ?? null,
                'priority' => $validated['priority'] ?? 'medium',
                'progress_percentage' => $validated['progress_percentage'] ?? 0,
                'is_active' => true,
            ]);
        } else {
            $updateData = array_intersect_key($validated, array_flip([
                'difficulty_level', 'last_year_average', 'priority', 'progress_percentage'
            ]));
            if (!empty($updateData)) {
                $plannerSubject->update($updateData);
            }
        }

        $plannerSubject->load('subject');

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث المادة بنجاح',
            'data' => [
                'id' => $plannerSubject->subject_id,
                'difficulty_level' => $plannerSubject->difficulty_level,
                'last_year_average' => $plannerSubject->last_year_average,
            ],
        ]);
    }

    /**
     * Delete planner subject
     *
     * DELETE /api/v1/planner/subjects/{id}
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $userId = auth()->id();

        $subject = PlannerSubject::where('user_id', $userId)
            ->where('id', $id)
            ->first();

        if (!$subject) {
            return response()->json([
                'success' => false,
                'error' => 'NOT_FOUND',
                'message' => 'المادة غير موجودة',
            ], 404);
        }

        $subject->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف المادة بنجاح',
        ]);
    }
}
