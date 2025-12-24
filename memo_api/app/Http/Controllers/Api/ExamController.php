<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExamSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class ExamController extends Controller
{
    /**
     * Get all exams for a user
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
        // Ensure user can only access their own exams
        if ($request->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $exams = ExamSchedule::with('subject')
            ->where('user_id', $request->user_id)
            ->orderBy('exam_date')
            ->get()
            ->map(function ($exam) {
                return [
                    'id' => (string) $exam->id,
                    'user_id' => (string) $exam->user_id,
                    'subject_id' => (string) $exam->subject_id,
                    'subject_name' => $exam->subject->name_ar ?? 'مادة غير معروفة',
                    'exam_date' => $exam->exam_date->format('Y-m-d'),
                    'exam_type' => $exam->exam_type,
                    'importance_level' => $exam->importance_level,
                    'duration_minutes' => $exam->duration_minutes,
                    'preparation_days_before' => $exam->preparation_days_before,
                    'target_score' => $exam->target_score,
                    'actual_score' => $exam->actual_score,
                    'chapters_covered' => $exam->chapters_covered ?? [],
                ];
            });

        return response()->json([
            'data' => $exams,
        ]);
    }

    /**
     * Get a specific exam
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $exam = ExamSchedule::with('subject')->find($id);

        if (!$exam) {
            return response()->json(['error' => 'Exam not found'], 404);
        }

        // Ensure user can only access their own exam
        if ($exam->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $data = [
            'id' => (string) $exam->id,
            'user_id' => (string) $exam->user_id,
            'subject_id' => (string) $exam->subject_id,
            'subject_name' => $exam->subject->name_ar ?? 'مادة غير معروفة',
            'exam_date' => $exam->exam_date->format('Y-m-d'),
            'exam_type' => $exam->exam_type,
            'importance_level' => $exam->importance_level,
            'duration_minutes' => $exam->duration_minutes,
            'preparation_days_before' => $exam->preparation_days_before,
            'target_score' => $exam->target_score,
            'actual_score' => $exam->actual_score,
            'chapters_covered' => $exam->chapters_covered ?? [],
        ];

        return response()->json([
            'data' => $data,
        ]);
    }

    /**
     * Create a new exam
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'subject_id' => 'required|exists:subjects,id',
            'exam_date' => 'required|date|after_or_equal:today',
            'exam_type' => 'required|in:quiz,test,exam,final_exam',
            'importance_level' => 'required|in:low,medium,high,critical',
            'duration_minutes' => 'required|integer|min:1',
            'preparation_days_before' => 'nullable|integer|min:1',
            'target_score' => 'nullable|numeric|min:0|max:20',
            'chapters_covered' => 'nullable|array',
            'chapters_covered.*' => 'string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        // Ensure user can only create their own exams
        if ($request->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $exam = ExamSchedule::create([
            'user_id' => $request->user_id,
            'subject_id' => $request->subject_id,
            'exam_type' => $request->exam_type,
            'exam_date' => $request->exam_date,
            'exam_time' => $request->exam_time ?? '08:00',
            'duration_minutes' => $request->duration_minutes,
            'importance_level' => $request->importance_level,
            'preparation_days_before' => $request->preparation_days_before ?? 7,
            'target_score' => $request->target_score,
            'chapters_covered' => $request->chapters_covered,
            'is_completed' => false,
        ]);

        $exam->load('subject');

        return response()->json([
            'data' => $exam,
            'message' => 'Exam created successfully',
        ], 201);
    }

    /**
     * Update an exam
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();
        $exam = ExamSchedule::find($id);

        if (!$exam) {
            return response()->json(['error' => 'Exam not found'], 404);
        }

        // Ensure user can only update their own exams
        if ($exam->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'subject_id' => 'sometimes|exists:subjects,id',
            'exam_date' => 'sometimes|date',
            'exam_type' => 'sometimes|in:quiz,test,exam,final_exam',
            'importance_level' => 'sometimes|in:low,medium,high,critical',
            'duration_minutes' => 'sometimes|integer|min:1',
            'preparation_days_before' => 'sometimes|integer|min:1',
            'target_score' => 'nullable|numeric|min:0|max:20',
            'actual_score' => 'nullable|numeric|min:0|max:20',
            'chapters_covered' => 'nullable|array',
            'chapters_covered.*' => 'string',
            'is_completed' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $updateData = $request->only([
            'subject_id',
            'exam_date',
            'exam_type',
            'importance_level',
            'duration_minutes',
            'preparation_days_before',
            'target_score',
            'actual_score',
            'chapters_covered',
            'is_completed',
        ]);

        $exam->update($updateData);
        $exam->load('subject');

        return response()->json([
            'data' => $exam,
            'message' => 'Exam updated successfully',
        ]);
    }

    /**
     * Delete an exam
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $exam = ExamSchedule::find($id);

        if (!$exam) {
            return response()->json(['error' => 'Exam not found'], 404);
        }

        // Ensure user can only delete their own exams
        if ($exam->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $exam->delete();

        return response()->json([
            'message' => 'Exam deleted successfully',
        ]);
    }

    /**
     * Record exam result and trigger adaptation
     *
     * This is a CRITICAL endpoint that:
     * 1. Records the actual exam score and performance
     * 2. Triggers priority recalculation for the subject
     * 3. Triggers adaptation service to adjust study schedule
     * 4. Awards achievements for high scores
     *
     * @param Request $request
     * @param int $id - Exam ID
     * @return \Illuminate\Http\JsonResponse
     */
    public function recordResult(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'actual_score' => 'required|numeric|min:0|max:20',
            'max_score' => 'nullable|numeric|min:1|max:20',
            'difficulty_rating' => 'nullable|integer|min:1|max:5',
            'time_spent_minutes' => 'nullable|integer|min:1',
            'notes' => 'nullable|string|max:1000',
            'mood' => 'nullable|in:happy,neutral,sad',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $exam = ExamSchedule::with('subject')->find($id);

        if (!$exam) {
            return response()->json(['error' => 'Exam not found'], 404);
        }

        // Ensure user can only record results for their own exams
        if ($exam->user_id != $user->id && !$user->is_admin) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        // Validate exam date has passed
        if ($exam->exam_date->isFuture()) {
            return response()->json([
                'error' => 'Cannot record result for a future exam',
            ], 422);
        }

        // Calculate performance percentage
        $maxScore = $request->max_score ?? 20;
        $scorePercentage = ($request->actual_score / $maxScore) * 100;

        // Update exam with result
        $exam->update([
            'actual_score' => $request->actual_score,
            'is_completed' => true,
            'difficulty_rating' => $request->difficulty_rating,
            'time_spent_minutes' => $request->time_spent_minutes,
            'result_notes' => $request->notes,
            'result_mood' => $request->mood,
            'score_percentage' => $scorePercentage,
        ]);

        // Get or create adaptation service
        $adaptationService = app(\App\Services\AdaptationService::class);
        $priorityService = app(\App\Services\PriorityCalculationService::class);

        // Trigger priority recalculation for this subject
        $priorityAdjustment = 0;
        $adaptationChanges = [];

        if ($scorePercentage < 60) {
            // Poor performance - increase priority significantly
            $priorityAdjustment = 30;
            $adaptationChanges[] = "Priorité de {$exam->subject->name_ar} augmentée de 30% en raison du score faible";
            $adaptationChanges[] = "Ajout de 2-3 sessions de révision supplémentaires par semaine";
            $adaptationChanges[] = "Réduction de la durée des sessions (sessions plus courtes et fréquentes)";
        } elseif ($scorePercentage >= 60 && $scorePercentage < 80) {
            // Moderate performance - slight increase
            $priorityAdjustment = 10;
            $adaptationChanges[] = "Priorité de {$exam->subject->name_ar} augmentée de 10%";
            $adaptationChanges[] = "Ajout d'1 session de révision supplémentaire par semaine";
        } elseif ($scorePercentage >= 80) {
            // Good performance - reduce priority to focus on weaker subjects
            $priorityAdjustment = -10;
            $adaptationChanges[] = "Priorité de {$exam->subject->name_ar} réduite de 10% (bonne maîtrise)";
            $adaptationChanges[] = "Recentrage sur les matières plus faibles";
        }

        // Check for achievement (score >= 18/20 = 90%)
        $achievementUnlocked = null;
        if ($scorePercentage >= 90) {
            $achievementUnlocked = [
                'type' => 'excellent_exam_score',
                'title' => 'Excellence ! 🌟',
                'description' => "Score excellent : {$request->actual_score}/{$maxScore} en {$exam->subject->name_ar}",
                'points_bonus' => 50,
            ];
            $adaptationChanges[] = "🎉 Succès débloqué : Excellence en {$exam->subject->name_ar}";

            // Award bonus points to user
            $pointsService = app(\App\Services\PointsCalculationService::class);
            $pointsService->awardPoints($user, 50);
        }

        // Trigger adaptation (this will regenerate schedule with new priorities)
        try {
            $adaptationResult = $adaptationService->adaptScheduleForUser($user, [
                'trigger' => 'exam_result',
                'exam_id' => $exam->id,
                'subject_id' => $exam->subject_id,
                'score_percentage' => $scorePercentage,
                'priority_adjustment' => $priorityAdjustment,
            ]);
        } catch (\Exception $e) {
            // Log error but don't fail the request
            \Log::error('Adaptation service failed', [
                'error' => $e->getMessage(),
                'exam_id' => $exam->id,
            ]);
            $adaptationResult = null;
        }

        return response()->json([
            'message' => 'Résultat de l\'examen enregistré avec succès',
            'exam' => $exam->fresh()->load('subject'),
            'score_percentage' => round($scorePercentage, 1),
            'performance_level' => $this->getPerformanceLevel($scorePercentage),
            'priority_adjustment' => $priorityAdjustment,
            'adaptation_changes' => $adaptationChanges,
            'achievement_unlocked' => $achievementUnlocked,
            'adaptation_triggered' => $adaptationResult !== null,
        ]);
    }

    /**
     * Get performance level label based on score percentage
     *
     * @param float $percentage
     * @return string
     */
    private function getPerformanceLevel(float $percentage): string
    {
        if ($percentage >= 90) {
            return 'excellent';
        } elseif ($percentage >= 80) {
            return 'très bien';
        } elseif ($percentage >= 70) {
            return 'bien';
        } elseif ($percentage >= 60) {
            return 'passable';
        } else {
            return 'insuffisant';
        }
    }
}
