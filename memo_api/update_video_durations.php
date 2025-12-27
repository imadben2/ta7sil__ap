<?php

/**
 * Script to update video durations for course lessons
 * Run with: php update_video_durations.php
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\CourseLesson;

echo "🎬 Starting video duration update...\n\n";

// Get all lessons with video_url from the tahfid course (course_id = 17)
$lessons = CourseLesson::whereHas('module', function ($q) {
    $q->where('course_id', 17); // Tahfid course
})->whereNotNull('video_url')
  ->where('video_duration_seconds', 0)
  ->get();

echo "Found " . $lessons->count() . " lessons to process\n\n";

$updated = 0;
$errors = 0;

foreach ($lessons as $lesson) {
    $videoUrl = $lesson->video_url;

    // Convert URL to file path
    $relativePath = str_replace('/storage/', '/storage/app/public/', $videoUrl);
    $fullPath = __DIR__ . $relativePath;

    if (!file_exists($fullPath)) {
        echo "❌ [{$lesson->id}] File not found: " . basename($videoUrl) . "\n";
        $errors++;
        continue;
    }

    // Get duration by reading MP4 file directly
    $duration = getVideoDurationFromMP4($fullPath);

    if ($duration > 0) {
        $lesson->video_duration_seconds = $duration;
        $lesson->save();

        $minutes = floor($duration / 60);
        $seconds = $duration % 60;
        echo "✅ [{$lesson->id}] " . mb_substr($lesson->title_ar, 0, 30) . " -> {$minutes}m {$seconds}s\n";
        $updated++;
    } else {
        echo "⚠️  [{$lesson->id}] Could not parse: " . basename($videoUrl) . "\n";
        $errors++;
    }
}

echo "\n" . str_repeat("=", 50) . "\n";
echo "📊 Summary:\n";
echo "   Updated: {$updated}\n";
echo "   Errors: {$errors}\n";
echo "   Total: " . $lessons->count() . "\n";

/**
 * Get duration by reading MP4 file structure
 * Searches both from start and end for moov atom
 */
function getVideoDurationFromMP4($filePath) {
    $fileSize = filesize($filePath);
    if ($fileSize < 8) return 0;

    // Try reading from the start first
    $duration = searchMoovFromStart($filePath, $fileSize);
    if ($duration > 0) return $duration;

    // If not found, try searching from the end (common in streaming MP4s)
    $duration = searchMoovFromEnd($filePath, $fileSize);
    return $duration;
}

function searchMoovFromStart($filePath, $fileSize) {
    $handle = @fopen($filePath, 'rb');
    if (!$handle) return 0;

    $duration = 0;
    $maxSearch = min($fileSize, 100 * 1024 * 1024); // Max 100MB search
    $offset = 0;

    while ($offset < $maxSearch) {
        fseek($handle, $offset);
        $atomHeader = fread($handle, 8);
        if (strlen($atomHeader) < 8) break;

        $atomSize = unpack('N', substr($atomHeader, 0, 4))[1];
        $atomType = substr($atomHeader, 4, 4);

        // Handle size=0 (atom extends to EOF)
        if ($atomSize == 0) {
            $atomSize = $fileSize - $offset;
        }
        // Handle extended size
        elseif ($atomSize == 1) {
            $extSize = fread($handle, 8);
            if (strlen($extSize) < 8) break;
            $atomSize = unpack('J', $extSize)[1]; // 64-bit big endian
        }

        if ($atomSize < 8 || $atomSize > $fileSize) break;

        if ($atomType === 'moov') {
            $duration = parseMoov($handle, $offset + 8, $atomSize - 8);
            break;
        }

        $offset += $atomSize;
    }

    fclose($handle);
    return $duration;
}

function searchMoovFromEnd($filePath, $fileSize) {
    $handle = @fopen($filePath, 'rb');
    if (!$handle) return 0;

    $duration = 0;
    $searchSize = min($fileSize, 50 * 1024 * 1024); // Search last 50MB

    // Read last chunk and search for 'moov' pattern
    $startPos = max(0, $fileSize - $searchSize);
    fseek($handle, $startPos);
    $chunk = fread($handle, $searchSize);

    // Find 'moov' in the chunk
    $moovPos = strpos($chunk, 'moov');
    if ($moovPos !== false && $moovPos >= 4) {
        // Get size from 4 bytes before 'moov'
        $sizeBytes = substr($chunk, $moovPos - 4, 4);
        $moovSize = unpack('N', $sizeBytes)[1];

        // Position in file
        $moovStart = $startPos + $moovPos - 4;

        // Parse moov content
        $duration = parseMoov($handle, $moovStart + 8, $moovSize - 8);
    }

    fclose($handle);
    return $duration;
}

function parseMoov($handle, $moovDataStart, $moovDataSize) {
    $offset = $moovDataStart;
    $endOffset = $moovDataStart + $moovDataSize;

    while ($offset < $endOffset) {
        fseek($handle, $offset);
        $header = fread($handle, 8);
        if (strlen($header) < 8) break;

        $size = unpack('N', substr($header, 0, 4))[1];
        $type = substr($header, 4, 4);

        if ($size < 8) break;

        if ($type === 'mvhd') {
            $mvhdData = fread($handle, min($size - 8, 120));
            if (strlen($mvhdData) < 20) break;

            $version = ord($mvhdData[0]);

            if ($version === 0) {
                // 32-bit: skip 4 bytes (flags+version), 4 creation, 4 modification
                // timescale at offset 12, duration at offset 16
                if (strlen($mvhdData) >= 20) {
                    $timescale = unpack('N', substr($mvhdData, 12, 4))[1];
                    $durationVal = unpack('N', substr($mvhdData, 16, 4))[1];
                }
            } else {
                // 64-bit: skip 4 bytes, 8 creation, 8 modification
                // timescale at offset 20, duration at offset 24 (8 bytes)
                if (strlen($mvhdData) >= 32) {
                    $timescale = unpack('N', substr($mvhdData, 20, 4))[1];
                    $durationVal = unpack('J', substr($mvhdData, 24, 8))[1];
                }
            }

            if (isset($timescale) && isset($durationVal) && $timescale > 0) {
                return (int) round($durationVal / $timescale);
            }
            break;
        }

        $offset += $size;
    }

    return 0;
}
