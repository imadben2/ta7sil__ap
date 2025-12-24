<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;

class BacSubject extends Model
{
    protected $fillable = [
        'bac_year_id',
        'bac_session_id',
        'subject_id',
        'academic_stream_id',
        'title_ar',
        'file_path',
        'correction_file_path',
        'duration_minutes',
        'total_points',
        'difficulty_rating',
        'average_score',
        'views_count',
        'downloads_count',
        'simulations_count'
    ];

    protected $casts = [
        'duration_minutes' => 'integer',
        'total_points' => 'decimal:2',
        'difficulty_rating' => 'decimal:2',
        'average_score' => 'decimal:2',
        'views_count' => 'integer',
        'downloads_count' => 'integer',
        'simulations_count' => 'integer',
    ];

    /**
     * Get the BAC year
     */
    public function bacYear()
    {
        return $this->belongsTo(BacYear::class);
    }

    /**
     * Get the BAC session
     */
    public function bacSession()
    {
        return $this->belongsTo(BacSession::class);
    }

    /**
     * Get the subject
     */
    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the academic stream
     */
    public function academicStream()
    {
        return $this->belongsTo(AcademicStream::class);
    }

    /**
     * Get all chapters for this BAC subject
     */
    public function chapters()
    {
        return $this->hasMany(BacSubjectChapter::class)->orderBy('order');
    }

    /**
     * Get all simulations for this BAC subject
     */
    public function simulations()
    {
        return $this->hasMany(BacSimulation::class);
    }

    /**
     * Get the base URL from the current request (handles emulator 10.0.2.2)
     */
    protected static function getBaseUrl()
    {
        // Try to get URL from current request (works correctly with emulator)
        if (request()) {
            $scheme = request()->getScheme();
            $host = request()->getHost();
            $port = request()->getPort();

            // Only add port if non-standard
            if (($scheme === 'http' && $port != 80) || ($scheme === 'https' && $port != 443)) {
                return "{$scheme}://{$host}:{$port}";
            }
            return "{$scheme}://{$host}";
        }

        // Fallback to config
        return rtrim(config('app.url'), '/');
    }

    /**
     * Get full URL for the PDF file (uses stream endpoint for better reliability)
     */
    public function getFileUrl()
    {
        if (!$this->file_path) {
            return null;
        }
        // Use stream endpoint with chunked download for PHP dev server compatibility
        return self::getBaseUrl() . '/api/v1/bac/' . $this->id . '/stream?type=subject';
    }

    /**
     * Get full URL for the correction PDF file (uses stream endpoint)
     */
    public function getCorrectionUrl()
    {
        if (!$this->correction_file_path) {
            return null;
        }
        // Use stream endpoint with chunked download for PHP dev server compatibility
        return self::getBaseUrl() . '/api/v1/bac/' . $this->id . '/stream?type=correction';
    }

    /**
     * Generate signed URL for file download
     */
    public function getSignedDownloadUrl()
    {
        return URL::temporarySignedRoute(
            'api.bac.download',
            now()->addHours(1),
            ['id' => $this->id, 'type' => 'subject']
        );
    }

    /**
     * Generate signed URL for correction file download
     */
    public function getSignedCorrectionUrl()
    {
        if (!$this->correction_file_path) {
            return null;
        }

        return URL::temporarySignedRoute(
            'api.bac.download',
            now()->addHours(1),
            ['id' => $this->id, 'type' => 'correction']
        );
    }

    /**
     * Increment views count
     */
    public function incrementViews()
    {
        $this->increment('views_count');
    }

    /**
     * Increment downloads count
     */
    public function incrementDownloads()
    {
        $this->increment('downloads_count');
    }

    /**
     * Increment simulations count
     */
    public function incrementSimulations()
    {
        $this->increment('simulations_count');
    }

    /**
     * Update average score based on new simulation results
     */
    public function updateAverageScore($newScore)
    {
        if ($this->simulations_count <= 1) {
            $this->update(['average_score' => $newScore]);
        } else {
            // Calculate new average
            $currentTotal = $this->average_score * ($this->simulations_count - 1);
            $newAverage = ($currentTotal + $newScore) / $this->simulations_count;
            $this->update(['average_score' => round($newAverage, 2)]);
        }
    }
}
