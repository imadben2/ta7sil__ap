<?php

namespace App\Listeners;

use App\Events\BacSimulationCompleted;
use App\Models\PlannerTask;
use App\Models\User;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class UpdatePlannerAfterSimulation implements ShouldQueue
{
    /**
     * Handle the event.
     *
     * This listener updates the planner with weak chapters identified
     * from the BAC simulation, suggesting review sessions.
     */
    public function handle(BacSimulationCompleted $event): void
    {
        try {
            $userId = $event->getUserId();
            $weakChapters = $event->weakChapters;
            $subjectId = $event->getSubjectId();
            $score = $event->getScore();

            // If score is below 60% (12/20), suggest more practice
            if ($score < 12 && !empty($weakChapters)) {
                $this->suggestReviewTasks($userId, $weakChapters, $subjectId);
            }

            Log::info("Updated planner after BAC simulation", [
                'user_id' => $userId,
                'simulation_id' => $event->simulation->id,
                'score' => $score,
                'weak_chapters_count' => count($weakChapters),
            ]);
        } catch (\Exception $e) {
            Log::error("Failed to update planner after BAC simulation", [
                'simulation_id' => $event->simulation->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Suggest review tasks for weak chapters.
     */
    protected function suggestReviewTasks(int $userId, array $weakChapters, int $subjectId): void
    {
        // Limit to top 3 weakest chapters
        $topWeakChapters = array_slice($weakChapters, 0, 3);

        foreach ($topWeakChapters as $chapter) {
            // Check if a similar task already exists
            $existingTask = PlannerTask::where('user_id', $userId)
                ->where('subject_id', $subjectId)
                ->where('task_type', 'review')
                ->where('status', 'pending')
                ->whereJsonContains('metadata->chapter', $chapter)
                ->first();

            if (!$existingTask) {
                // Create a suggested review task
                PlannerTask::create([
                    'user_id' => $userId,
                    'subject_id' => $subjectId,
                    'task_type' => 'review',
                    'title_ar' => 'مراجعة: ' . ($chapter['title_ar'] ?? $chapter),
                    'description_ar' => 'مراجعة مقترحة بناءً على أداء المحاكاة',
                    'priority' => 'high',
                    'status' => 'suggested',
                    'suggested_duration_minutes' => 45,
                    'metadata' => [
                        'chapter' => $chapter,
                        'source' => 'bac_simulation',
                        'auto_generated' => true,
                    ],
                ]);
            }
        }
    }
}
