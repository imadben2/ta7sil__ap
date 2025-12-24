<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class FileService
{
    /**
     * Upload a file to storage.
     *
     * @param  UploadedFile  $file
     * @param  string  $directory
     * @param  string  $disk
     * @return array{path: string, type: string, size: int}
     */
    public function uploadFile(UploadedFile $file, string $directory = 'contents', string $disk = 'public'): array
    {
        // Generate unique filename
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();

        // Store file
        $path = $file->storeAs($directory, $filename, $disk);

        return [
            'path' => $path,
            'type' => $file->getMimeType(),
            'size' => $file->getSize(),
        ];
    }

    /**
     * Upload a video file to storage.
     *
     * @param  UploadedFile  $file
     * @param  string  $directory
     * @param  string  $disk
     * @return array{path: string, type: string, size: int, duration: int|null}
     */
    public function uploadVideo(UploadedFile $file, string $directory = 'videos', string $disk = 'public'): array
    {
        $fileInfo = $this->uploadFile($file, $directory, $disk);

        // Try to get video duration (requires FFmpeg installed)
        $duration = $this->getVideoDuration(Storage::disk($disk)->path($fileInfo['path']));

        $fileInfo['duration'] = $duration;

        return $fileInfo;
    }

    /**
     * Delete a file from storage.
     *
     * @param  string  $path
     * @param  string  $disk
     * @return bool
     */
    public function deleteFile(string $path, string $disk = 'public'): bool
    {
        if (Storage::disk($disk)->exists($path)) {
            return Storage::disk($disk)->delete($path);
        }

        return false;
    }

    /**
     * Get file information.
     *
     * @param  string  $path
     * @param  string  $disk
     * @return array{exists: bool, size: int|null, mime_type: string|null, url: string|null}
     */
    public function getFileInfo(string $path, string $disk = 'public'): array
    {
        $exists = Storage::disk($disk)->exists($path);

        if (!$exists) {
            return [
                'exists' => false,
                'size' => null,
                'mime_type' => null,
                'url' => null,
            ];
        }

        return [
            'exists' => true,
            'size' => Storage::disk($disk)->size($path),
            'mime_type' => Storage::disk($disk)->mimeType($path),
            'url' => Storage::disk($disk)->url($path),
        ];
    }

    /**
     * Generate a temporary signed URL for private files.
     *
     * @param  string  $path
     * @param  int  $expiresInMinutes
     * @param  string  $disk
     * @return string
     */
    public function getSignedUrl(string $path, int $expiresInMinutes = 60, string $disk = 'private'): string
    {
        return Storage::disk($disk)->temporaryUrl(
            $path,
            now()->addMinutes($expiresInMinutes)
        );
    }

    /**
     * Validate file upload.
     *
     * @param  UploadedFile  $file
     * @param  array  $allowedMimeTypes
     * @param  int  $maxSizeInMb
     * @return bool
     * @throws \Exception
     */
    public function validateFile(UploadedFile $file, array $allowedMimeTypes = [], int $maxSizeInMb = 50): bool
    {
        // Check file size (convert MB to bytes)
        $maxSizeInBytes = $maxSizeInMb * 1024 * 1024;
        if ($file->getSize() > $maxSizeInBytes) {
            throw new \Exception("File size exceeds maximum allowed size of {$maxSizeInMb}MB");
        }

        // Check MIME type if specified
        if (!empty($allowedMimeTypes) && !in_array($file->getMimeType(), $allowedMimeTypes)) {
            throw new \Exception('File type not allowed. Allowed types: ' . implode(', ', $allowedMimeTypes));
        }

        // Verify file is uploaded properly
        if (!$file->isValid()) {
            throw new \Exception('File upload failed or file is corrupted');
        }

        return true;
    }

    /**
     * Get YouTube video ID from URL.
     *
     * @param  string  $url
     * @return string|null
     */
    public function getYoutubeVideoId(string $url): ?string
    {
        $pattern = '/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i';

        if (preg_match($pattern, $url, $matches)) {
            return $matches[1];
        }

        return null;
    }

    /**
     * Get video duration in seconds (requires FFmpeg).
     *
     * @param  string  $filePath
     * @return int|null
     */
    private function getVideoDuration(string $filePath): ?int
    {
        try {
            // Check if FFmpeg is available
            if (!$this->isFFmpegAvailable()) {
                return null;
            }

            $command = "ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " . escapeshellarg($filePath);
            $duration = shell_exec($command);

            return $duration ? (int) round((float) $duration) : null;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Check if FFmpeg is installed and available.
     *
     * @return bool
     */
    private function isFFmpegAvailable(): bool
    {
        $output = shell_exec('ffprobe -version 2>&1');
        return $output !== null && stripos($output, 'ffprobe') !== false;
    }

    /**
     * Get file extension from MIME type.
     *
     * @param  string  $mimeType
     * @return string
     */
    public function getExtensionFromMimeType(string $mimeType): string
    {
        $mimeMap = [
            'application/pdf' => 'pdf',
            'application/msword' => 'doc',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
            'video/mp4' => 'mp4',
            'video/mpeg' => 'mpeg',
            'video/quicktime' => 'mov',
            'video/x-msvideo' => 'avi',
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/gif' => 'gif',
        ];

        return $mimeMap[$mimeType] ?? 'bin';
    }
}
