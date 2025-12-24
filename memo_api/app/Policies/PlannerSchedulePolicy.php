<?php

namespace App\Policies;

use App\Models\PlannerSchedule;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class PlannerSchedulePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        // Any authenticated user can view their own schedules
        return true;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Users can only view their own schedules
        // Admins can view all schedules
        return $user->id === $plannerSchedule->user_id || $user->is_admin;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        // Any authenticated user can create schedules for themselves
        return true;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Users can only update their own schedules
        return $user->id === $plannerSchedule->user_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Users can only delete their own schedules
        // Prevent deletion of active schedules with in-progress sessions
        if ($plannerSchedule->is_active && $plannerSchedule->studySessions()->where('status', 'inProgress')->exists()) {
            return false;
        }

        return $user->id === $plannerSchedule->user_id;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Users can restore their own soft-deleted schedules
        return $user->id === $plannerSchedule->user_id;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Only admins can force delete schedules
        return $user->is_admin ?? false;
    }

    /**
     * Determine whether the user can activate the schedule.
     */
    public function activate(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Users can only activate their own schedules
        return $user->id === $plannerSchedule->user_id;
    }

    /**
     * Determine whether the user can adapt/modify the schedule.
     */
    public function adapt(User $user, PlannerSchedule $plannerSchedule): bool
    {
        // Users can only adapt their own schedules
        return $user->id === $plannerSchedule->user_id;
    }
}
