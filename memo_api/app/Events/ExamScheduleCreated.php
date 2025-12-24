<?php

namespace App\Events;

use App\Models\ExamSchedule;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ExamScheduleCreated
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * The exam schedule instance.
     */
    public ExamSchedule $exam;

    /**
     * Create a new event instance.
     */
    public function __construct(ExamSchedule $exam)
    {
        $this->exam = $exam;
    }
}
