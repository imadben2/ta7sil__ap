<?php

namespace App\Policies;

use App\Models\PlannerSubject;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class PlannerSubjectPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true; // Any authenticated user can view their own planner subjects
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, PlannerSubject $plannerSubject): bool
    {
        return $user->id === $plannerSubject->user_id || $user->is_admin;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return true; // Any authenticated user can add subjects to their planner
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, PlannerSubject $plannerSubject): bool
    {
        return $user->id === $plannerSubject->user_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, PlannerSubject $plannerSubject): bool
    {
        return $user->id === $plannerSubject->user_id;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, PlannerSubject $plannerSubject): bool
    {
        return $user->id === $plannerSubject->user_id;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, PlannerSubject $plannerSubject): bool
    {
        return $user->is_admin ?? false;
    }
}
