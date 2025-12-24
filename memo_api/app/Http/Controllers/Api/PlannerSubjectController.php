<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserSubject;
use App\Models\Subject;
use App\Models\UserSubjectProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PlannerSubjectController extends Controller
{
    /**
     * Get all planner subjects for the authenticated user
     * Returns subjects based on user's academic profile (year and stream)
     */
    public function index(Request $request)
    {
        $user = $request->user();

        \Log::info('PlannerSubjectController@index called', [
            'user_id' => $user ? $user->id : 'NULL',
            'user_email' => $user ? $user->email : 'NULL',
        ]);

        // Get user's academic profile
        $academicProfile = $user->academicProfile;

        \Log::info('Academic profile', [
            'has_profile' => $academicProfile ? true : false,
            'year_id' => $academicProfile ? $academicProfile->academic_year_id : 'NULL',
            'stream_id' => $academicProfile ? $academicProfile->academic_stream_id : 'NULL',
        ]);

        if (!$academicProfile || !$academicProfile->academic_year_id || !$academicProfile->academic_stream_id) {
            \Log::warning('Academic profile not configured');
            return response()->json([
                'data' => [],
                'message' => 'Academic profile not configured',
            ]);
        }

        // Get subjects for the user's academic year and stream (using forStream for JSON array)
        $subjects = Subject::where('academic_year_id', $academicProfile->academic_year_id)
            ->forStream($academicProfile->academic_stream_id)
            ->where('is_active', true)
            ->get();

        \Log::info('Subjects query result', [
            'count' => $subjects->count(),
            'year_id' => $academicProfile->academic_year_id,
            'stream_id' => $academicProfile->academic_stream_id,
        ]);

        $streamId = $academicProfile->academic_stream_id;

        $subjects = $subjects
            ->map(function ($subject) use ($user, $streamId) {
                // Check if user has this subject in UserSubject table (for customization)
                $userSubject = UserSubject::where('user_id', $user->id)
                    ->where('subject_id', $subject->id)
                    ->first();

                // Get progress for this subject
                $progress = UserSubjectProgress::where('user_id', $user->id)
                    ->where('subject_id', $subject->id)
                    ->first();

                // Get stream-specific coefficient from subject_stream table
                $streamCoef = \App\Models\SubjectStream::where('subject_id', $subject->id)
                    ->where('academic_stream_id', $streamId)
                    ->first();

                $coefficient = $streamCoef ? (int) $streamCoef->coefficient : (int) ($subject->coefficient ?? 1);

                return [
                    'id' => (string) $subject->id,
                    'name' => $subject->name_ar,
                    'name_ar' => $subject->name_ar,
                    'color_hex' => $subject->color ?? '#6366F1',
                    'icon_name' => $subject->icon ?? 'book',
                    'coefficient' => $coefficient,
                    'difficulty_level' => $progress->difficulty_level ?? 5,
                    'progress_percentage' => $progress->progress_percentage ?? 0.00,
                    'last_studied_at' => $progress->last_studied_at ?? null,
                    'total_chapters' => $progress->total_chapters ?? 0,
                    'completed_chapters' => $progress->completed_chapters ?? 0,
                    'average_score' => $progress->average_score ?? 0.00,
                    'last_year_average' => $progress->last_year_average ?? null,
                    'is_active' => $userSubject->is_active ?? true,
                    'goal_hours_per_week' => $userSubject->goal_hours_per_week ?? 0,
                ];
            });

        return response()->json([
            'data' => $subjects,
        ]);
    }

    /**
     * Get a specific planner subject
     * Returns subject data even if not yet in user's planner (with defaults)
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();

        // First get the base subject
        $subject = Subject::find($id);
        if (!$subject) {
            return response()->json(['error' => 'Subject not found'], 404);
        }

        // Get user-specific data if exists
        $userSubject = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $id)
            ->first();

        $progress = UserSubjectProgress::where('user_id', $user->id)
            ->where('subject_id', $id)
            ->first();

        $data = [
            'id' => (string) $subject->id,
            'name' => $subject->name_ar,
            'name_ar' => $subject->name_ar,
            'color_hex' => $subject->color ?? '#6366F1',
            'icon_name' => $subject->icon ?? 'book',
            'coefficient' => $subject->coefficient,
            'difficulty_level' => $progress->difficulty_level ?? 5,
            'progress_percentage' => $progress->progress_percentage ?? 0.00,
            'last_studied_at' => $progress->last_studied_at ?? null,
            'total_chapters' => $progress->total_chapters ?? 0,
            'completed_chapters' => $progress->completed_chapters ?? 0,
            'average_score' => $progress->average_score ?? 0.00,
            'last_year_average' => $progress->last_year_average ?? null,
            'is_active' => $userSubject->is_active ?? true,
            'goal_hours_per_week' => $userSubject->goal_hours_per_week ?? 0,
        ];

        return response()->json([
            'data' => $data,
        ]);
    }

    /**
     * Add a subject to user's planner
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'subject_id' => 'required|exists:subjects,id',
            'goal_hours_per_week' => 'nullable|numeric|min:0|max:168',
            'difficulty_level' => 'nullable|integer|min:1|max:10',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Check if already exists
        $existing = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $request->subject_id)
            ->first();

        if ($existing) {
            return response()->json([
                'error' => 'Subject already in your planner',
            ], 409);
        }

        // Add to planner
        $userSubject = UserSubject::create([
            'user_id' => $user->id,
            'subject_id' => $request->subject_id,
            'goal_hours_per_week' => $request->goal_hours_per_week ?? 0,
            'is_active' => true,
        ]);

        // Create initial progress record
        UserSubjectProgress::create([
            'user_id' => $user->id,
            'subject_id' => $request->subject_id,
            'difficulty_level' => $request->difficulty_level ?? 5,
            'progress_percentage' => 0,
            'total_chapters' => 0,
            'completed_chapters' => 0,
            'average_score' => 0,
        ]);

        return response()->json([
            'data' => $userSubject->load('subject'),
            'message' => 'Subject added to planner successfully',
        ], 201);
    }

    /**
     * Update planner subject settings
     * Auto-creates the user subject record if it doesn't exist (upsert behavior)
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();

        // First verify the subject exists in the subjects table
        $subject = Subject::find($id);
        if (!$subject) {
            return response()->json(['error' => 'Subject not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'goal_hours_per_week' => 'sometimes|numeric|min:0|max:168',
            'difficulty_level' => 'sometimes|integer|min:1|max:10',
            'last_year_average' => 'nullable|numeric|min:0|max:20',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        // Get or create user subject (upsert behavior)
        $userSubject = UserSubject::firstOrCreate(
            [
                'user_id' => $user->id,
                'subject_id' => $id,
            ],
            [
                'goal_hours_per_week' => 0,
                'is_active' => true,
            ]
        );

        // Update user_subjects settings
        $updateData = [];
        if ($request->has('goal_hours_per_week')) {
            $updateData['goal_hours_per_week'] = $request->goal_hours_per_week;
        }
        if ($request->has('is_active')) {
            $updateData['is_active'] = $request->is_active;
        }

        if (!empty($updateData)) {
            $userSubject->update($updateData);
        }

        // Update or create progress record
        $progressData = [
            'difficulty_level' => $request->difficulty_level ?? 5,
        ];

        // Only include last_year_average if provided in request
        if ($request->has('last_year_average')) {
            $progressData['last_year_average'] = $request->last_year_average;
        }

        UserSubjectProgress::updateOrCreate(
            [
                'user_id' => $user->id,
                'subject_id' => $id,
            ],
            $progressData
        );

        return response()->json([
            'data' => $userSubject->fresh()->load('subject', 'progress'),
            'message' => 'Subject updated successfully',
        ]);
    }

    /**
     * Remove a subject from planner
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();

        $userSubject = UserSubject::where('user_id', $user->id)
            ->where('subject_id', $id)
            ->first();

        if (!$userSubject) {
            return response()->json(['error' => 'Subject not found in your planner'], 404);
        }

        // Soft delete by marking as inactive
        $userSubject->update(['is_active' => false]);

        return response()->json([
            'message' => 'Subject removed from planner successfully',
        ]);
    }
}
