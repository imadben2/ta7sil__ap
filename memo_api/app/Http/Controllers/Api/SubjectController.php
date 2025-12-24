<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\UserSubjectProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SubjectController extends Controller
{
    /**
     * Get all subjects for a user
     * Includes user-specific progress data
     */
    public function index(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        // Ensure user can only access their own data
        if ($request->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // Get user's academic profile
        $academicProfile = $user->academicProfile;

        if (!$academicProfile || !$academicProfile->academic_year_id || !$academicProfile->academic_stream_id) {
            return response()->json([
                'data' => [],
                'message' => 'Academic profile not configured',
            ]);
        }

        // Get subjects for the user's academic year and stream with user progress data
        $subjects = Subject::with(['progress' => function ($query) use ($request) {
            $query->where('user_id', $request->user_id);
        }])
            ->where('academic_year_id', $academicProfile->academic_year_id)
            ->forStream($academicProfile->academic_stream_id)
            ->where('is_active', true)
            ->orderBy('order')
            ->get()
            ->map(function ($subject) {
                $progress = $subject->progress->first();

                return [
                    'id' => (string) $subject->id,
                    'name' => $subject->name_ar, // Use name_ar as 'name'
                    'name_ar' => $subject->name_ar,
                    'color_hex' => $subject->color,
                    'icon_name' => $subject->icon,
                    'coefficient' => (int) ($subject->coefficient ?? 1),
                    'difficulty_level' => $progress->difficulty_level ?? 5,
                    'progress_percentage' => $progress->progress_percentage ?? 0.00,
                    'last_studied_at' => $progress->last_studied_at ?? null,
                    'total_chapters' => $progress->total_chapters ?? 0,
                    'completed_chapters' => $progress->completed_chapters ?? 0,
                    'average_score' => $progress->average_score ?? null,
                ];
            });

        return response()->json([
            'data' => $subjects,
        ]);
    }

    /**
     * Get a specific subject
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $subject = Subject::with(['progress' => function ($query) use ($user) {
            $query->where('user_id', $user->id);
        }])->find($id);

        if (!$subject) {
            return response()->json(['error' => 'Subject not found'], 404);
        }

        $progress = $subject->progress->first();

        $data = [
            'id' => (string) $subject->id,
            'name' => $subject->name_ar,
            'name_ar' => $subject->name_ar,
            'color_hex' => $subject->color,
            'icon_name' => $subject->icon,
            'coefficient' => $subject->coefficient,
            'difficulty_level' => $progress->difficulty_level ?? 5,
            'progress_percentage' => $progress->progress_percentage ?? 0.00,
            'last_studied_at' => $progress->last_studied_at ?? null,
            'total_chapters' => $progress->total_chapters ?? 0,
            'completed_chapters' => $progress->completed_chapters ?? 0,
            'average_score' => $progress->average_score ?? null,
        ];

        return response()->json([
            'data' => $data,
        ]);
    }

    /**
     * Create a new subject
     * Note: This is typically an admin operation
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'name_ar' => 'required|string|max:100',
            'color_hex' => 'required|string|regex:/^#[0-9A-Fa-f]{6}$/',
            'icon_name' => 'required|string|max:50',
            'coefficient' => 'required|integer|min:1|max:10',
            'academic_stream_ids' => 'required|array',
            'academic_stream_ids.*' => 'exists:academic_streams,id',
            'academic_year_id' => 'required|exists:academic_years,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $subject = Subject::create([
            'academic_stream_ids' => $request->academic_stream_ids,
            'academic_year_id' => $request->academic_year_id,
            'name_ar' => $request->name_ar,
            'slug' => \Str::slug($request->name),
            'color' => $request->color_hex,
            'icon' => $request->icon_name,
            'coefficient' => $request->coefficient,
            'is_active' => true,
        ]);

        return response()->json([
            'data' => $subject,
            'message' => 'Subject created successfully',
        ], 201);
    }

    /**
     * Update a subject
     */
    public function update(Request $request, $id)
    {
        $subject = Subject::find($id);

        if (!$subject) {
            return response()->json(['error' => 'Subject not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:100',
            'name_ar' => 'sometimes|string|max:100',
            'color_hex' => 'sometimes|string|regex:/^#[0-9A-Fa-f]{6}$/',
            'icon_name' => 'sometimes|string|max:50',
            'coefficient' => 'sometimes|integer|min:1|max:10',
            'difficulty_level' => 'sometimes|integer|min:1|max:10',
            'progress_percentage' => 'sometimes|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        // Update subject basic info
        $updateData = [];
        if ($request->has('name_ar')) {
            $updateData['name_ar'] = $request->name_ar;
        }
        if ($request->has('color_hex')) {
            $updateData['color'] = $request->color_hex;
        }
        if ($request->has('icon_name')) {
            $updateData['icon'] = $request->icon_name;
        }
        if ($request->has('coefficient')) {
            $updateData['coefficient'] = $request->coefficient;
        }

        if (!empty($updateData)) {
            $subject->update($updateData);
        }

        // Update user-specific progress if provided
        if ($request->has('difficulty_level') || $request->has('progress_percentage')) {
            $user = $request->user();
            $progressData = [];

            if ($request->has('difficulty_level')) {
                $progressData['difficulty_level'] = $request->difficulty_level;
            }
            if ($request->has('progress_percentage')) {
                $progressData['progress_percentage'] = $request->progress_percentage;
            }

            UserSubjectProgress::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'subject_id' => $subject->id,
                ],
                $progressData
            );
        }

        return response()->json([
            'data' => $subject->fresh(),
            'message' => 'Subject updated successfully',
        ]);
    }

    /**
     * Delete a subject
     * Note: This is typically an admin operation
     */
    public function destroy($id)
    {
        $subject = Subject::find($id);

        if (!$subject) {
            return response()->json(['error' => 'Subject not found'], 404);
        }

        // Soft delete by marking as inactive instead of actual deletion
        $subject->update(['is_active' => false]);

        return response()->json([
            'message' => 'Subject deleted successfully',
        ]);
    }
}
