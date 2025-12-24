<?php

namespace App\Events;

use App\Models\Course;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CourseUpdated
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * The course that was updated.
     */
    public Course $course;

    /**
     * The type of update (new_lesson, content_update, instructor_message).
     */
    public string $updateType;

    /**
     * Additional data about the update.
     */
    public array $data;

    /**
     * Create a new event instance.
     */
    public function __construct(Course $course, string $updateType, array $data = [])
    {
        $this->course = $course;
        $this->updateType = $updateType;
        $this->data = $data;
    }
}
