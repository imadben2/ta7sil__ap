<?php

namespace App\Services;

use App\Models\BacSubject;
use App\Models\BacYear;
use App\Models\BacSession;
use App\Models\BacSubjectChapter;
use App\Models\BacSimulation;
use App\Models\UserBacPerformance;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class BacService
{
    /**
     * Create a new BAC subject with file upload
     */
    public function createBacSubject(array $data, ?UploadedFile $file = null, ?UploadedFile $correctionFile = null)
    {
        // Upload main file
        if ($file) {
            $filePath = $this->uploadFile($file, 'bac_subjects');
            $data['file_path'] = $filePath;
        }

        // Upload correction file if provided
        if ($correctionFile) {
            $correctionPath = $this->uploadFile($correctionFile, 'bac_corrections');
            $data['correction_file_path'] = $correctionPath;
        }

        // Create BAC subject
        $bacSubject = BacSubject::create($data);

        return $bacSubject;
    }

    /**
     * Update BAC subject
     */
    public function updateBacSubject(BacSubject $bacSubject, array $data, ?UploadedFile $file = null, ?UploadedFile $correctionFile = null)
    {
        // Upload and replace main file if provided
        if ($file) {
            // Delete old file
            if ($bacSubject->file_path) {
                Storage::disk('public')->delete($bacSubject->file_path);
            }

            $filePath = $this->uploadFile($file, 'bac_subjects');
            $data['file_path'] = $filePath;
        }

        // Upload and replace correction file if provided
        if ($correctionFile) {
            // Delete old correction file
            if ($bacSubject->correction_file_path) {
                Storage::disk('public')->delete($bacSubject->correction_file_path);
            }

            $correctionPath = $this->uploadFile($correctionFile, 'bac_corrections');
            $data['correction_file_path'] = $correctionPath;
        }

        // Update BAC subject
        $bacSubject->update($data);

        return $bacSubject;
    }

    /**
     * Delete BAC subject and its files
     */
    public function deleteBacSubject(BacSubject $bacSubject)
    {
        // Delete files from storage
        if ($bacSubject->file_path) {
            Storage::disk('public')->delete($bacSubject->file_path);
        }

        if ($bacSubject->correction_file_path) {
            Storage::disk('public')->delete($bacSubject->correction_file_path);
        }

        // Delete the record
        $bacSubject->delete();
    }

    /**
     * Upload a file to storage
     */
    protected function uploadFile(UploadedFile $file, string $directory): string
    {
        $fileName = time() . '_' . Str::slug(pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME)) . '.' . $file->getClientOriginalExtension();

        return $file->storeAs($directory, $fileName, 'public');
    }

    /**
     * Get BAC subjects with filters
     */
    public function getBacSubjects(array $filters = [])
    {
        $query = BacSubject::with(['bacYear', 'bacSession', 'subject', 'academicStream', 'chapters']);

        if (isset($filters['year_id'])) {
            $query->where('bac_year_id', $filters['year_id']);
        }

        if (isset($filters['session_id'])) {
            $query->where('bac_session_id', $filters['session_id']);
        }

        if (isset($filters['subject_id'])) {
            $query->where('subject_id', $filters['subject_id']);
        }

        if (isset($filters['stream_id'])) {
            $query->where('academic_stream_id', $filters['stream_id']);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    /**
     * Get BAC subject by ID with relationships
     */
    public function getBacSubjectById($id)
    {
        return BacSubject::with(['bacYear', 'bacSession', 'subject', 'academicStream', 'chapters'])
            ->findOrFail($id);
    }

    /**
     * Add chapters to BAC subject
     */
    public function addChapters(BacSubject $bacSubject, array $chapters)
    {
        foreach ($chapters as $index => $chapterData) {
            BacSubjectChapter::create([
                'bac_subject_id' => $bacSubject->id,
                'title_ar' => $chapterData['title_ar'],
                'order' => $index + 1
            ]);
        }
    }

    /**
     * Update chapters for BAC subject
     */
    public function updateChapters(BacSubject $bacSubject, array $chapters)
    {
        // Delete existing chapters
        $bacSubject->chapters()->delete();

        // Add new chapters
        $this->addChapters($bacSubject, $chapters);
    }

    /**
     * Get download file path
     */
    public function getDownloadPath(BacSubject $bacSubject, string $type = 'subject')
    {
        if ($type === 'correction') {
            return $bacSubject->correction_file_path;
        }

        return $bacSubject->file_path;
    }

    /**
     * Get BAC years for filters
     */
    public function getBacYears()
    {
        return BacYear::active()->orderBy('year', 'desc')->get();
    }

    /**
     * Get BAC sessions
     */
    public function getBacSessions()
    {
        return BacSession::all();
    }

    /**
     * Get statistics for BAC subjects
     */
    public function getStatistics()
    {
        return [
            'total_subjects' => BacSubject::count(),
            'total_downloads' => BacSubject::sum('downloads_count'),
            'total_views' => BacSubject::sum('views_count'),
            'subjects_by_year' => BacSubject::selectRaw('bac_year_id, COUNT(*) as count')
                ->groupBy('bac_year_id')
                ->with('bacYear')
                ->get(),
            'most_downloaded' => BacSubject::orderBy('downloads_count', 'desc')
                ->with(['bacYear', 'bacSession', 'subject'])
                ->limit(10)
                ->get(),
        ];
    }

    /**
     * Get recommended BAC subjects for a user based on their performance
     *
     * Algorithm:
     * 1. Get user's weak chapters from their performance records
     * 2. Exclude subjects attempted recently (within 2 weeks)
     * 3. Prioritize subjects with lower difficulty for weak areas
     * 4. Vary years (mix of recent and older exams)
     */
    public function getRecommendedSubjects(User $user, int $limit = 5)
    {
        // Get user's performances to identify weak areas
        $performances = UserBacPerformance::where('user_id', $user->id)->get();

        // Extract weak chapters and subject IDs where performance is lacking
        $weakSubjectIds = [];
        $weakChapters = [];

        foreach ($performances as $performance) {
            // If average score is below 60%, mark as weak subject
            if ($performance->average_score < 12) {
                $weakSubjectIds[] = $performance->subject_id;
            }

            // Collect weak chapters
            if (!empty($performance->weak_chapters)) {
                $weakChapters = array_merge($weakChapters, $performance->weak_chapters);
            }
        }

        // Get recently attempted BAC subjects (within 2 weeks)
        $recentAttempts = BacSimulation::where('user_id', $user->id)
            ->where('created_at', '>=', now()->subWeeks(2))
            ->pluck('bac_subject_id')
            ->toArray();

        // Build query for recommendations
        $query = BacSubject::with(['bacYear', 'bacSession', 'subject', 'academicStream'])
            ->whereNotIn('id', $recentAttempts);

        // Prioritize weak subjects if available
        if (!empty($weakSubjectIds)) {
            $query->orderByRaw('CASE WHEN subject_id IN (' . implode(',', $weakSubjectIds) . ') THEN 0 ELSE 1 END');
        }

        // Order by difficulty (easier first for weak subjects)
        $query->orderBy('difficulty_rating', 'asc')
            ->orderBy('bac_year_id', 'desc'); // Prefer recent years

        $recommendations = $query->limit($limit)->get();

        return $recommendations->map(function ($bacSubject) use ($weakSubjectIds, $weakChapters) {
            // Determine the reason for recommendation
            $reason = 'تدريب متنوع';

            if (in_array($bacSubject->subject_id, $weakSubjectIds)) {
                $reason = 'تحسين الأداء في ' . $bacSubject->subject->name_ar;
            } elseif (!empty($weakChapters)) {
                // Check if this exam covers any weak chapters
                $coveredChapters = $bacSubject->chapters->pluck('title_ar')->toArray();
                $matchingChapters = array_intersect($coveredChapters, $weakChapters);
                if (!empty($matchingChapters)) {
                    $reason = 'تمرين على: ' . implode(', ', array_slice($matchingChapters, 0, 2));
                }
            }

            return [
                'id' => $bacSubject->id,
                'title_ar' => $bacSubject->title_ar,
                'year' => $bacSubject->bacYear->year,
                'session' => $bacSubject->bacSession->name_ar,
                'subject' => [
                    'id' => $bacSubject->subject->id,
                    'name_ar' => $bacSubject->subject->name_ar,
                ],
                'stream' => [
                    'id' => $bacSubject->academicStream->id,
                    'name_ar' => $bacSubject->academicStream->name_ar,
                ],
                'duration_minutes' => $bacSubject->duration_minutes,
                'difficulty_rating' => $bacSubject->difficulty_rating,
                'reason' => $reason,
            ];
        });
    }

    /**
     * Get BAC subjects for exam preparation based on upcoming exams from planner
     */
    public function getSubjectsForExamPrep(User $user, int $subjectId, int $limit = 3)
    {
        // Get recently attempted for this subject
        $recentAttempts = BacSimulation::where('user_id', $user->id)
            ->whereHas('bacSubject', function ($q) use ($subjectId) {
                $q->where('subject_id', $subjectId);
            })
            ->where('created_at', '>=', now()->subWeeks(2))
            ->pluck('bac_subject_id')
            ->toArray();

        return BacSubject::with(['bacYear', 'bacSession', 'subject'])
            ->where('subject_id', $subjectId)
            ->whereNotIn('id', $recentAttempts)
            ->orderBy('bac_year_id', 'desc')
            ->limit($limit)
            ->get();
    }
}
