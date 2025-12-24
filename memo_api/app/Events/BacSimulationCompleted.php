<?php

namespace App\Events;

use App\Models\BacSimulation;
use App\Models\UserBacPerformance;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class BacSimulationCompleted
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * The completed simulation instance.
     */
    public BacSimulation $simulation;

    /**
     * The user's performance record.
     */
    public UserBacPerformance $performance;

    /**
     * Weak chapters identified from the simulation.
     */
    public array $weakChapters;

    /**
     * Create a new event instance.
     */
    public function __construct(BacSimulation $simulation, UserBacPerformance $performance, array $weakChapters = [])
    {
        $this->simulation = $simulation;
        $this->performance = $performance;
        $this->weakChapters = $weakChapters;
    }

    /**
     * Get the user ID from the simulation.
     */
    public function getUserId(): int
    {
        return $this->simulation->user_id;
    }

    /**
     * Get the subject ID from the BAC subject.
     */
    public function getSubjectId(): int
    {
        return $this->simulation->bacSubject->subject_id;
    }

    /**
     * Get the user's score from the simulation.
     */
    public function getScore(): float
    {
        return $this->simulation->user_score ?? 0;
    }
}
