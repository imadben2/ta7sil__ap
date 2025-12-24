<?php

namespace App\Services;

use App\Models\Content;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ContentService
{
    protected FileService $fileService;

    public function __construct(FileService $fileService)
    {
        $this->fileService = $fileService;
    }

    /**
     * Create new content.
     *
     * @param  array  $data
     * @param  User|null  $creator
     * @return Content
     */
    public function createContent(array $data, ?User $creator = null): Content
    {
        DB::beginTransaction();

        try {
            // Generate slug from title
            $data['slug'] = $this->generateSlug($data['title_ar']);

            // Set creator
            if ($creator) {
                $data['created_by'] = $creator->id;
            }

            // Handle file upload if present
            if (isset($data['file']) && $data['file'] instanceof UploadedFile) {
                $fileInfo = $this->handleFileUpload($data['file']);
                $data = array_merge($data, $fileInfo);
                unset($data['file']);
            }

            // Handle video upload if present
            if (isset($data['video_file']) && $data['video_file'] instanceof UploadedFile) {
                $videoInfo = $this->handleVideoUpload($data['video_file']);
                $data = array_merge($data, $videoInfo);
                unset($data['video_file']);
            }

            // Handle YouTube URL
            if (isset($data['youtube_url']) && !empty($data['youtube_url'])) {
                $data['video_type'] = 'youtube';
                $data['video_url'] = $data['youtube_url'];
                $data['has_video'] = true;
                unset($data['youtube_url']);
            }

            // Create content
            $content = Content::create($data);

            DB::commit();

            return $content;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update existing content.
     *
     * @param  Content  $content
     * @param  array  $data
     * @param  User|null  $updater
     * @return Content
     */
    public function updateContent(Content $content, array $data, ?User $updater = null): Content
    {
        DB::beginTransaction();

        try {
            // Update slug if title changed
            if (isset($data['title_ar']) && $data['title_ar'] !== $content->title_ar) {
                $data['slug'] = $this->generateSlug($data['title_ar']);
            }

            // Set updater
            if ($updater) {
                $data['updated_by'] = $updater->id;
            }

            // Handle new file upload
            if (isset($data['file']) && $data['file'] instanceof UploadedFile) {
                // Delete old file if exists
                if ($content->has_file && $content->file_path) {
                    $this->fileService->deleteFile($content->file_path);
                }

                // Upload new file
                $fileInfo = $this->handleFileUpload($data['file']);
                $data = array_merge($data, $fileInfo);
                unset($data['file']);
            }

            // Handle delete file request
            if (isset($data['delete_file']) && $data['delete_file'] === true) {
                if ($content->has_file && $content->file_path) {
                    $this->fileService->deleteFile($content->file_path);
                }
                $data['has_file'] = false;
                $data['file_path'] = null;
                $data['file_type'] = null;
                $data['file_size'] = null;
                unset($data['delete_file']);
            }

            // Handle new video upload
            if (isset($data['video_file']) && $data['video_file'] instanceof UploadedFile) {
                // Delete old video if exists
                if ($content->has_video && $content->video_type === 'upload' && $content->video_url) {
                    $this->fileService->deleteFile($content->video_url);
                }

                // Upload new video
                $videoInfo = $this->handleVideoUpload($data['video_file']);
                $data = array_merge($data, $videoInfo);
                unset($data['video_file']);
            }

            // Handle YouTube URL update
            if (isset($data['youtube_url'])) {
                if (!empty($data['youtube_url'])) {
                    // Delete old uploaded video if switching from upload to YouTube
                    if ($content->has_video && $content->video_type === 'upload' && $content->video_url) {
                        $this->fileService->deleteFile($content->video_url);
                    }

                    $data['video_type'] = 'youtube';
                    $data['video_url'] = $data['youtube_url'];
                    $data['has_video'] = true;
                } else {
                    // Remove video
                    if ($content->has_video && $content->video_type === 'upload' && $content->video_url) {
                        $this->fileService->deleteFile($content->video_url);
                    }
                    $data['has_video'] = false;
                    $data['video_type'] = null;
                    $data['video_url'] = null;
                    $data['video_duration_seconds'] = null;
                }
                unset($data['youtube_url']);
            }

            // Update content
            $content->update($data);

            DB::commit();

            return $content->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Delete content and associated files.
     *
     * @param  Content  $content
     * @return bool
     */
    public function deleteContent(Content $content): bool
    {
        DB::beginTransaction();

        try {
            // Delete associated files
            if ($content->has_file && $content->file_path) {
                $this->fileService->deleteFile($content->file_path);
            }

            // Delete associated video (if uploaded, not YouTube)
            if ($content->has_video && $content->video_type === 'upload' && $content->video_url) {
                $this->fileService->deleteFile($content->video_url);
            }

            // Soft delete content
            $content->delete();

            DB::commit();

            return true;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Publish content.
     *
     * @param  Content  $content
     * @param  Carbon|null  $publishAt
     * @return Content
     */
    public function publishContent(Content $content, ?Carbon $publishAt = null): Content
    {
        $content->update([
            'is_published' => true,
            'published_at' => $publishAt ?? now(),
        ]);

        return $content->fresh();
    }

    /**
     * Unpublish content.
     *
     * @param  Content  $content
     * @return Content
     */
    public function unpublishContent(Content $content): Content
    {
        $content->update([
            'is_published' => false,
            'published_at' => null,
        ]);

        return $content->fresh();
    }

    /**
     * Generate slug from Arabic title.
     *
     * @param  string  $title
     * @return string
     */
    public function generateSlug(string $title): string
    {
        // Transliterate Arabic to Latin characters
        $slug = $this->transliterateArabic($title);

        // Generate slug using Laravel's Str helper
        $slug = Str::slug($slug);

        // Ensure uniqueness
        $originalSlug = $slug;
        $counter = 1;

        while (Content::where('slug', $slug)->exists()) {
            $slug = $originalSlug . '-' . $counter;
            $counter++;
        }

        return $slug;
    }

    /**
     * Handle file upload.
     *
     * @param  UploadedFile  $file
     * @return array
     */
    protected function handleFileUpload(UploadedFile $file): array
    {
        // Validate file
        $allowedMimeTypes = [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ];

        $this->fileService->validateFile($file, $allowedMimeTypes, 50);

        // Upload file
        $fileInfo = $this->fileService->uploadFile($file, 'contents/files');

        return [
            'has_file' => true,
            'file_path' => $fileInfo['path'],
            'file_type' => $fileInfo['type'],
            'file_size' => $fileInfo['size'],
        ];
    }

    /**
     * Handle video upload.
     *
     * @param  UploadedFile  $file
     * @return array
     */
    protected function handleVideoUpload(UploadedFile $file): array
    {
        // Validate video file
        $allowedMimeTypes = [
            'video/mp4',
            'video/mpeg',
            'video/quicktime',
            'video/x-msvideo',
        ];

        $this->fileService->validateFile($file, $allowedMimeTypes, 500); // 500MB max for videos

        // Upload video
        $videoInfo = $this->fileService->uploadVideo($file, 'contents/videos');

        return [
            'has_video' => true,
            'video_type' => 'upload',
            'video_url' => $videoInfo['path'],
            'video_duration_seconds' => $videoInfo['duration'],
        ];
    }

    /**
     * Transliterate Arabic text to Latin characters.
     *
     * @param  string  $text
     * @return string
     */
    protected function transliterateArabic(string $text): string
    {
        $arabic = [
            'ا' => 'a', 'أ' => 'a', 'إ' => 'i', 'آ' => 'a',
            'ب' => 'b', 'ت' => 't', 'ث' => 'th', 'ج' => 'j',
            'ح' => 'h', 'خ' => 'kh', 'د' => 'd', 'ذ' => 'dh',
            'ر' => 'r', 'ز' => 'z', 'س' => 's', 'ش' => 'sh',
            'ص' => 's', 'ض' => 'd', 'ط' => 't', 'ظ' => 'z',
            'ع' => 'a', 'غ' => 'gh', 'ف' => 'f', 'ق' => 'q',
            'ك' => 'k', 'ل' => 'l', 'م' => 'm', 'ن' => 'n',
            'ه' => 'h', 'و' => 'w', 'ي' => 'y', 'ى' => 'a',
            'ة' => 'h', 'ئ' => 'e', 'ؤ' => 'o',
        ];

        return str_replace(array_keys($arabic), array_values($arabic), $text);
    }

    /**
     * Increment view count.
     *
     * @param  Content  $content
     * @return void
     */
    public function incrementViews(Content $content): void
    {
        $content->increment('views_count');
    }

    /**
     * Increment download count.
     *
     * @param  Content  $content
     * @return void
     */
    public function incrementDownloads(Content $content): void
    {
        $content->increment('downloads_count');
    }
}
