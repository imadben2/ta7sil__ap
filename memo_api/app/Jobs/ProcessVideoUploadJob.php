<?php

namespace App\Jobs;

use App\Models\CourseLesson;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;

/**
 * Process uploaded video (compression, thumbnail generation, etc.)
 */
class ProcessVideoUploadJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 2;
    public $timeout = 600; // 10 minutes for large videos

    /**
     * Create a new job instance.
     */
    public function __construct(
        public int $lessonId,
        public string $videoPath
    ) {
        $this->onQueue('default');
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $lesson = CourseLesson::find($this->lessonId);

        if (!$lesson || !Storage::exists($this->videoPath)) {
            \Log::error("ProcessVideoUploadJob: Lesson or video not found");
            return;
        }

        try {
            // Here you would implement video processing:
            // - Generate thumbnail if not provided
            // - Compress video for different qualities
            // - Extract video duration
            // - Generate preview clips

            // For now, just log
            \Log::info("Video processed for lesson {$this->lessonId}");

            // Update lesson status
            $lesson->update([
                'processing_status' => 'completed',
            ]);
        } catch (\Exception $e) {
            \Log::error("Failed to process video for lesson {$this->lessonId}: {$e->getMessage()}");

            $lesson->update([
                'processing_status' => 'failed',
            ]);

            throw $e;
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        \Log::error("ProcessVideoUploadJob failed for lesson {$this->lessonId}: {$exception->getMessage()}");
    }
}
