<?php

namespace App\Policies;

use App\Models\PlannerStudySession;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class PlannerStudySessionPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true; // Any authenticated user can view their own sessions
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, PlannerStudySession $plannerStudySession): bool
    {
        return $user->id === $plannerStudySession->user_id || $user->is_admin;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return true; // Any authenticated user can create sessions
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, PlannerStudySession $plannerStudySession): bool
    {
        return $user->id === $plannerStudySession->user_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, PlannerStudySession $plannerStudySession): bool
    {
        // Cannot delete in-progress sessions
        if ($plannerStudySession->status === 'inProgress') {
            return false;
        }
        return $user->id === $plannerStudySession->user_id;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, PlannerStudySession $plannerStudySession): bool
    {
        return $user->id === $plannerStudySession->user_id;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, PlannerStudySession $plannerStudySession): bool
    {
        return $user->is_admin ?? false;
    }

    /**
     * Custom policy methods for session actions
     */
    public function start(User $user, PlannerStudySession $session): bool
    {
        return $user->id === $session->user_id && in_array($session->status, ['scheduled', 'paused']);
    }

    public function pause(User $user, PlannerStudySession $session): bool
    {
        return $user->id === $session->user_id && $session->status === 'inProgress';
    }

    public function resume(User $user, PlannerStudySession $session): bool
    {
        return $user->id === $session->user_id && $session->status === 'paused';
    }

    public function complete(User $user, PlannerStudySession $session): bool
    {
        return $user->id === $session->user_id && in_array($session->status, ['inProgress', 'paused']);
    }

    public function skip(User $user, PlannerStudySession $session): bool
    {
        return $user->id === $session->user_id && $session->status === 'scheduled';
    }

    public function reschedule(User $user, PlannerStudySession $session): bool
    {
        return $user->id === $session->user_id && !in_array($session->status, ['completed', 'missed']);
    }
}
