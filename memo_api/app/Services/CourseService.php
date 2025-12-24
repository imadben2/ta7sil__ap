<?php

namespace App\Services;

use App\Models\Course;
use App\Models\CourseModule;
use App\Models\CourseLesson;
use App\Models\CourseLessonAttachment;
use App\Models\CourseQuiz;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\UploadedFile;

class CourseService
{
    /**
     * Create a new course
     */
    public function createCourse(array $data): Course
    {
        DB::beginTransaction();

        try {
            // Generate unique slug
            $data['slug'] = $this->generateUniqueSlug($data['title_ar']);

            // Handle file uploads
            if (isset($data['thumbnail']) && $data['thumbnail'] instanceof UploadedFile) {
                $data['thumbnail_url'] = $this->uploadThumbnail($data['thumbnail']);
                unset($data['thumbnail']);
            }

            if (isset($data['trailer_video']) && $data['trailer_video'] instanceof UploadedFile) {
                $data['trailer_video_url'] = $this->uploadTrailerVideo($data['trailer_video']);
                $data['trailer_video_type'] = 'upload';
                unset($data['trailer_video']);
            }

            if (isset($data['instructor_photo']) && $data['instructor_photo'] instanceof UploadedFile) {
                $data['instructor_photo_url'] = $this->uploadInstructorPhoto($data['instructor_photo']);
                unset($data['instructor_photo']);
            }

            $course = Course::create($data);

            DB::commit();

            return $course;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update a course
     */
    public function updateCourse(Course $course, array $data): Course
    {
        DB::beginTransaction();

        try {
            // Update slug if title changed
            if (isset($data['title_ar']) && $data['title_ar'] !== $course->title_ar) {
                $data['slug'] = $this->generateUniqueSlug($data['title_ar'], $course->id);
            }

            // Handle file uploads
            if (isset($data['thumbnail']) && $data['thumbnail'] instanceof UploadedFile) {
                // Delete old thumbnail
                if ($course->thumbnail_url) {
                    Storage::disk('public')->delete($course->thumbnail_url);
                }
                $data['thumbnail_url'] = $this->uploadThumbnail($data['thumbnail']);
                unset($data['thumbnail']);
            }

            if (isset($data['trailer_video']) && $data['trailer_video'] instanceof UploadedFile) {
                // Delete old trailer video
                if ($course->trailer_video_url && $course->trailer_video_type === 'upload') {
                    Storage::disk('public')->delete($course->trailer_video_url);
                }
                $data['trailer_video_url'] = $this->uploadTrailerVideo($data['trailer_video']);
                $data['trailer_video_type'] = 'upload';
                unset($data['trailer_video']);
            }

            if (isset($data['instructor_photo']) && $data['instructor_photo'] instanceof UploadedFile) {
                // Delete old photo
                if ($course->instructor_photo_url) {
                    Storage::disk('public')->delete($course->instructor_photo_url);
                }
                $data['instructor_photo_url'] = $this->uploadInstructorPhoto($data['instructor_photo']);
                unset($data['instructor_photo']);
            }

            $course->update($data);

            DB::commit();

            return $course->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Delete a course (soft delete)
     */
    public function deleteCourse(Course $course): bool
    {
        return $course->delete();
    }

    /**
     * Publish a course
     */
    public function publishCourse(Course $course): Course
    {
        $course->update([
            'is_published' => true,
            'published_at' => now(),
        ]);

        return $course;
    }

    /**
     * Unpublish a course
     */
    public function unpublishCourse(Course $course): Course
    {
        $course->update([
            'is_published' => false,
            'published_at' => null,
        ]);

        return $course;
    }

    /**
     * Create a module for a course
     */
    public function createModule(Course $course, array $data): CourseModule
    {
        $data['course_id'] = $course->id;

        // Set order if not provided
        if (!isset($data['order'])) {
            $data['order'] = $course->modules()->count() + 1;
        }

        $module = CourseModule::create($data);

        // Update course statistics
        $course->updateStatistics();

        return $module;
    }

    /**
     * Update a module
     */
    public function updateModule(CourseModule $module, array $data): CourseModule
    {
        $module->update($data);

        // Update course statistics
        $module->course->updateStatistics();

        return $module->fresh();
    }

    /**
     * Delete a module
     */
    public function deleteModule(CourseModule $module): bool
    {
        $course = $module->course;
        $deleted = $module->delete();

        // Update course statistics
        $course->updateStatistics();

        return $deleted;
    }

    /**
     * Create a lesson for a module
     */
    public function createLesson(CourseModule $module, array $data): CourseLesson
    {
        DB::beginTransaction();

        try {
            $data['course_module_id'] = $module->id;

            // Set order if not provided
            if (!isset($data['order'])) {
                $data['order'] = $module->lessons()->count() + 1;
            }

            // Handle video upload
            if (isset($data['video']) && $data['video'] instanceof UploadedFile) {
                $data['video_url'] = $this->uploadLessonVideo($data['video']);
                $data['video_type'] = 'upload';
                unset($data['video']);
            }

            // Handle thumbnail upload
            if (isset($data['video_thumbnail']) && $data['video_thumbnail'] instanceof UploadedFile) {
                $data['video_thumbnail_url'] = $this->uploadLessonThumbnail($data['video_thumbnail']);
                unset($data['video_thumbnail']);
            }

            $lesson = CourseLesson::create($data);

            // Update course statistics
            $module->course->updateStatistics();

            DB::commit();

            return $lesson;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update a lesson
     */
    public function updateLesson(CourseLesson $lesson, array $data): CourseLesson
    {
        DB::beginTransaction();

        try {
            // Handle video upload
            if (isset($data['video']) && $data['video'] instanceof UploadedFile) {
                // Delete old video
                if ($lesson->video_url && $lesson->video_type === 'upload') {
                    Storage::disk('public')->delete($lesson->video_url);
                }
                $data['video_url'] = $this->uploadLessonVideo($data['video']);
                $data['video_type'] = 'upload';
                unset($data['video']);
            }

            // Handle thumbnail upload
            if (isset($data['video_thumbnail']) && $data['video_thumbnail'] instanceof UploadedFile) {
                // Delete old thumbnail
                if ($lesson->video_thumbnail_url) {
                    Storage::disk('public')->delete($lesson->video_thumbnail_url);
                }
                $data['video_thumbnail_url'] = $this->uploadLessonThumbnail($data['video_thumbnail']);
                unset($data['video_thumbnail']);
            }

            $lesson->update($data);

            // Update course statistics
            $lesson->module->course->updateStatistics();

            DB::commit();

            return $lesson->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Delete a lesson
     */
    public function deleteLesson(CourseLesson $lesson): bool
    {
        $course = $lesson->module->course;

        // Delete video files
        if ($lesson->video_url && $lesson->video_type === 'upload') {
            Storage::disk('public')->delete($lesson->video_url);
        }

        if ($lesson->video_thumbnail_url) {
            Storage::disk('public')->delete($lesson->video_thumbnail_url);
        }

        $deleted = $lesson->delete();

        // Update course statistics
        $course->updateStatistics();

        return $deleted;
    }

    /**
     * Add attachment to a lesson
     */
    public function addAttachment(CourseLesson $lesson, UploadedFile $file): CourseLessonAttachment
    {
        $path = $file->store('lesson_attachments', 'public');
        $sizeKb = round($file->getSize() / 1024);

        $attachment = CourseLessonAttachment::create([
            'course_lesson_id' => $lesson->id,
            'file_name' => $file->getClientOriginalName(),
            'file_path' => $path,
            'file_type' => $file->getClientMimeType(),
            'file_size_kb' => $sizeKb,
        ]);

        // Update lesson has_attachments flag
        $lesson->update(['has_attachments' => true]);

        return $attachment;
    }

    /**
     * Delete an attachment
     */
    public function deleteAttachment(CourseLessonAttachment $attachment): bool
    {
        $lesson = $attachment->lesson;

        // Delete file
        Storage::disk('public')->delete($attachment->file_path);

        $deleted = $attachment->delete();

        // Update lesson has_attachments flag if no more attachments
        if ($lesson->attachments()->count() === 0) {
            $lesson->update(['has_attachments' => false]);
        }

        return $deleted;
    }

    /**
     * Assign quiz to module
     */
    public function assignQuiz(CourseModule $module, int $quizId, array $data = []): CourseQuiz
    {
        $data['course_module_id'] = $module->id;
        $data['quiz_id'] = $quizId;

        // Set order if not provided
        if (!isset($data['order'])) {
            $data['order'] = $module->quizzes()->count() + 1;
        }

        // Set default values
        $data['is_required'] = $data['is_required'] ?? true;
        $data['passing_score'] = $data['passing_score'] ?? 60;

        $courseQuiz = CourseQuiz::create($data);

        // Update course statistics
        $module->course->updateStatistics();

        return $courseQuiz;
    }

    /**
     * Remove quiz from module
     */
    public function removeQuiz(CourseQuiz $courseQuiz): bool
    {
        $course = $courseQuiz->module->course;
        $deleted = $courseQuiz->delete();

        // Update course statistics
        $course->updateStatistics();

        return $deleted;
    }

    /**
     * Reorder modules
     */
    public function reorderModules(Course $course, array $moduleOrders): void
    {
        DB::transaction(function () use ($moduleOrders) {
            foreach ($moduleOrders as $moduleId => $order) {
                CourseModule::where('id', $moduleId)->update(['order' => $order]);
            }
        });
    }

    /**
     * Reorder lessons
     */
    public function reorderLessons(CourseModule $module, array $lessonOrders): void
    {
        DB::transaction(function () use ($lessonOrders) {
            foreach ($lessonOrders as $lessonId => $order) {
                CourseLesson::where('id', $lessonId)->update(['order' => $order]);
            }
        });
    }

    // Private helper methods

    private function generateUniqueSlug(string $title, ?int $exceptId = null): string
    {
        $slug = Str::slug($title);
        $originalSlug = $slug;
        $counter = 1;

        while (true) {
            $query = Course::where('slug', $slug);

            if ($exceptId) {
                $query->where('id', '!=', $exceptId);
            }

            if (!$query->exists()) {
                return $slug;
            }

            $slug = $originalSlug . '-' . $counter;
            $counter++;
        }
    }

    private function uploadThumbnail(UploadedFile $file): string
    {
        return $file->store('courses/thumbnails', 'public');
    }

    private function uploadTrailerVideo(UploadedFile $file): string
    {
        return $file->store('courses/trailers', 'public');
    }

    private function uploadInstructorPhoto(UploadedFile $file): string
    {
        return $file->store('instructors/photos', 'public');
    }

    private function uploadLessonVideo(UploadedFile $file): string
    {
        return $file->store('lessons/videos', 'public');
    }

    private function uploadLessonThumbnail(UploadedFile $file): string
    {
        return $file->store('lessons/thumbnails', 'public');
    }
}
