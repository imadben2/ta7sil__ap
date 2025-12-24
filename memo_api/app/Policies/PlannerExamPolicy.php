<?php

namespace App\Policies;

use App\Models\PlannerExam;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class PlannerExamPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true; // Any authenticated user can view their own exams
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, PlannerExam $plannerExam): bool
    {
        return $user->id === $plannerExam->user_id || $user->is_admin;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return true; // Any authenticated user can create exams
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, PlannerExam $plannerExam): bool
    {
        // Cannot update exams after result is recorded
        if ($plannerExam->score !== null) {
            return false;
        }
        return $user->id === $plannerExam->user_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, PlannerExam $plannerExam): bool
    {
        // Cannot delete exams that have triggered adaptation
        if ($plannerExam->triggered_adaptation) {
            return false;
        }
        return $user->id === $plannerExam->user_id;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, PlannerExam $plannerExam): bool
    {
        return $user->id === $plannerExam->user_id;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, PlannerExam $plannerExam): bool
    {
        return $user->is_admin ?? false;
    }

    /**
     * Determine whether the user can record exam results.
     */
    public function recordResult(User $user, PlannerExam $exam): bool
    {
        return $user->id === $exam->user_id && $exam->score === null;
    }
}
