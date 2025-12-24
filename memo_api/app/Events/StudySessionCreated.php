<?php

namespace App\Events;

use App\Models\StudySession;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class StudySessionCreated
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * The study session instance.
     */
    public StudySession $session;

    /**
     * Create a new event instance.
     */
    public function __construct(StudySession $session)
    {
        $this->session = $session;
    }
}
