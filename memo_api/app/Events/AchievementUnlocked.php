<?php

namespace App\Events;

use App\Models\User;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AchievementUnlocked
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * The user who unlocked the achievement.
     */
    public User $user;

    /**
     * The achievement type.
     */
    public string $achievementType;

    /**
     * Additional data about the achievement.
     */
    public array $data;

    /**
     * Create a new event instance.
     */
    public function __construct(User $user, string $achievementType, array $data = [])
    {
        $this->user = $user;
        $this->achievementType = $achievementType;
        $this->data = $data;
    }
}
