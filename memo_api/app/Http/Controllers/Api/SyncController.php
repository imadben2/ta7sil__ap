<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

/**
 * Sync Controller - Handle offline sync for mobile apps
 * Returns all data modified since last sync timestamp
 */
class SyncController extends Controller
{
    /**
     * Get all data modified since last sync
     * GET /api/v1/sync?last_sync={timestamp}
     */
    public function sync(Request $request)
    {
        $user = Auth::user();

        // Validate last_sync timestamp
        $request->validate([
            'last_sync' => 'nullable|date',
        ]);

        $lastSync = $request->input('last_sync')
            ? Carbon::parse($request->input('last_sync'))
            : null;

        $syncData = [
            'sync_timestamp' => now()->toIso8601String(),
            'user_profile' => $this->getUserProfileUpdates($user, $lastSync),
            'study_sessions' => $this->getStudySessionUpdates($user, $lastSync),
            'contents' => $this->getContentUpdates($user, $lastSync),
            'quiz_attempts' => $this->getQuizAttemptUpdates($user, $lastSync),
            'preferences' => $user->settings ?? [],
            'notifications' => $this->getNotificationUpdates($user, $lastSync),
        ];

        return response()->json([
            'success' => true,
            'data' => $syncData,
        ]);
    }

    /**
     * Get user profile updates
     */
    private function getUserProfileUpdates($user, $lastSync)
    {
        if (!$lastSync || $user->updated_at > $lastSync) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'profile_picture' => $user->profile_picture,
                'academic_profile' => $user->academicProfile,
                'updated_at' => $user->updated_at->toIso8601String(),
            ];
        }

        return null;
    }

    /**
     * Get study session updates
     */
    private function getStudySessionUpdates($user, $lastSync)
    {
        $query = $user->studySessions()
            ->with('subject', 'contents');

        if ($lastSync) {
            $query->where('updated_at', '>', $lastSync);
        } else {
            // If no last sync, get upcoming and recent sessions
            $query->where(function ($q) {
                $q->whereDate('scheduled_date', '>=', now()->subDays(7))
                  ->whereDate('scheduled_date', '<=', now()->addDays(14));
            });
        }

        return $query->orderBy('scheduled_date', 'asc')
            ->get()
            ->map(function ($session) {
                return [
                    'id' => $session->id,
                    'subject_id' => $session->subject_id,
                    'subject' => [
                        'id' => $session->subject->id,
                        'name_ar' => $session->subject->name_ar,
                        'color' => $session->subject->color,
                    ],
                    'scheduled_date' => $session->scheduled_date,
                    'start_time' => $session->start_time,
                    'duration_minutes' => $session->duration_minutes,
                    'status' => $session->status,
                    'contents' => $session->contents->map(fn($c) => [
                        'id' => $c->id,
                        'title_ar' => $c->title_ar,
                    ]),
                    'updated_at' => $session->updated_at->toIso8601String(),
                ];
            });
    }

    /**
     * Get content updates (new published contents)
     */
    private function getContentUpdates($user, $lastSync)
    {
        if (!$user->academicProfile) {
            return [];
        }

        $query = \App\Models\Content::with('subject', 'contentType', 'chapter')
            ->where('is_published', true);

        if ($lastSync) {
            $query->where('updated_at', '>', $lastSync);
        } else {
            // Get recent contents (last 30 days)
            $query->where('created_at', '>=', now()->subDays(30));
        }

        return $query->orderBy('created_at', 'desc')
            ->limit(50) // Limit to prevent huge payloads
            ->get()
            ->map(function ($content) {
                return [
                    'id' => $content->id,
                    'title_ar' => $content->title_ar,
                    'description_ar' => $content->description_ar,
                    'subject' => [
                        'id' => $content->subject->id,
                        'name_ar' => $content->subject->name_ar,
                    ],
                    'content_type' => $content->contentType->name_ar ?? null,
                    'chapter' => $content->chapter->title_ar ?? null,
                    'file_path' => $content->file_path,
                    'url' => $content->url,
                    'created_at' => $content->created_at->toIso8601String(),
                    'updated_at' => $content->updated_at->toIso8601String(),
                ];
            });
    }

    /**
     * Get quiz attempt updates
     */
    private function getQuizAttemptUpdates($user, $lastSync)
    {
        $query = $user->quizAttempts()
            ->with('quiz.subject');

        if ($lastSync) {
            $query->where('updated_at', '>', $lastSync);
        } else {
            // Get recent attempts (last 30 days)
            $query->where('created_at', '>=', now()->subDays(30));
        }

        return $query->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($attempt) {
                return [
                    'id' => $attempt->id,
                    'quiz_id' => $attempt->quiz_id,
                    'quiz_title' => $attempt->quiz->title_ar ?? null,
                    'subject' => $attempt->quiz->subject->name_ar ?? null,
                    'score' => $attempt->score,
                    'max_score' => $attempt->max_score,
                    'percentage' => $attempt->max_score > 0
                        ? round(($attempt->score / $attempt->max_score) * 100, 2)
                        : 0,
                    'completed_at' => $attempt->completed_at?->toIso8601String(),
                    'updated_at' => $attempt->updated_at->toIso8601String(),
                ];
            });
    }

    /**
     * Get notification updates
     */
    private function getNotificationUpdates($user, $lastSync)
    {
        // Placeholder - implement when notification system is ready
        return [];
    }

    /**
     * Upload local changes from mobile app
     * POST /api/v1/sync/upload
     */
    public function upload(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'preferences' => 'nullable|array',
            'completed_sessions' => 'nullable|array',
            'quiz_attempts' => 'nullable|array',
        ]);

        $conflicts = [];

        // Update user preferences
        if ($request->has('preferences')) {
            $user->settings = array_merge($user->settings ?? [], $request->input('preferences'));
            $user->save();
        }

        // Sync completed sessions
        if ($request->has('completed_sessions')) {
            foreach ($request->input('completed_sessions') as $sessionData) {
                $session = \App\Models\StudySession::find($sessionData['id'] ?? null);

                if ($session && $session->user_id === $user->id) {
                    // Check for conflicts (server timestamp > client timestamp)
                    if ($session->updated_at > Carbon::parse($sessionData['updated_at'] ?? null)) {
                        $conflicts[] = [
                            'type' => 'study_session',
                            'id' => $session->id,
                            'reason' => 'server_data_newer',
                        ];
                        continue;
                    }

                    // Update session status
                    $session->update([
                        'status' => $sessionData['status'] ?? $session->status,
                        'actual_duration_minutes' => $sessionData['actual_duration_minutes'] ?? null,
                        'completed_at' => $sessionData['completed_at'] ?? null,
                    ]);
                }
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Sync completed successfully',
            'conflicts' => $conflicts,
            'sync_timestamp' => now()->toIso8601String(),
        ]);
    }
}
